<?php

namespace App\Http\Requests\Review;

use Illuminate\Foundation\Http\FormRequest;

class StoreReviewRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return $this->user()?->hasRole('customer') ?? false;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'body' => ['nullable', 'string', 'max:2000'],
            'media_ids' => ['nullable', 'array'],
            'media_ids.*' => ['integer', 'exists:media_files,id'],
        ];
    }

    /**
     * Get custom error messages.
     */
    public function messages(): array
    {
        return [
            'rating.required' => 'Bitte geben Sie eine Bewertung ab.',
            'rating.min' => 'Die Bewertung muss mindestens 1 Stern betragen.',
            'rating.max' => 'Die Bewertung darf maximal 5 Sterne betragen.',
            'body.max' => 'Die Rezension darf maximal 2000 Zeichen lang sein.',
            'media_ids.*.exists' => 'Eine oder mehrere ausgewählte Mediendateien existieren nicht.',
        ];
    }
}