<?php

namespace App\Http\Controllers\Staff;

use App\Http\Controllers\Controller;
use App\Http\Requests\Staff\ShiftUpsertRequest;
use App\Models\Shift;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ShiftController extends Controller
{
    public function index(Request $req)
    {
        $this->authorize('viewAny', Shift::class);
        $from = $req->query('from'); // ISO
        $to = $req->query('to');
        $q = Shift::query()->with('stylist');
        if ($from) {
            $q->where('start_at', '>=', Carbon::parse($from));
        }
        if ($to) {
            $q->where('end_at', '<=', Carbon::parse($to));
        }
        // optional filter by stylist_id
        if ($sid = $req->query('stylist_id')) {
            $q->where('stylist_id', $sid);
        }
        return response()->json(['shifts' => $q->orderBy('start_at')->get()]);
    }

    public function store(ShiftUpsertRequest $req)
    {
        $this->authorize('create', Shift::class);
        // TODO: availability collision check with bookings/absences
        $shift = Shift::create($req->validated());
        return response()->json(['shift' => $shift->fresh('stylist')], 201);
    }

    public function update(ShiftUpsertRequest $req, Shift $shift)
    {
        $this->authorize('update', $shift);
        $shift->fill($req->validated())->save();
        return response()->json(['shift' => $shift->fresh('stylist')]);
    }

    public function destroy(Shift $shift)
    {
        $this->authorize('delete', $shift);
        $shift->delete();
        return response()->json(['ok' => true]);
    }

    /** Drag: move shift (start/end change) */
    public function move(Request $req, Shift $shift)
    {
        $this->authorize('update', $shift);
        $data = $req->validate([
            'start_at' => ['required', 'date'],
            'end_at' => ['required', 'date', 'after:start_at'],
        ]);
        // TODO: collision check
        $shift->update($data);
        return response()->json(['shift' => $shift->fresh()]);
    }

    /** Resize: update only end_at */
    public function resize(Request $req, Shift $shift)
    {
        $this->authorize('update', $shift);
        $data = $req->validate([
            'end_at' => ['required', 'date', 'after:' . $shift->start_at],
        ]);
        $shift->update($data);
        return response()->json(['shift' => $shift->fresh()]);
    }
}