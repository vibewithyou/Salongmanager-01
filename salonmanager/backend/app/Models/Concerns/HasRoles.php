<?php

namespace App\Models\Concerns;

use App\Models\{Role, UserRole};
use Illuminate\Database\Eloquent\Relations\HasMany;

trait HasRoles
{
  public function userRoles(): HasMany { return $this->hasMany(UserRole::class); }

  /** Rollen nur für den aktiven Tenant + globale */
  public function rolesInTenant(?int $salonId = null): array {
    $salonId ??= app('tenant')->id ?? null;
    $q = $this->userRoles()->with('role');
    return $q->get()->filter(function($ur) use ($salonId) {
      /** @var \App\Models\UserRole $ur */
      if (!$ur->role) return false;
      if ($ur->role->scope === Role::GLOBAL) return true;
      return $salonId && $ur->salon_id === $salonId;
    })->map(fn($ur)=>$ur->role->name)->values()->all();
  }

  public function hasRole(string $name, ?int $salonId = null): bool {
    $salonId ??= app('tenant')->id ?? null;
    // short-circuit: owner immer true
    if ($name !== 'owner' && $this->hasRole('owner', null)) return true;
    $names = $this->rolesInTenant($salonId);
    return in_array($name, $names, true);
  }

  public function hasAnyRole(array $names, ?int $salonId = null): bool {
    foreach ($names as $n) if ($this->hasRole($n, $salonId)) return true;
    return false;
  }

  /** Grant convenience */
  public function grantRole(string $name, ?int $salonId = null): void {
    $roleId = Role::idBy($name);
    if (!$roleId) return;
    if ($name === 'owner' || $name === 'platform_admin') $salonId = null;
    UserRole::firstOrCreate(['user_id'=>$this->id,'role_id'=>$roleId,'salon_id'=>$salonId]);
  }

  public function revokeRole(string $name, ?int $salonId = null): void {
    $roleId = Role::idBy($name);
    if (!$roleId) return;
    $this->userRoles()->where(['role_id'=>$roleId,'salon_id'=>$salonId])->delete();
  }
}