<?php

namespace App\Http\Controllers\Rbac;

use App\Http\Controllers\Controller;
use App\Http\Requests\Rbac\GrantRoleRequest;
use App\Models\User;

class RoleController extends Controller
{
  public function grant(GrantRoleRequest $r) {
    $v = $r->validated();
    $user = User::findOrFail($v['user_id']);
    $salonId = $v['salon_id'] ?? (app('tenant')->id ?? null);
    $user->grantRole($v['role'], $salonId);
    return response()->json(['ok'=>true]);
  }

  public function revoke(GrantRoleRequest $r) {
    $v = $r->validated();
    $user = User::findOrFail($v['user_id']);
    $salonId = $v['salon_id'] ?? (app('tenant')->id ?? null);
    $user->revokeRole($v['role'], $salonId);
    return response()->json(['ok'=>true]);
  }

  public function myRoles() {
    $salonId = app('tenant')->id ?? null;
    return response()->json(['roles'=>auth()->user()?->rolesInTenant($salonId) ?? []]);
  }
}