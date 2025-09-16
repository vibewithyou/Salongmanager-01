<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\{User, Role};

class RbacGrant extends Command
{
  protected $signature = 'rbac:grant {user_id} {role} {--salon_id=}';
  protected $description = 'Grant a role to user (optional salon_id)';

  public function handle(): int
  {
    $uid = (int)$this->argument('user_id');
    $role = (string)$this->argument('role');
    $salonId = $this->option('salon_id') ? (int)$this->option('salon_id') : null;

    $user = User::find($uid);
    if (!$user) { $this->error('User not found'); return 1; }
    if (!Role::where('name',$role)->exists()) { $this->error('Role not found'); return 1; }

    $user->grantRole($role, $salonId);
    $this->info("Granted {$role} to user {$uid}".($salonId? " for salon {$salonId}" : ' (global)'));
    return 0;
  }
}