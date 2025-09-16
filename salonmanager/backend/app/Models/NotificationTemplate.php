<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationTemplate extends Model {
  protected $fillable = ['salon_id','event','channel','locale','subject','body_markdown','webhook_json','active'];
  protected $casts = ['active'=>'boolean'];
}