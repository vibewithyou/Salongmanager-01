<?php

namespace App\Services\Invoicing;

class Totals
{
    public static function compute(array $lines): array
    {
        // line: ['qty','unit_net','tax_rate','discount'=>% or amount (optional)]
        $taxMap = [];
        $totalNet = 0;
        $totalTax = 0;
        $totalGross = 0;
        
        foreach ($lines as &$l) {
            $qty = (int) $l['qty'];
            $unit = (float) $l['unit_net'];
            $rate = (float) $l['tax_rate'];
            $lineNet = $qty * $unit;
            
            if (isset($l['discount'])) {
                $d = $l['discount'];
                if (is_array($d) && isset($d['percent'])) {
                    $lineNet -= $lineNet * ($d['percent'] / 100);
                } else {
                    $lineNet -= (float) $d;
                }
                $lineNet = max(0, round($lineNet, 2));
            }
            
            $lineTax = round($lineNet * $rate / 100, 2);
            $lineGross = round($lineNet + $lineTax, 2);

            $l['line_net'] = $lineNet;
            $l['line_tax'] = $lineTax;
            $l['line_gross'] = $lineGross;

            $totalNet += $lineNet;
            $totalTax += $lineTax;
            $totalGross += $lineGross;
            
            $key = number_format($rate, 2, '.', '');
            $taxMap[$key] = ($taxMap[$key] ?? 0) + $lineTax;
        }
        
        $breakdown = [];
        foreach ($taxMap as $rate => $tax) {
            $r = (float) $rate;
            $net = round($tax * 100 / $r, 2);
            $breakdown[] = ['rate' => $r, 'net' => $net, 'tax' => round($tax, 2)];
        }
        
        return [
            'lines' => $lines,
            'total_net' => round($totalNet, 2),
            'total_tax' => round($totalTax, 2),
            'total_gross' => round($totalGross, 2),
            'tax_breakdown' => $breakdown,
        ];
    }
}