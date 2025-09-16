<?php
namespace App\Http\Requests\Notify;

use Illuminate\Foundation\Http\FormRequest;

class WebhookUpsertRequest extends FormRequest {
  public function authorize(): bool { return $this->user()->hasAnyRole(['salon_owner','salon_manager']); }
  public function rules(): array {
    return [
      'event'=>['required','string','max:120'],
      'url'=>['required','url','max:255'],
      'secret'=>['nullable','string','max:120'],
      'headers'=>['array'],
      'active'=>['boolean'],
    ];
  }
}