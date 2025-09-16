<?php

namespace App\Http\Controllers\Pos;

use App\Http\Controllers\Controller;
use App\Http\Requests\Pos\InvoiceCreateRequest;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\PosSession;
use App\Services\Invoicing\NumberGenerator;
use App\Services\Invoicing\Totals;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class InvoiceController extends Controller
{
    public function store(InvoiceCreateRequest $request)
    {
        abort_unless(Gate::allows('pos.use'), 403);
        
        $salonId = app('tenant')->id;
        $calc = Totals::compute($request->validated()['lines']);
        $number = NumberGenerator::nextForSalon($salonId);

        $invoice = DB::transaction(function () use ($salonId, $request, $calc, $number) {
            $invoice = Invoice::create([
                'salon_id' => $salonId,
                'pos_session_id' => PosSession::query()
                    ->where('salon_id', $salonId)
                    ->whereNull('closed_at')
                    ->latest('opened_at')
                    ->value('id'),
                'customer_id' => $request->validated()['customer_id'] ?? null,
                'number' => $number,
                'issued_at' => now(),
                'total_net' => $calc['total_net'],
                'total_tax' => $calc['total_tax'],
                'total_gross' => $calc['total_gross'],
                'tax_breakdown' => $calc['tax_breakdown'],
                'status' => 'open',
                'meta' => $request->validated()['meta'] ?? [],
            ]);
            
            foreach ($calc['lines'] as $line) {
                InvoiceItem::create([
                    'invoice_id' => $invoice->id,
                    'type' => $line['type'],
                    'reference_id' => $line['reference_id'] ?? null,
                    'name' => $line['name'],
                    'qty' => $line['qty'],
                    'unit_net' => $line['unit_net'],
                    'tax_rate' => $line['tax_rate'],
                    'line_net' => $line['line_net'],
                    'line_tax' => $line['line_tax'],
                    'line_gross' => $line['line_gross'],
                    'meta' => isset($line['discount']) ? ['discount' => $line['discount']] : null,
                ]);
            }
            
            return $invoice;
        });

        return response()->json(['invoice' => $invoice->load('items')], 201);
    }

    public function show(Invoice $invoice)
    {
        return response()->json(['invoice' => $invoice->load('items', 'payments')]);
    }
}