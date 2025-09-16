<?php

namespace App\Observers;

use App\Models\ProductPrice;
use App\Support\Audit\Audit;

class ProductPriceObserver
{
    public function updated(ProductPrice $p): void
    {
        if ($p->isDirty(['price','active'])) {
            Audit::write('inventory.price.updated','ProductPrice',$p->id,[
                'price_new'=>$p->price,
                'active'=>$p->active,
            ]);
        }
    }
}