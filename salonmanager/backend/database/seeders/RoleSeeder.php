<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;

class RoleSeeder extends Seeder
{
  public function run(): void
  {
    $defs = [
      ['name'=>'owner','scope'=>Role::GLOBAL],
      ['name'=>'platform_admin','scope'=>Role::GLOBAL],
      ['name'=>'salon_owner','scope'=>Role::SALON],
      ['name'=>'salon_manager','scope'=>Role::SALON],
      ['name'=>'stylist','scope'=>Role::SALON],
      ['name'=>'customer','scope'=>Role::SALON],
    ];
    foreach ($defs as $d) Role::updateOrCreate(['name'=>$d['name']], ['scope'=>$d['scope']]);
  }
}