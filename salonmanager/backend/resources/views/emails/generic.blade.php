@component('mail::message')
# {{ $subject }}

@component('mail::panel')
{!! \Illuminate\Mail\Markdown::parse($markdown) !!}
@endcomponent

@slot('subcopy')
@component('mail::subcopy')
Diese E-Mail wurde automatisch von SalonManager gesendet.
@endcomponent
@endslot

@endcomponent