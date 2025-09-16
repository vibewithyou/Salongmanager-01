@extends('mails.layout')

@section('content')
<h2 style="color: #000000; margin-top: 0;">💰 Rückerstattung ausgestellt</h2>

<p>Hallo {{ $customerName ?? 'Liebe/r Kunde/in' }},</p>

<p>wir haben Ihre Rückerstattung bearbeitet und ausgestellt. Die Details finden Sie unten.</p>

<div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FFD700;">
    <h3 style="margin-top: 0; color: #000000;">Rückerstattungsdetails</h3>
    <p><strong>Rückerstattungsnummer:</strong> {{ $refundNumber ?? 'Nicht angegeben' }}</p>
    <p><strong>Ursprünglicher Betrag:</strong> {{ $originalAmount ?? 'Nicht angegeben' }}€</p>
    <p><strong>Rückerstattungsbetrag:</strong> <span class="highlight">{{ $refundAmount ?? 'Nicht angegeben' }}€</span></p>
    <p><strong>Grund:</strong> {{ $reason ?? 'Nicht angegeben' }}</p>
    <p><strong>Datum:</strong> {{ $refundDate ?? 'Nicht angegeben' }}</p>
    @if($originalBookingDate)
    <p><strong>Ursprünglicher Termin:</strong> {{ $originalBookingDate }}</p>
    @endif
</div>

@if($refundMethod)
<div style="background-color: #fff3cd; padding: 16px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FFD700;">
    <h4 style="margin-top: 0; color: #000000;">Rückerstattungsmethode</h4>
    <p style="margin-bottom: 0;">
        @if($refundMethod === 'card')
        Die Rückerstattung erfolgt auf die ursprünglich verwendete Kreditkarte. 
        Die Bearbeitung kann 3-5 Werktage dauern.
        @elseif($refundMethod === 'bank')
        Die Rückerstattung erfolgt per Banküberweisung auf das angegebene Konto.
        Die Bearbeitung kann 2-3 Werktage dauern.
        @else
        Die Rückerstattung erfolgt über {{ $refundMethod }}.
        @endif
    </p>
</div>
@endif

<h3>Nächste Schritte:</h3>
<ul>
    <li>Die Rückerstattung wird innerhalb der angegebenen Frist bearbeitet</li>
    <li>Sie erhalten eine Bestätigung, sobald die Rückerstattung abgeschlossen ist</li>
    <li>Bei Fragen wenden Sie sich gerne an uns</li>
</ul>

@if($rebookingUrl)
<div style="text-align: center; margin: 30px 0;">
    <a href="{{ $rebookingUrl }}" class="button">Neuen Termin buchen</a>
</div>
@endif

<p>Vielen Dank für Ihr Verständnis. Wir hoffen, Sie bald wieder in unserem Salon begrüßen zu dürfen!</p>

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
