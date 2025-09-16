<?php

namespace App\Http\Requests\Rbac;

use Illuminate\Foundation\Http\FormRequest;

class GrantRoleRequest extends FormRequest
{
  public function authorize(): bool {
    return $this->user()->hasAnyRole(['owner','platform_admin','salon_owner','salon_manager']);
  }
  public function rules(): array {
    return [
      'user_id' => ['required','exists:users,id'],
      'role'    => ['required','string','in:owner,platform_admin,salon_owner,salon_manager,stylist,customer'],
      'salon_id'=> ['nullable','exists:salons,id'],
    ];
  }
}