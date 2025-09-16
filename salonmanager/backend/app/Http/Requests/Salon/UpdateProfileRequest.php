<?php

namespace App\Http\Requests\Salon;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool { 
        return true; // policy handles authorization
    }
    
    public function rules(): array {
        return [
            'name'               => ['sometimes','string','max:190'],
            'slug'               => ['sometimes','string','max:190'], // change slug only by owner? policy will decide
            'primary_color'      => ['sometimes','string','max:20'],
            'secondary_color'    => ['sometimes','string','max:20'],
            'brand'              => ['sometimes','array'],
            'seo'                => ['sometimes','array'],
            'social'             => ['sometimes','array'],
            'content_settings'   => ['sometimes','array'],
            'logo_path'          => ['nullable','string','max:255'], // TODO: move to upload endpoint
        ];
    }
}