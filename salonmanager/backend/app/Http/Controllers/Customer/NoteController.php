<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Customer\NoteRequest;
use App\Models\User;
use App\Models\CustomerNote;
use Illuminate\Http\Request;

class NoteController extends Controller
{
    public function index(User $customer)
    {
        $this->authorize('viewAny', CustomerNote::class);
        $notes = CustomerNote::where('customer_id', $customer->id)->orderByDesc('id')->get();
        return response()->json(['notes' => $notes]);
    }

    public function store(NoteRequest $req)
    {
        $this->authorize('create', CustomerNote::class);
        $note = CustomerNote::create([
            'salon_id' => app('tenant')->id,
            'customer_id' => $req->validated()['customer_id'],
            'author_id' => $req->user()->id,
            'note' => $req->validated()['note'],
        ]);
        return response()->json(['note' => $note], 201);
    }

    public function update(Request $req, CustomerNote $note)
    {
        $this->authorize('update', $note);
        $data = $req->validate(['note' => ['required', 'string', 'max:2000']]);
        $note->update($data);
        return response()->json(['note' => $note]);
    }

    public function destroy(CustomerNote $note)
    {
        $this->authorize('delete', $note);
        $note->delete();
        return response()->json(['ok' => true]);
    }
}