<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class NotificationLog extends Model {
  use SalonOwned;
  protected $fillable = ['salon_id','user_id','event','channel','status','ref_type','ref_id','target','error','payload'];
  protected $casts = ['payload'=>'array'];
}