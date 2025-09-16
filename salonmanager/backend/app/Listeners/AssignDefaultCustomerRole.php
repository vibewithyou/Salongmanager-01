<?php

namespace App\Listeners;

use App\Models\Role;

class AssignDefaultCustomerRole
{
  public function handle($event): void
  {
    $user = $event->user ?? $event->model ?? null;
    if (!$user) return;
    $salonId = app('tenant')->id ?? null;
    if (!$salonId) return; // ohne Tenant keine salon-gebundene Rolle

    // schon eine salon-gebundene Rolle? dann nichts tun
    if ($user->hasAnyRole(['customer','stylist','salon_manager','salon_owner'], $salonId)) return;

    $user->grantRole('customer', $salonId);
  }
}