<?php

namespace App\Http\Requests\Staff;

use Illuminate\Foundation\Http\FormRequest;

class ShiftUpsertRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'stylist_id' => ['required', 'integer', 'exists:stylists,id'],
            'start_at' => ['required', 'date'],
            'end_at' => ['required', 'date', 'after:start_at'],
            'status' => ['sometimes', 'in:planned,confirmed,swapped,canceled'],
            'meta' => ['sometimes', 'array'],
        ];
    }
}