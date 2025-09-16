<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class Webhook extends Model {
  use SalonOwned;
  protected $fillable = ['salon_id','event','url','secret','active','headers'];
  protected $casts = ['active'=>'boolean','headers'=>'array'];
}