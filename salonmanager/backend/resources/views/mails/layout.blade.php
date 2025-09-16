<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $subject ?? 'SalonManager' }}</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f5f5f5;
            color: #000000;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
        }
        .header {
            background-color: #000000;
            padding: 24px;
            text-align: center;
        }
        .logo {
            width: 48px;
            height: 48px;
            background-color: #FFD700;
            border-radius: 8px;
            margin: 0 auto 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #000000;
        }
        .salon-name {
            color: #FFD700;
            font-size: 24px;
            font-weight: bold;
            margin: 0;
        }
        .salon-tagline {
            color: #ffffff;
            font-size: 14px;
            margin: 4px 0 0;
            opacity: 0.8;
        }
        .divider {
            height: 2px;
            background: linear-gradient(90deg, #FFD700, #D4AF37);
            margin: 0;
        }
        .content {
            padding: 32px 24px;
            line-height: 1.6;
        }
        .footer {
            background-color: #000000;
            color: #ffffff;
            padding: 24px;
            text-align: center;
            font-size: 14px;
        }
        .footer a {
            color: #FFD700;
            text-decoration: none;
        }
        .footer a:hover {
            text-decoration: underline;
        }
        .button {
            display: inline-block;
            background-color: #FFD700;
            color: #000000;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            margin: 16px 0;
        }
        .button:hover {
            background-color: #D4AF37;
        }
        .highlight {
            background-color: #FFD700;
            color: #000000;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 600;
        }
        @media (max-width: 600px) {
            .container {
                margin: 0;
            }
            .content {
                padding: 24px 16px;
            }
            .header {
                padding: 20px 16px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">✂️</div>
            <h1 class="salon-name">{{ $salonName ?? 'SalonManager' }}</h1>
            <p class="salon-tagline">Beauty & Wellness</p>
        </div>
        <hr class="divider">
        
        <div class="content">
            @yield('content')
        </div>
        
        <div class="footer">
            <p><strong>{{ $salonName ?? 'SalonManager' }}</strong></p>
            <p>
                <!-- TODO: Replace with actual salon address -->
                Musterstraße 123<br>
                12345 Musterstadt<br>
                Deutschland
            </p>
            <p>
                Telefon: <a href="tel:+49123456789">+49 123 456 789</a><br>
                E-Mail: <a href="mailto:info@salonmanager.de">info@salonmanager.de</a><br>
                Web: <a href="https://salonmanager.de">salonmanager.de</a>
            </p>
            <hr style="border: none; border-top: 1px solid #333; margin: 16px 0;">
            <p style="font-size: 12px; opacity: 0.7;">
                <a href="{{ url('/datenschutz') }}">Datenschutz</a> | 
                <a href="{{ url('/agb') }}">AGB</a> | 
                <a href="{{ url('/impressum') }}">Impressum</a>
            </p>
        </div>
    </div>
</body>
</html>
