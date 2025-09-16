<?php

namespace App\Policies;

use App\Models\Booking;
use App\Models\User;

class BookingPolicy
{
    /**
     * Determine whether the user can view any bookings.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist', 'customer']);
    }

    /**
     * Determine whether the user can view the booking.
     */
    public function view(User $user, Booking $booking): bool
    {
        // Customer can view own bookings
        if ($user->hasRole('customer') && $booking->customer_id === $user->id) {
            return true;
        }

        // Stylist can view assigned bookings
        if ($user->hasRole('stylist') && $booking->stylist_id === $user->stylist?->id) {
            return true;
        }

        // Salon owner/manager can view all bookings in their salon
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return $booking->salon_id === $user->current_salon_id;
        }

        return false;
    }

    /**
     * Determine whether the user can create bookings.
     */
    public function create(User $user): bool
    {
        return $user->hasRole('customer');
    }

    /**
     * Determine whether the user can update the booking.
     */
    public function update(User $user, Booking $booking): bool
    {
        // Customer can update own pending bookings
        if ($user->hasRole('customer') && 
            $booking->customer_id === $user->id && 
            $booking->status === Booking::STATUS_PENDING) {
            return true;
        }

        // Salon owner/manager can update any booking in their salon
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return $booking->salon_id === $user->current_salon_id;
        }

        return false;
    }

    /**
     * Determine whether the user can delete the booking.
     */
    public function delete(User $user, Booking $booking): bool
    {
        // Only salon owner/manager can delete bookings
        return $user->hasAnyRole(['salon_owner', 'salon_manager']) && 
               $booking->salon_id === $user->current_salon_id;
    }

    /**
     * Determine whether the user can confirm the booking.
     */
    public function confirm(User $user, Booking $booking): bool
    {
        // Stylist can confirm assigned bookings
        if ($user->hasRole('stylist') && $booking->stylist_id === $user->stylist?->id) {
            return true;
        }

        // Salon owner/manager can confirm any booking in their salon
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return $booking->salon_id === $user->current_salon_id;
        }

        return false;
    }

    /**
     * Determine whether the user can decline the booking.
     */
    public function decline(User $user, Booking $booking): bool
    {
        // Stylist can decline assigned bookings
        if ($user->hasRole('stylist') && $booking->stylist_id === $user->stylist?->id) {
            return true;
        }

        // Salon owner/manager can decline any booking in their salon
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return $booking->salon_id === $user->current_salon_id;
        }

        return false;
    }

    /**
     * Determine whether the user can cancel the booking.
     */
    public function cancel(User $user, Booking $booking): bool
    {
        // Customer can cancel own bookings
        if ($user->hasRole('customer') && $booking->customer_id === $user->id) {
            return true;
        }

        // Stylist can cancel bookings assigned to them
        if ($user->hasRole('stylist') && $booking->stylist_id === $user->id) {
            return true;
        }

        // Salon owner/manager can cancel any booking in their salon
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return $booking->salon_id === $user->current_salon_id;
        }

        return false;
    }

    /**
     * Determine whether the user can modify the booking (confirm/decline).
     */
    public function modify(User $user, Booking $booking): bool
    {
        // Stylist can only modify their own bookings
        if ($user->hasRole('stylist') && $booking->stylist_id === $user->id) {
            return true;
        }

        // Salon owner/manager can modify any booking in their salon
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return $booking->salon_id === $user->current_salon_id;
        }

        return false;
    }
}