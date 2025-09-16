<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Booking Confirmed</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #f8f9fa; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
        .content { background: #fff; padding: 30px; border: 1px solid #e9ecef; }
        .footer { background: #f8f9fa; padding: 20px; text-align: center; border-radius: 0 0 8px 8px; font-size: 14px; color: #6c757d; }
        .booking-details { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .service-item { padding: 10px 0; border-bottom: 1px solid #e9ecef; }
        .service-item:last-child { border-bottom: none; }
        .btn { display: inline-block; padding: 12px 24px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Booking Confirmed!</h1>
            <p>Your appointment has been successfully confirmed.</p>
        </div>
        
        <div class="content">
            <p>Hello {{ $user->profile->first_name ?? $user->name }},</p>
            
            <p>We're excited to confirm your upcoming appointment with us!</p>
            
            <div class="booking-details">
                <h3>Appointment Details</h3>
                <p><strong>Date:</strong> {{ $booking->date->format('l, F j, Y') }}</p>
                <p><strong>Time:</strong> {{ $booking->time }}</p>
                <p><strong>Staff:</strong> {{ $staff->name ?? 'TBD' }}</p>
                <p><strong>Total:</strong> ${{ number_format($booking->total, 2) }}</p>
                
                @if($services && $services->count() > 0)
                    <h4>Services:</h4>
                    @foreach($services as $service)
                        <div class="service-item">
                            <strong>{{ $service->name }}</strong>
                            <br>
                            Duration: {{ $service->duration }} minutes
                            <br>
                            Price: ${{ number_format($service->price, 2) }}
                        </div>
                    @endforeach
                @endif
                
                @if($booking->notes)
                    <h4>Notes:</h4>
                    <p>{{ $booking->notes }}</p>
                @endif
            </div>
            
            <p>If you need to reschedule or cancel your appointment, please contact us at least 24 hours in advance.</p>
            
            <p>We look forward to seeing you!</p>
            
            <p>Best regards,<br>
            The {{ config('app.name') }} Team</p>
        </div>
        
        <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>© {{ date('Y') }} {{ config('app.name') }}. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
