<?php

namespace App\Console\Commands;

use App\Models\Invoice;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;

class ExportDatev extends Command
{
    protected $signature = 'export:datev {from} {to} {--salon=} {--format=csv}';
    protected $description = 'Export invoices to DATEV CSV format for accounting';

    public function handle()
    {
        $from = $this->argument('from');
        $to = $this->argument('to');
        $salonId = $this->option('salon');
        $format = $this->option('format');

        // Validate date format
        try {
            $fromDate = Carbon::parse($from);
            $toDate = Carbon::parse($to);
        } catch (\Exception $e) {
            $this->error('Invalid date format. Use YYYY-MM-DD format.');
            return 1;
        }

        $query = Invoice::whereBetween('created_at', [$fromDate, $toDate])
            ->where('status', 'paid')
            ->with(['items', 'customer', 'salon']);

        if ($salonId) {
            $query->where('salon_id', $salonId);
        }

        $invoices = $query->orderBy('created_at')->get();

        if ($invoices->isEmpty()) {
            $this->info('No paid invoices found for the specified date range.');
            return 0;
        }

        $this->info("Found {$invoices->count()} paid invoices for export.");

        if ($format === 'csv') {
            $this->exportCsv($invoices, $fromDate, $toDate);
        } else {
            $this->error('Only CSV format is currently supported.');
            return 1;
        }

        return 0;
    }

    private function exportCsv($invoices, Carbon $fromDate, Carbon $toDate)
    {
        $filename = "datev_export_{$fromDate->format('Y-m-d')}_{$toDate->format('Y-m-d')}.csv";
        $filepath = storage_path("app/exports/{$filename}");

        // Ensure directory exists
        if (!file_exists(dirname($filepath))) {
            mkdir(dirname($filepath), 0755, true);
        }

        $file = fopen($filepath, 'w');

        // Write CSV header
        fputcsv($file, [
            'Rechnungsnummer',
            'Datum',
            'Kunde',
            'Nettobetrag',
            'Steuersatz',
            'Steuerbetrag',
            'Bruttobetrag',
            'Zahlungsmethode',
            'Zahlungsanbieter',
            'Status',
            'Salon',
        ]);

        $totalNet = 0;
        $totalTax = 0;
        $totalGross = 0;

        foreach ($invoices as $invoice) {
            $customerName = $invoice->customer ? $invoice->customer->name : 'Walk-in';
            $salonName = $invoice->salon ? $invoice->salon->name : 'Unknown';
            
            // Get payment method from first payment
            $paymentMethod = 'Unknown';
            $paymentProvider = $invoice->payment_provider ?? 'Unknown';
            
            if ($invoice->payments->isNotEmpty()) {
                $paymentMethod = $invoice->payments->first()->method ?? 'Unknown';
            }

            fputcsv($file, [
                $invoice->number,
                $invoice->created_at->format('Y-m-d'),
                $customerName,
                number_format($invoice->total_net, 2, ',', '.'),
                '19%', // Default tax rate for DATEV
                number_format($invoice->total_tax, 2, ',', '.'),
                number_format($invoice->total_gross, 2, ',', '.'),
                $paymentMethod,
                $paymentProvider,
                $invoice->status,
                $salonName,
            ]);

            $totalNet += $invoice->total_net;
            $totalTax += $invoice->total_tax;
            $totalGross += $invoice->total_gross;
        }

        // Write summary line
        fputcsv($file, [
            'SUMME',
            '',
            '',
            number_format($totalNet, 2, ',', '.'),
            '',
            number_format($totalTax, 2, ',', '.'),
            number_format($totalGross, 2, ',', '.'),
            '',
            '',
            '',
            '',
        ]);

        fclose($file);

        $this->info("DATEV export completed: {$filepath}");
        $this->table(
            ['Total Net', 'Total Tax', 'Total Gross', 'Invoices'],
            [[
                number_format($totalNet, 2, ',', '.') . ' €',
                number_format($totalTax, 2, ',', '.') . ' €',
                number_format($totalGross, 2, ',', '.') . ' €',
                $invoices->count(),
            ]]
        );
    }
}
