<?php
namespace App\Http\Requests\Notify;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePrefsRequest extends FormRequest {
  public function authorize(): bool { return true; }
  public function rules(): array {
    return [
      'items' => ['required','array','min:1'],
      'items.*.event' => ['required','string','max:120'],
      'items.*.channel' => ['required','in:mail,sms,webhook'],
      'items.*.enabled' => ['required','boolean'],
    ];
  }
}