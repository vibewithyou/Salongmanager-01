<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\Discount;

class DiscountController extends Controller
{
    public function index()
    {
        $q = Discount::query()->where('active', true);
        $today = now()->toDateString();
        $q->where(function($w) use ($today) {
            $w->whereNull('valid_from')->orWhere('valid_from', '<=', $today);
        })->where(function($w) use ($today) {
            $w->whereNull('valid_to')->orWhere('valid_to', '>=', $today);
        });
        return response()->json(['discounts' => $q->orderBy('id', 'desc')->get()]);
    }
}