<?php

namespace App\Http\Controllers;

use App\Models\GdprRequest;
use App\Models\User;
use App\Events\Audit\Generic;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class GdprController extends Controller
{
    /**
     * Request data export
     * POST /gdpr/export
     */
    public function requestExport(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $gdprRequest = GdprRequest::create([
            'salon_id' => app('tenant')->id,
            'user_id' => $user->id,
            'type' => 'export',
            'status' => 'done',
            'payload' => $this->collectData($user),
        ]);

        event(new Generic('gdpr.export', 'User', $user->id, []));

        return response()->json(['file' => $gdprRequest->payload]);
    }

    /**
     * Request account deletion
     * POST /gdpr/delete
     */
    public function requestDelete(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $gdprRequest = GdprRequest::create([
            'salon_id' => app('tenant')->id,
            'user_id' => $user->id,
            'type' => 'delete',
            'status' => 'pending',
        ]);

        event(new Generic('gdpr.delete.request', 'User', $user->id, []));

        return response()->json([
            'ok' => true,
            'status' => 'pending',
            'message' => 'Ihr Löschantrag wurde eingereicht und wird bearbeitet.'
        ]);
    }

    /**
     * Confirm deletion request (Admin only)
     * POST /gdpr/delete/{gdpr}/confirm
     */
    public function confirmDelete(GdprRequest $gdprRequest): JsonResponse
    {
        if ($gdprRequest->type !== 'delete' || $gdprRequest->status !== 'pending') {
            abort(400, 'Invalid request type or status');
        }

        $user = $gdprRequest->user;
        
        // Anonymize instead of hard delete (due to tax/invoice obligations)
        $user->update([
            'name' => '[deleted]',
            'email' => null,
            'phone' => null,
            'email_verified_at' => null,
            'remember_token' => null,
        ]);

        $gdprRequest->update(['status' => 'done']);

        event(new Generic('gdpr.delete.confirm', 'User', $user->id, [
            'gdpr_request_id' => $gdprRequest->id
        ]));

        return response()->json([
            'ok' => true,
            'message' => 'User data has been anonymized'
        ]);
    }

    /**
     * Collect all user data for export
     */
    private function collectData(User $user): array
    {
        return [
            'export_date' => now()->toIso8601String(),
            'profile' => $user->only([
                'id',
                'name',
                'email',
                'phone',
                'created_at',
                'updated_at'
            ]),
            'bookings' => $user->bookings()
                ->with(['service', 'employee'])
                ->get()
                ->map(function ($booking) {
                    return [
                        'id' => $booking->id,
                        'service' => $booking->service?->name,
                        'employee' => $booking->employee?->name,
                        'date' => $booking->date,
                        'start_time' => $booking->start_time,
                        'end_time' => $booking->end_time,
                        'status' => $booking->status,
                        'price' => $booking->price,
                        'created_at' => $booking->created_at,
                    ];
                })->toArray(),
            'invoices' => $user->invoices()
                ->get()
                ->map(function ($invoice) {
                    return [
                        'id' => $invoice->id,
                        'invoice_number' => $invoice->invoice_number,
                        'amount' => $invoice->amount,
                        'status' => $invoice->status,
                        'created_at' => $invoice->created_at,
                    ];
                })->toArray(),
            'reviews' => $user->reviews()
                ->get()
                ->map(function ($review) {
                    return [
                        'id' => $review->id,
                        'rating' => $review->rating,
                        'comment' => $review->comment,
                        'service_id' => $review->service_id,
                        'employee_id' => $review->employee_id,
                        'created_at' => $review->created_at,
                    ];
                })->toArray(),
            'loyalty_cards' => $user->loyaltyCards()
                ->get()
                ->map(function ($card) {
                    return [
                        'id' => $card->id,
                        'card_number' => $card->card_number,
                        'points' => $card->points,
                        'status' => $card->status,
                        'created_at' => $card->created_at,
                    ];
                })->toArray(),
        ];
    }
}