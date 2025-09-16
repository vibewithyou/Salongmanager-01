<?php

namespace App\Http\Requests\Staff;

use Illuminate\Foundation\Http\FormRequest;

class AbsenceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Policy check in Controller
    }

    public function rules(): array
    {
        return [
            'user_id' => ['required', 'exists:users,id'],
            'stylist_id' => ['nullable', 'integer', 'exists:stylists,id'],
            'start_at' => ['required', 'date'],
            'end_at' => ['required', 'date', 'after:start_at'],
            'from_date' => ['nullable', 'date'],
            'to_date' => ['nullable', 'date', 'after_or_equal:from_date'],
            'type' => ['required', 'in:vacation,sick,other'],
            'reason' => ['nullable', 'string', 'max:500'],
            'note' => ['nullable', 'string', 'max:1000'],
        ];
    }
}