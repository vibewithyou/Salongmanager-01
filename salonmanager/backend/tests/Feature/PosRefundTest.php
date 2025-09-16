<?php

namespace Tests\Feature;

use App\Models\Invoice;
use App\Models\Refund;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PosRefundTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_refund_full_invoice()
    {
        // TODO: Test full refund
        // - Create paid invoice
        // - Process full refund
        // - Verify invoice status changes to 'refunded'
        $this->markTestIncomplete('TODO: Implement full refund test');
    }

    public function test_can_refund_partial_invoice()
    {
        // TODO: Test partial refund
        // - Create paid invoice
        // - Process partial refund
        // - Verify invoice remains 'paid' status
        // - Test line-item refunds
        $this->markTestIncomplete('TODO: Implement partial refund test');
    }

    public function test_refund_permissions()
    {
        // TODO: Test RBAC for refunds
        // - Only salon_owner/salon_manager can refund
        // - Stylists cannot refund
        $this->markTestIncomplete('TODO: Implement refund permissions test');
    }
}