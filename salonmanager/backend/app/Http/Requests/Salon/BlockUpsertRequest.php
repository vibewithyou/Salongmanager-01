<?php

namespace App\Http\Requests\Salon;

use Illuminate\Foundation\Http\FormRequest;

class BlockUpsertRequest extends FormRequest
{
    public function authorize(): bool { 
        return true; // policy handles authorization
    }
    
    public function rules(): array {
        return [
            'type'      => ['required','string','max:50'],
            'title'     => ['nullable','string','max:190'],
            'config'    => ['nullable','array'],
            'is_active' => ['sometimes','boolean'],
            'position'  => ['sometimes','integer','min:0','max:1000'],
        ];
    }
}