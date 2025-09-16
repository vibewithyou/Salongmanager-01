<?php

namespace App\Http\Controllers;

use App\Http\Requests\Staff\ShiftUpsertRequest;
use App\Http\Requests\Staff\AbsenceRequest;
use App\Models\{Shift, Absence, WorkRule};
use App\Services\Schedule\{Recurrence, ConflictChecker, Rules};
use Carbon\Carbon;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    // --- SHIFTS ---
    public function listShifts(Request $r)
    {
        $salonId = app('tenant')->id;
        $from = Carbon::parse($r->query('from', now()->startOfMonth()));
        $to = Carbon::parse($r->query('to', now()->endOfMonth()));
        $userId = $r->query('user_id');

        $q = Shift::where('salon_id', $salonId)->when($userId, fn ($x) => $x->where('user_id', $userId));
        $rows = $q->get();
        
        // expand recurrence
        $events = [];
        foreach ($rows as $s) {
            $expanded = Recurrence::expand($s, $from, $to);
            foreach ($expanded as [$start, $end]) {
                $events[] = [
                    'id' => $s->id,
                    'user_id' => $s->user_id,
                    'title' => $s->title,
                    'role' => $s->role,
                    'start_at' => $start->toIso8601String(),
                    'end_at' => $end->toIso8601String(),
                    'published' => $s->published
                ];
            }
        }
        return response()->json(['items' => $events]);
    }

    public function upsertShift(ShiftUpsertRequest $r)
    {
        $salonId = app('tenant')->id;
        $v = $r->validated();
        
        // rule check
        if (Rules::violatesDailyHours($salonId, $v['start_at'], $v['end_at'])) {
            return response()->json(['error' => 'rule_violation', 'field' => 'end_at', 'msg' => 'Exceeds max hours per day'], 422);
        }
        
        // conflict checks
        $from = Carbon::parse($v['start_at']);
        $to = Carbon::parse($v['end_at']);
        if (ConflictChecker::hasBookingConflict($salonId, (int) $v['user_id'], $from, $to)) {
            return response()->json(['error' => 'booking_conflict'], 409);
        }
        if (ConflictChecker::hasAbsenceConflict($salonId, (int) $v['user_id'], $from, $to)) {
            return response()->json(['error' => 'absence_conflict'], 409);
        }

        $shift = Shift::updateOrCreate(
            ['salon_id' => $salonId, 'id' => $r->route('shift')?->id ?? 0],
            [
                'user_id' => $v['user_id'],
                'stylist_id' => $v['stylist_id'] ?? null,
                'start_at' => $v['start_at'],
                'end_at' => $v['end_at'],
                'role' => $v['role'] ?? null,
                'title' => $v['title'] ?? null,
                'rrule' => $v['rrule'] ?? null,
                'exdates' => $v['exdates'] ?? [],
                'published' => $v['published'] ?? true,
                'status' => $v['status'] ?? 'planned',
                'meta' => $v['meta'] ?? []
            ]
        );
        
        \App\Support\Audit\Audit::write('schedule.shift.upsert', 'Shift', $shift->id, []);
        return response()->json(['shift' => $shift]);
    }

    public function deleteShift(Shift $shift)
    {
        $this->authorizeRole(['salon_owner', 'salon_manager']);
        $shift->delete();
        \App\Support\Audit\Audit::write('schedule.shift.delete', 'Shift', $shift->id, []);
        return response()->json(['ok' => true]);
    }

    // --- ABSENCES ---
    public function listAbsences(Request $r)
    {
        $salonId = app('tenant')->id;
        $from = Carbon::parse($r->query('from', now()->startOfMonth()));
        $to = Carbon::parse($r->query('to', now()->endOfMonth()));
        $userId = $r->query('user_id');

        $q = Absence::where('salon_id', $salonId)
            ->whereBetween('start_at', [$from, $to])
            ->when($userId, fn ($x) => $x->where('user_id', $userId));
        return response()->json(['items' => $q->orderBy('start_at')->get()]);
    }

    public function requestAbsence(AbsenceRequest $r)
    {
        $u = $r->user();
        $salonId = app('tenant')->id;
        
        // Stylist darf nur für sich; Manager/Owner für alle
        if ($u->hasAnyRole(['salon_owner', 'salon_manager']) === false && $u->id !== (int) $r->input('user_id')) {
            abort(403);
        }
        
        $v = $r->validated();
        $abs = Absence::create([
            'salon_id' => $salonId,
            'user_id' => $v['user_id'],
            'stylist_id' => $v['stylist_id'] ?? null,
            'start_at' => $v['start_at'],
            'end_at' => $v['end_at'],
            'from_date' => $v['from_date'] ?? Carbon::parse($v['start_at'])->toDateString(),
            'to_date' => $v['to_date'] ?? Carbon::parse($v['end_at'])->toDateString(),
            'type' => $v['type'],
            'reason' => $v['reason'] ?? null,
            'note' => $v['note'] ?? null,
            'status' => 'pending'
        ]);
        
        \App\Support\Audit\Audit::write('schedule.absence.request', 'Absence', $abs->id, []);
        // Optional: Notify Manager (Prompt 15)
        return response()->json(['absence' => $abs], 201);
    }

    public function decideAbsence(Absence $absence, Request $r)
    {
        $this->authorizeRole(['salon_owner', 'salon_manager']);
        $r->validate(['action' => 'required|in:approve,reject', 'reason' => 'nullable|string|max:500']);
        
        $absence->status = $r->input('action') === 'approve' ? 'approved' : 'rejected';
        $absence->save();
        
        \App\Support\Audit\Audit::write('schedule.absence.' . $absence->status, 'Absence', $absence->id, []);
        // Optional: Notify stylist result
        return response()->json(['absence' => $absence]);
    }

    // --- WORK RULES ---
    public function getWorkRules()
    {
        $salonId = app('tenant')->id;
        $rules = WorkRule::where('salon_id', $salonId)->first();
        return response()->json(['rules' => $rules]);
    }

    public function updateWorkRules(Request $r)
    {
        $this->authorizeRole(['salon_owner', 'salon_manager']);
        $salonId = app('tenant')->id;
        
        $r->validate([
            'max_hours_per_day' => 'required|integer|min:1|max:24',
            'min_break_minutes_per6h' => 'required|integer|min:0|max:480'
        ]);
        
        $rules = WorkRule::updateOrCreate(
            ['salon_id' => $salonId],
            $r->only(['max_hours_per_day', 'min_break_minutes_per6h'])
        );
        
        return response()->json(['rules' => $rules]);
    }

    private function authorizeRole(array $roles): void
    {
        if (!request()->user()->hasAnyRole($roles)) {
            abort(403);
        }
    }
}
