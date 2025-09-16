<?php

namespace App\Http\Requests\Inventory;

use Illuminate\Foundation\Http\FormRequest;

class ProductUpsertRequest extends FormRequest 
{
    public function authorize(): bool 
    {
        return true;
    }
    
    public function rules(): array 
    {
        return [
            'supplier_id' => ['nullable', 'exists:suppliers,id'],
            'sku' => ['required', 'string', 'max:64'],
            'barcode' => ['nullable', 'string', 'max:64'],
            'name' => ['required', 'string', 'max:190'],
            'description' => ['nullable', 'string'],
            'tax_rate' => ['required', 'numeric', 'min:0', 'max:99.99'],
            'reorder_point' => ['nullable', 'integer', 'min:0'],
            'reorder_qty' => ['nullable', 'integer', 'min:0'],
            'meta' => ['array'],
            'price' => ['nullable', 'array'], // {net_price,tax_rate,gross_price}
        ];
    }
}