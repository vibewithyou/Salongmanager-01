<?php

namespace App\Http\Controllers\Salon;

use App\Http\Controllers\Controller;
use App\Http\Requests\Salon\BlockUpsertRequest;
use App\Models\ContentBlock;
use Illuminate\Http\Request;

class BlockController extends Controller
{
    public function index(Request $request)
    {
        $blocks = ContentBlock::query()
            ->orderBy('position')
            ->get(['id','type','title','config','is_active','position','updated_at']);
        return response()->json(['blocks'=>$blocks]);
    }

    public function store(BlockUpsertRequest $request)
    {
        $this->authorize('create', ContentBlock::class);
        $block = ContentBlock::create($request->validated());
        return response()->json(['block'=>$block], 201);
    }

    public function show(ContentBlock $block)
    {
        $this->authorize('view', $block);
        return response()->json(['block'=>$block]);
    }

    public function update(BlockUpsertRequest $request, ContentBlock $block)
    {
        $this->authorize('update', $block);
        $block->fill($request->validated());
        $block->save();
        return response()->json(['block'=>$block->fresh()]);
    }

    public function destroy(ContentBlock $block)
    {
        $this->authorize('delete', $block);
        $block->delete();
        return response()->json(['ok'=>true]);
    }
}