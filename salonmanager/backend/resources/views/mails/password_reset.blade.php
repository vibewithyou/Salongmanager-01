@extends('mails.layout')

@section('content')
<h2 style="color: #000000; margin-top: 0;">🔐 Passwort zurücksetzen</h2>

<p>Hallo {{ $userName ?? 'Liebe/r Nutzer/in' }},</p>

<p>Sie haben eine Anfrage zum Zurücksetzen Ihres Passworts gestellt. Falls Sie diese Anfrage nicht gestellt haben, können Sie diese E-Mail ignorieren.</p>

<div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FFD700;">
    <h3 style="margin-top: 0; color: #000000;">Passwort zurücksetzen</h3>
    <p>Klicken Sie auf den folgenden Button, um ein neues Passwort zu erstellen:</p>
    
    <div style="text-align: center; margin: 20px 0;">
        <a href="{{ $resetUrl ?? '#' }}" class="button">Passwort zurücksetzen</a>
    </div>
    
    <p style="font-size: 14px; color: #666; margin-bottom: 0;">
        <strong>Hinweis:</strong> Dieser Link ist nur 60 Minuten gültig.
    </p>
</div>

@if($resetUrl)
<div style="background-color: #fff3cd; padding: 16px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #FFD700;">
    <h4 style="margin-top: 0; color: #000000;">Falls der Button nicht funktioniert:</h4>
    <p style="margin-bottom: 0; word-break: break-all;">
        Kopieren Sie diesen Link in Ihren Browser:<br>
        <a href="{{ $resetUrl }}">{{ $resetUrl }}</a>
    </p>
</div>
@endif

<h3>Sicherheitshinweise:</h3>
<ul>
    <li>Verwenden Sie ein starkes Passwort mit mindestens 8 Zeichen</li>
    <li>Kombinieren Sie Groß- und Kleinbuchstaben, Zahlen und Sonderzeichen</li>
    <li>Verwenden Sie nicht dasselbe Passwort für mehrere Konten</li>
    <li>Teilen Sie Ihr Passwort niemals mit anderen</li>
</ul>

<p>Falls Sie Probleme beim Zurücksetzen haben oder weitere Fragen haben, kontaktieren Sie uns gerne.</p>

<p>Mit freundlichen Grüßen<br>
<strong>Ihr {{ $salonName ?? 'SalonManager' }} Team</strong></p>

<div style="background-color: #f8f9fa; padding: 16px; border-radius: 8px; margin: 20px 0; text-align: center;">
    <p style="margin: 0; font-size: 14px; color: #666;">
        <strong>Support:</strong><br>
        Telefon: <a href="tel:{{ $phone ?? '+49123456789' }}">{{ $phone ?? '+49 123 456 789' }}</a><br>
        E-Mail: <a href="mailto:{{ $email ?? 'support@salonmanager.de' }}">{{ $email ?? 'support@salonmanager.de' }}</a>
    </p>
</div>
@endsection
