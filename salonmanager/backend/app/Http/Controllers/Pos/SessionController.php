<?php

namespace App\Http\Controllers\Pos;

use App\Http\Controllers\Controller;
use App\Http\Requests\Pos\OpenSessionRequest;
use App\Models\PosSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class SessionController extends Controller
{
    public function open(OpenSessionRequest $request)
    {
        abort_unless(Gate::allows('pos.use'), 403);
        
        $session = PosSession::create([
            'salon_id' => app('tenant')->id,
            'user_id' => $request->user()->id,
            'opened_at' => now(),
            'opening_cash' => $request->validated()['opening_cash'] ?? 0,
        ]);
        
        return response()->json(['session' => $session], 201);
    }

    public function close(Request $request, PosSession $session)
    {
        abort_unless(Gate::allows('pos.manage'), 403);
        
        $data = $request->validate([
            'closing_cash' => ['required', 'numeric']
        ]);
        
        $session->update([
            'closed_at' => now(),
            'closing_cash' => $data['closing_cash']
        ]);
        
        return response()->json(['session' => $session]);
    }
}