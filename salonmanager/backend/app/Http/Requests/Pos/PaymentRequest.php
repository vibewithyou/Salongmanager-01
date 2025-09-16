<?php

namespace App\Http\Requests\Pos;

use Illuminate\Foundation\Http\FormRequest;

class PaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'method' => ['required', 'in:cash,card,external'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'meta' => ['array'],
        ];
    }
}