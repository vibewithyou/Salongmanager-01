<?php

namespace App\Http\Requests\Inventory;

use Illuminate\Foundation\Http\FormRequest;

class TransferRequest extends FormRequest 
{
    public function authorize(): bool 
    {
        return true;
    }
    
    public function rules(): array 
    {
        return [
            'product_id' => ['required', 'exists:products,id'],
            'from_location_id' => ['required', 'exists:stock_locations,id'],
            'to_location_id' => ['required', 'exists:stock_locations,id', 'different:from_location_id'],
            'qty' => ['required', 'integer', 'min:1'],
            'note' => ['nullable', 'string', 'max:500'],
        ];
    }
}