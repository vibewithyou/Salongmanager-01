<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    protected $fillable = ['name','label'];

    public const OWNER = 'owner';
    public const PLATFORM_ADMIN = 'platform_admin';
    public const SALON_OWNER = 'salon_owner';
    public const SALON_MANAGER = 'salon_manager';
    public const STYLIST = 'stylist';
    public const CUSTOMER = 'customer';
}

