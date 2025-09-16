<?php

namespace App\Http\Requests\Media;

use Illuminate\Foundation\Http\FormRequest;

class FinalizeUploadRequest extends FormRequest
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
            'key' => ['required', 'string', 'max:255'], // object key used for the upload
            'mime' => ['required', 'string', 'max:100'],
            'bytes' => ['required', 'integer', 'min:1'],
            'owner_type' => ['required', 'string', 'max:190'],
            'owner_id' => ['required', 'integer'],
            'width' => ['nullable', 'integer', 'min:1'],
            'height' => ['nullable', 'integer', 'min:1'],
            'visibility' => ['nullable', 'in:public,internal,private'],
            'consent_required' => ['boolean'],
            'subject_user_id' => ['nullable', 'exists:users,id'],
            'subject_name' => ['nullable', 'string', 'max:120'],
            'subject_contact' => ['nullable', 'string', 'max:190'],
        ];
    }
}