<?php

namespace App\Http\Controllers\Staff;

use App\Http\Controllers\Controller;
use App\Http\Requests\Staff\AbsenceRequest;
use App\Models\Absence;
use Illuminate\Http\Request;

class AbsenceController extends Controller
{
    public function index(Request $req)
    {
        $this->authorize('viewAny', Absence::class);
        $q = Absence::query();
        if ($sid = $req->query('stylist_id')) {
            $q->where('stylist_id', $sid);
        }
        return response()->json(['absences' => $q->orderBy('from_date')->get()]);
    }

    public function store(AbsenceRequest $req)
    {
        $this->authorize('create', Absence::class);
        $absence = Absence::create($req->validated());
        // TODO: notify manager; optionally auto-block shifts in range
        return response()->json(['absence' => $absence], 201);
    }

    public function update(AbsenceRequest $req, Absence $absence)
    {
        $this->authorize('update', $absence);
        $absence->fill($req->validated())->save();
        return response()->json(['absence' => $absence]);
    }

    public function destroy(Absence $absence)
    {
        $this->authorize('delete', $absence);
        $absence->delete();
        return response()->json(['ok' => true]);
    }

    public function approve(Request $req, Absence $absence)
    {
        $this->authorize('approve', $absence);
        $absence->update(['status' => 'approved']);
        return response()->json(['absence' => $absence]);
    }
}