<?php

namespace App\Http\Requests\Search;

use Illuminate\Foundation\Http\FormRequest;

class SalonSearchRequest extends FormRequest
{
    public function authorize(): bool { return true; }
    public function rules(): array {
        return [
            'q'         => ['nullable','string','max:120'],
            'lat'       => ['nullable','numeric','between:-90,90'],
            'lng'       => ['nullable','numeric','between:-180,180'],
            'radius_km' => ['nullable','numeric','min:1','max:100'],
            'service_id' => ['nullable','integer','exists:services,id'],
            'services'  => ['nullable','array'],
            'services.*' => ['integer','exists:services,id'],
            'price_min' => ['nullable','numeric','min:0'],
            'price_max' => ['nullable','numeric','min:0'],
            'rating_min' => ['nullable','numeric','min:0','max:5'],
            'open_now'  => ['nullable','boolean'],
            'page'      => ['nullable','integer','min:1'],
            'per_page'  => ['nullable','integer','min:1','max:50'],
            'sort'      => ['nullable','in:distance,name,rating'],
        ];
    }
}