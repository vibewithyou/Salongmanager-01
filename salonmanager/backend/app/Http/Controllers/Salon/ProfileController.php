<?php

namespace App\Http\Controllers\Salon;

use App\Http\Controllers\Controller;
use App\Http\Requests\Salon\UpdateProfileRequest;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $salon = app('tenant');
        return response()->json([
            'salon' => $salon->only([
                'id','name','slug','logo_path','primary_color','secondary_color'
            ]) + [
                'brand'            => $salon->brand ?? [],
                'seo'              => $salon->seo ?? [],
                'social'           => $salon->social ?? [],
                'content_settings' => $salon->content_settings ?? [],
            ],
        ]);
    }

    public function update(UpdateProfileRequest $req)
    {
        $salon = app('tenant');
        $this->authorize('update', $salon);

        $salon->fill($req->validated());
        $salon->save();

        return response()->json(['ok'=>true, 'salon'=>$salon->fresh()]);
    }
}