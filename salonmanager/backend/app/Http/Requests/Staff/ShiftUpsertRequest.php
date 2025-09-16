<?php

namespace App\Http\Requests\Staff;

use Illuminate\Foundation\Http\FormRequest;

class ShiftUpsertRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasAnyRole(['salon_owner', 'salon_manager']);
    }

    public function rules(): array
    {
        return [
            'user_id' => ['required', 'exists:users,id'],
            'stylist_id' => ['nullable', 'integer', 'exists:stylists,id'],
            'start_at' => ['required', 'date'],
            'end_at' => ['required', 'date', 'after:start_at'],
            'role' => ['nullable', 'string', 'max:40'],
            'title' => ['nullable', 'string', 'max:80'],
            'rrule' => ['nullable', 'string', 'max:255'],
            'exdates' => ['array'],
            'exdates.*' => ['date'],
            'published' => ['boolean'],
            'status' => ['sometimes', 'in:planned,confirmed,swapped,canceled'],
            'meta' => ['sometimes', 'array'],
        ];
    }
}