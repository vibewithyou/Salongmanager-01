@extends('mails.layout')

@section('content')
<h2 style="color: #000000; margin-top: 0;">🎉 Buchung bestätigt!</h2>

<p>Hallo {{ $customerName ?? 'Liebe/r Kunde/in' }},</p>

<p>vielen Dank für Ihre Buchung! Wir freuen uns, Sie in unserem Salon begrüßen zu dürfen.</p>

<div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FFD700;">
    <h3 style="margin-top: 0; color: #000000;">Buchungsdetails</h3>
    <p><strong>Service:</strong> {{ $serviceName ?? 'Nicht angegeben' }}</p>
    <p><strong>Datum:</strong> {{ $bookingDate ?? 'Nicht angegeben' }}</p>
    <p><strong>Uhrzeit:</strong> {{ $bookingTime ?? 'Nicht angegeben' }}</p>
    <p><strong>Dauer:</strong> {{ $duration ?? 'Nicht angegeben' }}</p>
    <p><strong>Stylist:</strong> {{ $stylistName ?? 'Wird zugewiesen' }}</p>
    @if($price)
    <p><strong>Preis:</strong> <span class="highlight">{{ $price }}€</span></p>
    @endif
</div>

@if($notes)
<div style="background-color: #fff3cd; padding: 16px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FFD700;">
    <h4 style="margin-top: 0; color: #000000;">Ihre Notizen</h4>
    <p style="margin-bottom: 0;">{{ $notes }}</p>
</div>
@endif

<h3>Was Sie erwartet:</h3>
<ul>
    <li>Professionelle Beratung und Service</li>
    <li>Hochwertige Produkte</li>
    <li>Entspannende Atmosphäre</li>
    <li>Individuelle Betreuung</li>
</ul>

<h3>Wichtige Hinweise:</h3>
<ul>
    <li>Bitte kommen Sie 5-10 Minuten vor Ihrem Termin</li>
    <li>Bei Verspätung von mehr als 15 Minuten behalten wir uns vor, den Termin zu stornieren</li>
    <li>Stornierungen sind bis 24 Stunden vor dem Termin kostenfrei möglich</li>
    <li>Bei Fragen stehen wir Ihnen gerne zur Verfügung</li>
</ul>

@if($rescheduleUrl)
<div style="text-align: center; margin: 30px 0;">
    <a href="{{ $rescheduleUrl }}" class="button">Termin umbuchen</a>
</div>
@endif

<p>Wir freuen uns auf Ihren Besuch!</p>

<p>Mit freundlichen Grüßen<br>
<strong>Ihr {{ $salonName ?? 'SalonManager' }} Team</strong></p>

@if($contactInfo)
<div style="background-color: #f8f9fa; padding: 16px; border-radius: 8px; margin: 20px 0; text-align: center;">
    <p style="margin: 0;"><strong>Kontakt:</strong><br>
    Telefon: <a href="tel:{{ $phone ?? '+49123456789' }}">{{ $phone ?? '+49 123 456 789' }}</a><br>
    E-Mail: <a href="mailto:{{ $email ?? 'info@salonmanager.de' }}">{{ $email ?? 'info@salonmanager.de' }}</a></p>
</div>
@endif
@endsection