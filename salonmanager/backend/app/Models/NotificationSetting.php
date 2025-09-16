<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class NotificationSetting extends Model {
  use SalonOwned;
  protected $fillable = ['salon_id','user_id','event','channel','enabled','meta'];
  protected $casts = ['enabled'=>'boolean','meta'=>'array'];
}