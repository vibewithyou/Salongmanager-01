<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
  protected $fillable = ['name','scope'];
  public const GLOBAL = 'global';
  public const SALON  = 'salon';

  public static function idBy(string $name): ?int {
    return static::query()->where('name',$name)->value('id');
  }
}