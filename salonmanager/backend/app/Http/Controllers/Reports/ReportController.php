<?php

namespace App\Http\Controllers\Reports;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use League\Csv\Writer;

class ReportController extends Controller
{
    public function revenue(Request $request)
    {
        $salon = app('tenant');
        $from = Carbon::parse($request->get('from'));
        $to = Carbon::parse($request->get('to'));
        
        $data = Invoice::where('salon_id', $salon->id)
            ->whereBetween('issued_at', [$from, $to])
            ->selectRaw('DATE(issued_at) as day, SUM(total_gross) as revenue')
            ->groupBy('day')
            ->orderBy('day')
            ->get();
            
        return response()->json($data);
    }

    public function topServices(Request $request)
    {
        $salon = app('tenant');
        $from = Carbon::parse($request->get('from'));
        $to = Carbon::parse($request->get('to'));
        
        $data = DB::table('booking_services')
            ->join('bookings', 'booking_services.booking_id', '=', 'bookings.id')
            ->join('services', 'booking_services.service_id', '=', 'services.id')
            ->where('bookings.salon_id', $salon->id)
            ->whereBetween('bookings.start_at', [$from, $to])
            ->where('bookings.status', 'confirmed')
            ->select('services.name', DB::raw('COUNT(*) as cnt'), DB::raw('SUM(booking_services.price) as total_revenue'))
            ->groupBy('services.name')
            ->orderByDesc('cnt')
            ->limit(10)
            ->get();
            
        return response()->json($data);
    }

    public function topStylists(Request $request)
    {
        $salon = app('tenant');
        $from = Carbon::parse($request->get('from'));
        $to = Carbon::parse($request->get('to'));
        
        $data = DB::table('booking_services')
            ->join('bookings', 'booking_services.booking_id', '=', 'bookings.id')
            ->join('stylists', 'booking_services.stylist_id', '=', 'stylists.id')
            ->where('bookings.salon_id', $salon->id)
            ->whereBetween('bookings.start_at', [$from, $to])
            ->where('bookings.status', 'confirmed')
            ->select('stylists.name', DB::raw('COUNT(*) as cnt'), DB::raw('SUM(booking_services.price) as total_revenue'))
            ->groupBy('stylists.name')
            ->orderByDesc('cnt')
            ->limit(10)
            ->get();
            
        return response()->json($data);
    }

    public function occupancy(Request $request)
    {
        $salon = app('tenant');
        $from = Carbon::parse($request->get('from'));
        $to = Carbon::parse($request->get('to'));
        
        // Get total available hours vs booked hours
        $data = DB::table('shifts')
            ->leftJoin('booking_services', function($join) use ($from, $to) {
                $join->on('shifts.stylist_id', '=', 'booking_services.stylist_id')
                     ->whereBetween('booking_services.created_at', [$from, $to]);
            })
            ->where('shifts.salon_id', $salon->id)
            ->whereBetween('shifts.start_at', [$from, $to])
            ->selectRaw('DATE(shifts.start_at) as day, 
                        SUM(TIMESTAMPDIFF(MINUTE, shifts.start_at, shifts.end_at)) as total_minutes,
                        SUM(COALESCE(booking_services.duration, 0)) as booked_minutes')
            ->groupBy('day')
            ->orderBy('day')
            ->get();
            
        // Calculate occupancy percentage
        $data = $data->map(function($item) {
            $occupancy = $item->total_minutes > 0 ? ($item->booked_minutes / $item->total_minutes) * 100 : 0;
            return [
                'day' => $item->day,
                'total_minutes' => $item->total_minutes,
                'booked_minutes' => $item->booked_minutes,
                'occupancy_percentage' => round($occupancy, 2)
            ];
        });
            
        return response()->json($data);
    }

    public function exportCsv(Request $request)
    {
        $type = $request->get('type'); // revenue, topServices, topStylists, occupancy
        $from = $request->get('from');
        $to = $request->get('to');
        
        // Create a new request with the same parameters for the specific method
        $methodRequest = new Request(['from' => $from, 'to' => $to]);
        
        $rows = [];
        switch ($type) {
            case 'revenue':
                $rows = $this->revenue($methodRequest)->getData(true);
                break;
            case 'topServices':
                $rows = $this->topServices($methodRequest)->getData(true);
                break;
            case 'topStylists':
                $rows = $this->topStylists($methodRequest)->getData(true);
                break;
            case 'occupancy':
                $rows = $this->occupancy($methodRequest)->getData(true);
                break;
            default:
                return response()->json(['error' => 'Invalid report type'], 400);
        }
        
        if (empty($rows)) {
            return response()->json(['error' => 'No data found'], 404);
        }
        
        $csv = Writer::createFromString('');
        $csv->insertOne(array_keys($rows[0] ?? []));
        foreach ($rows as $row) {
            $csv->insertOne((array) $row);
        }
        
        return response($csv->toString(), 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="report_' . $type . '_' . $from . '_to_' . $to . '.csv"'
        ]);
    }
}