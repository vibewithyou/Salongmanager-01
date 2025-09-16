<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class GdprRequest extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'user_id', 'type', 'status', 'artifact_path', 'meta'];
    protected $casts = ['meta' => 'array'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}