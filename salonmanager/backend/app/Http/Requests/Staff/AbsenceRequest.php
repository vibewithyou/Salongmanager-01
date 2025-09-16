<?php

namespace App\Http\Requests\Staff;

use Illuminate\Foundation\Http\FormRequest;

class AbsenceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'stylist_id' => ['required', 'integer', 'exists:stylists,id'],
            'from_date' => ['required', 'date'],
            'to_date' => ['required', 'date', 'after_or_equal:from_date'],
            'type' => ['required', 'in:vacation,sick,other'],
            'note' => ['nullable', 'string', 'max:1000'],
        ];
    }
}