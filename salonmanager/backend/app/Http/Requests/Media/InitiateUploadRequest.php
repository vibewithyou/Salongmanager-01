<?php

namespace App\Http\Requests\Media;

use Illuminate\Foundation\Http\FormRequest;

class InitiateUploadRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'filename' => ['required', 'string', 'max:190'],
            'mime' => ['required', 'string', 'max:100'],
            'bytes' => ['required', 'integer', 'min:1', 'max:104857600'], // 100 MB
            'visibility' => ['nullable', 'in:public,internal,private'],
            // Consent payload (optional; required for personenbezogene Fotos)
            'consent_required' => ['boolean'],
            'subject_user_id' => ['nullable', 'exists:users,id'],
            'subject_name' => ['nullable', 'string', 'max:120'],
            'subject_contact' => ['nullable', 'string', 'max:190'],
        ];
    }
}