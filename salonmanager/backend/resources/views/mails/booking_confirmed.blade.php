@php($cs = config('app.name','SalonManager'))
<p>{{$cs}} – Buchung bestätigt</p>
<p>Hallo {{ $customerName ?? 'Kunde' }},</p>
<p>Dein Termin am {{ $startAt }} bei {{ $stylistName ?? 'Stylist' }} wurde bestätigt.</p>
<p>Salon: {{ $salonName }}</p>
<p>Viele Grüße</p>
