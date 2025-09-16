<?php

namespace App\Http\Requests\Booking;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStatusRequest extends FormRequest 
{
  public function authorize(): bool 
  { 
    return true; 
  }
  
  public function rules(): array 
  {
    return [
      'action' => ['required','in:confirm,decline,cancel'],
      'reason' => ['nullable','string','max:500'],
    ];
  }
}