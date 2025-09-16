<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class CustomerNote extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'customer_id', 'author_id', 'note'];

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function author()
    {
        return $this->belongsTo(User::class, 'author_id');
    }
}