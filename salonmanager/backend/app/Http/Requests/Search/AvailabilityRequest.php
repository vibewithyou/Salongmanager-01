<?php

namespace App\Http\Requests\Search;

use Illuminate\Foundation\Http\FormRequest;

class AvailabilityRequest extends FormRequest
{
    public function authorize(): bool { return true; }
    public function rules(): array {
        return [
            'salon_id'   => ['required','integer','exists:salons,id'],
            'service_id' => ['required','integer','exists:services,id'],
            'from'       => ['nullable','date'], // default now
            'to'         => ['nullable','date'], // default +14 days
            'limit'      => ['nullable','integer','min:1','max:10'],
        ];
    }
}