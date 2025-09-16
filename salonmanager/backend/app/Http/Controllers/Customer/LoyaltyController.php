<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\LoyaltyCard;
use App\Models\LoyaltyTransaction;
use Illuminate\Http\Request;

class LoyaltyController extends Controller
{
    public function show(User $customer)
    {
        $card = LoyaltyCard::firstOrCreate([
            'salon_id' => app('tenant')->id,
            'customer_id' => $customer->id,
        ]);
        $this->authorize('view', $card);
        return response()->json(['card' => $card, 'transactions' => $card->tx()->orderByDesc('id')->get()]);
    }

    public function adjust(Request $req, User $customer)
    {
        $card = LoyaltyCard::firstOrCreate([
            'salon_id' => app('tenant')->id,
            'customer_id' => $customer->id
        ]);
        $this->authorize('adjust', $card);
        $data = $req->validate(['delta' => ['required', 'integer', 'between:-10000,10000'], 'reason' => ['nullable', 'string', 'max:190']]);
        $tx = LoyaltyTransaction::create([
            'salon_id' => app('tenant')->id,
            'card_id' => $card->id,
            'delta' => $data['delta'],
            'reason' => $data['reason'] ?? null
        ]);
        $card->increment('points', $data['delta']);
        return response()->json(['card' => $card->fresh(), 'transaction' => $tx], 201);
    }
}