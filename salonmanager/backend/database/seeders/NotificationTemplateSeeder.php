<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\NotificationTemplate;

class NotificationTemplateSeeder extends Seeder
{
    public function run(): void
    {
        // Global default templates (salon_id = null)
        $templates = [
            // Booking confirmed
            [
                'salon_id' => null,
                'event' => 'booking.confirmed',
                'channel' => 'mail',
                'locale' => 'de',
                'subject' => 'Buchungsbestätigung - {{salon.name}}',
                'body_markdown' => <<<MD
# Buchung bestätigt! 🎉

Hallo {{user.name}},

Ihre Buchung wurde bestätigt:

**Service:** {{booking.service}}  
**Datum:** {{booking.start}}  
**Salon:** {{salon.name}}

Wir freuen uns auf Ihren Besuch!

Mit freundlichen Grüßen  
Ihr {{salon.name}} Team
MD,
                'active' => true,
            ],
            [
                'salon_id' => null,
                'event' => 'booking.confirmed',
                'channel' => 'sms',
                'locale' => 'de',
                'body_markdown' => 'Buchung bestätigt! {{booking.service}} am {{booking.start}} bei {{salon.name}}. Wir freuen uns auf Sie!',
                'active' => true,
            ],
            // Booking declined
            [
                'salon_id' => null,
                'event' => 'booking.declined',
                'channel' => 'mail',
                'locale' => 'de',
                'subject' => 'Buchung leider nicht möglich - {{salon.name}}',
                'body_markdown' => <<<MD
# Buchung nicht möglich

Hallo {{user.name}},

leider können wir Ihre Buchung für {{booking.service}} am {{booking.start}} nicht bestätigen.

Bitte wählen Sie einen anderen Termin oder kontaktieren Sie uns direkt.

Mit freundlichen Grüßen  
Ihr {{salon.name}} Team
MD,
                'active' => true,
            ],
            // Invoice paid
            [
                'salon_id' => null,
                'event' => 'pos.invoice.paid',
                'channel' => 'mail',
                'locale' => 'de',
                'subject' => 'Rechnung {{invoice.number}} - {{salon.name}}',
                'body_markdown' => <<<MD
# Rechnung bezahlt

Hallo {{user.name}},

vielen Dank für Ihre Zahlung!

**Rechnung:** {{invoice.number}}  
**Betrag:** {{invoice.total}} €  
**Salon:** {{salon.name}}

Ihre Rechnung wurde erfolgreich bezahlt.

Mit freundlichen Grüßen  
Ihr {{salon.name}} Team
MD,
                'active' => true,
            ],
            // Media consent requested
            [
                'salon_id' => null,
                'event' => 'media.consent.requested',
                'channel' => 'mail',
                'locale' => 'de',
                'subject' => 'Einverständniserklärung für Medien - {{salon.name}}',
                'body_markdown' => <<<MD
# Einverständniserklärung erforderlich

Hallo {{user.name}},

wir benötigen Ihr Einverständnis für die Verwendung von Medien (Fotos/Videos) von Ihrem Besuch.

**Datei:** {{file.path}}

Bitte bestätigen Sie Ihre Zustimmung in der App oder kontaktieren Sie uns direkt.

Mit freundlichen Grüßen  
Ihr {{salon.name}} Team
MD,
                'active' => true,
            ],
        ];

        foreach ($templates as $template) {
            NotificationTemplate::updateOrCreate(
                [
                    'salon_id' => $template['salon_id'],
                    'event' => $template['event'],
                    'channel' => $template['channel'],
                    'locale' => $template['locale'],
                ],
                $template
            );
        }
    }
}