<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Customer\ProfileUpsertRequest;
use App\Models\User;
use App\Models\CustomerProfile;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $req)
    {
        $this->authorize('viewAny', User::class);
        $q = User::query()
            ->whereHas('roles', fn($r) => $r->where('name', 'customer'))
            ->select(['id', 'name', 'email']);
        if ($s = $req->query('search')) {
            $q->where(fn($w) => $w->where('name', 'like', "%$s%")->orWhere('email', 'like', "%$s%"));
        }
        return response()->json(['customers' => $q->orderBy('name')->paginate(20)]);
    }

    public function show(User $customer)
    {
        $this->authorize('view', $customer);
        $profile = CustomerProfile::firstOrCreate([
            'salon_id' => app('tenant')->id,
            'user_id' => $customer->id,
        ]);
        return response()->json(['customer' => $customer->only(['id', 'name', 'email']), 'profile' => $profile]);
    }

    public function update(ProfileUpsertRequest $req, User $customer)
    {
        $this->authorize('update', $customer);
        $profile = CustomerProfile::firstOrCreate([
            'salon_id' => app('tenant')->id,
            'user_id' => $customer->id
        ]);
        $profile->fill($req->validated())->save();
        return response()->json(['profile' => $profile->fresh()]);
    }

    // DSGVO-Stubs
    public function requestExport(User $customer)
    {
        $this->authorize('view', $customer);
        // TODO: dispatch export job, write audit log
        return response()->json(['ok' => true, 'message' => 'Export requested (TODO job)']);
    }

    public function requestDeletion(User $customer)
    {
        $this->authorize('update', $customer);
        // TODO: dispatch deletion workflow (soft queue + retention)
        return response()->json(['ok' => true, 'message' => 'Deletion requested (TODO workflow)']);
    }
}