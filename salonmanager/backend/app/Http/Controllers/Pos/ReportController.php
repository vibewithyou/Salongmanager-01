<?php

namespace App\Http\Controllers\Pos;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ReportController extends Controller
{
    public function zReport(Request $request)
    {
        abort_unless(Gate::allows('pos.manage'), 403);
        
        $from = Carbon::parse($request->query('from', now()->startOfDay()));
        $to = Carbon::parse($request->query('to', now()->endOfDay()));
        $salonId = app('tenant')->id;

        $invoices = Invoice::where('salon_id', $salonId)
            ->whereBetween('issued_at', [$from, $to])
            ->get();
            
        $payments = Payment::where('salon_id', $salonId)
            ->whereBetween('paid_at', [$from, $to])
            ->get();

        $byMethod = $payments->groupBy('method')->map->sum('amount');
        $totNet = $invoices->sum('total_net');
        $totTax = $invoices->sum('total_tax');
        $totGross = $invoices->sum('total_gross');

        return response()->json([
            'range' => [$from->toDateTimeString(), $to->toDateTimeString()],
            'summary' => ['net' => $totNet, 'tax' => $totTax, 'gross' => $totGross],
            'payments' => $byMethod,
            'count_invoices' => $invoices->count(),
        ]);
    }

    public function datevCsv(Request $request)
    {
        abort_unless(Gate::allows('pos.manage'), 403);
        
        // Simple CSV stub (Soll/Haben neutral): date, number, net, tax, gross
        $from = Carbon::parse($request->query('from', now()->startOfMonth()));
        $to = Carbon::parse($request->query('to', now()->endOfMonth()));
        $salonId = app('tenant')->id;

        $rows = Invoice::where('salon_id', $salonId)
            ->whereBetween('issued_at', [$from, $to])
            ->orderBy('issued_at')
            ->get(['number', 'issued_at', 'total_net', 'total_tax', 'total_gross']);

        $csv = "date;number;net;tax;gross\n";
        foreach ($rows as $row) {
            $csv .= sprintf(
                "%s;%s;%.2f;%.2f;%.2f\n",
                $row->issued_at->format('Y-m-d'),
                $row->number,
                $row->total_net,
                $row->total_tax,
                $row->total_gross
            );
        }
        
        return response($csv, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="datev_export.csv"'
        ]);
    }
}