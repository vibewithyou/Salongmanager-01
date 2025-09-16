<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserRole extends Model
{
  protected $fillable = ['user_id','role_id','salon_id'];

  public function role(): BelongsTo {
    return $this->belongsTo(Role::class);
  }
}