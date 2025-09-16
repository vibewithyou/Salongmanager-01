<?php

namespace App\Http\Requests\Booking;

use Illuminate\Foundation\Http\FormRequest;

class StoreBookingRequest extends FormRequest 
{
  public function authorize(): bool 
  { 
    return true; 
  }
  
  public function rules(): array 
  {
    return [
      'customer_id' => ['required','integer','exists:users,id'],
      'stylist_id'  => ['required','integer','exists:users,id'],
      'service_id'  => ['required','integer','exists:services,id'],
      'start_at'    => ['required','date'],
      'duration'    => ['required','integer','min:5','max:600'], // minutes
      'buffer_before'=> ['nullable','integer','min:0','max:60'],
      'buffer_after' => ['nullable','integer','min:0','max:60'],
      'note'        => ['nullable','string','max:2000'],
      'media_ids'   => ['array'],
      'media_ids.*' => ['integer','exists:media_files,id'],
      // Für Alternativvorschläge
      'suggest_if_conflict' => ['boolean'],
    ];
  }
}