<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;

class ProfileUpsertRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'phone' => ['nullable', 'string', 'max:30'],
            'preferred_stylist' => ['nullable', 'string', 'max:190'],
            'prefs' => ['nullable', 'array'],
            'address' => ['nullable', 'array'],
        ];
    }
}