<?php

namespace App\Http\Requests\Pos;

use Illuminate\Foundation\Http\FormRequest;

class InvoiceCreateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'customer_id' => ['nullable', 'exists:users,id'],
            'lines' => ['required', 'array', 'min:1'],
            'lines.*.type' => ['required', 'string'],
            'lines.*.reference_id' => ['nullable', 'integer'],
            'lines.*.name' => ['required', 'string', 'max:190'],
            'lines.*.qty' => ['required', 'integer', 'min:1'],
            'lines.*.unit_net' => ['required', 'numeric', 'min:0'],
            'lines.*.tax_rate' => ['required', 'numeric', 'min:0', 'max:99.99'],
            'lines.*.discount' => ['nullable'], // percent|amount
            'meta' => ['array'],
        ];
    }
}