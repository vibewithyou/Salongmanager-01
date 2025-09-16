<?php

return [
    // Booking emails
    'booking' => [
        'confirmed' => [
            'subject' => 'Buchungsbestätigung - :salon_name',
            'greeting' => 'Hallo :customer_name,',
            'intro' => 'vielen Dank für Ihre Buchung! Wir freuen uns, Sie in unserem Salon begrüßen zu dürfen.',
            'details_title' => 'Buchungsdetails',
            'service' => 'Service',
            'date' => 'Datum',
            'time' => 'Uhrzeit',
            'duration' => 'Dauer',
            'stylist' => 'Stylist',
            'price' => 'Preis',
            'notes' => 'Ihre Notizen',
            'expectations_title' => 'Was Sie erwartet',
            'expectations' => [
                'Professionelle Beratung und Service',
                'Hochwertige Produkte',
                'Entspannende Atmosphäre',
                'Individuelle Betreuung',
            ],
            'important_title' => 'Wichtige Hinweise',
            'important' => [
                'Bitte kommen Sie 5-10 Minuten vor Ihrem Termin',
                'Bei Verspätung von mehr als 15 Minuten behalten wir uns vor, den Termin zu stornieren',
                'Stornierungen sind bis 24 Stunden vor dem Termin kostenfrei möglich',
                'Bei Fragen stehen wir Ihnen gerne zur Verfügung',
            ],
            'reschedule_button' => 'Termin umbuchen',
            'closing' => 'Wir freuen uns auf Ihren Besuch!',
            'signature' => 'Mit freundlichen Grüßen',
        ],
        'cancelled' => [
            'subject' => 'Buchung storniert - :salon_name',
            'greeting' => 'Hallo :customer_name,',
            'intro' => 'Ihre Buchung wurde storniert.',
            'details_title' => 'Stornierungsdetails',
            'cancellation_reason' => 'Grund',
            'refund_info' => 'Rückerstattung',
            'rebook_button' => 'Neuen Termin buchen',
        ],
        'reminder' => [
            'subject' => 'Terminerinnerung - :salon_name',
            'greeting' => 'Hallo :customer_name,',
            'intro' => 'dies ist eine freundliche Erinnerung an Ihren bevorstehenden Termin.',
            'reminder_text' => 'Ihr Termin ist in :hours Stunden.',
        ],
    ],

    // Password reset
    'password_reset' => [
        'subject' => 'Passwort zurücksetzen - :salon_name',
        'greeting' => 'Hallo :user_name,',
        'intro' => 'Sie haben eine Anfrage zum Zurücksetzen Ihres Passworts gestellt.',
        'ignore_notice' => 'Falls Sie diese Anfrage nicht gestellt haben, können Sie diese E-Mail ignorieren.',
        'reset_button' => 'Passwort zurücksetzen',
        'link_validity' => 'Dieser Link ist nur 60 Minuten gültig.',
        'manual_link' => 'Falls der Button nicht funktioniert:',
        'security_title' => 'Sicherheitshinweise',
        'security_tips' => [
            'Verwenden Sie ein starkes Passwort mit mindestens 8 Zeichen',
            'Kombinieren Sie Groß- und Kleinbuchstaben, Zahlen und Sonderzeichen',
            'Verwenden Sie nicht dasselbe Passwort für mehrere Konten',
            'Teilen Sie Ihr Passwort niemals mit anderen',
        ],
    ],

    // Refund
    'refund' => [
        'issued' => [
            'subject' => 'Rückerstattung ausgestellt - :salon_name',
            'greeting' => 'Hallo :customer_name,',
            'intro' => 'wir haben Ihre Rückerstattung bearbeitet und ausgestellt.',
            'details_title' => 'Rückerstattungsdetails',
            'refund_number' => 'Rückerstattungsnummer',
            'original_amount' => 'Ursprünglicher Betrag',
            'refund_amount' => 'Rückerstattungsbetrag',
            'reason' => 'Grund',
            'date' => 'Datum',
            'original_booking' => 'Ursprünglicher Termin',
            'method_title' => 'Rückerstattungsmethode',
            'next_steps_title' => 'Nächste Schritte',
            'next_steps' => [
                'Die Rückerstattung wird innerhalb der angegebenen Frist bearbeitet',
                'Sie erhalten eine Bestätigung, sobald die Rückerstattung abgeschlossen ist',
                'Bei Fragen wenden Sie sich gerne an uns',
            ],
            'rebook_button' => 'Neuen Termin buchen',
            'closing' => 'Vielen Dank für Ihr Verständnis. Wir hoffen, Sie bald wieder in unserem Salon begrüßen zu dürfen!',
        ],
    ],

    // Staff notifications
    'staff' => [
        'shift_assigned' => [
            'subject' => 'Neue Schicht zugewiesen - :salon_name',
            'greeting' => 'Hallo :staff_name,',
            'intro' => 'Ihnen wurde eine neue Schicht zugewiesen.',
            'shift_details' => 'Schichtdetails',
            'date' => 'Datum',
            'start_time' => 'Startzeit',
            'end_time' => 'Endzeit',
            'location' => 'Standort',
        ],
        'shift_cancelled' => [
            'subject' => 'Schicht storniert - :salon_name',
            'greeting' => 'Hallo :staff_name,',
            'intro' => 'Ihre Schicht wurde storniert.',
        ],
    ],

    // Common
    'common' => [
        'contact' => 'Kontakt',
        'phone' => 'Telefon',
        'email' => 'E-Mail',
        'website' => 'Web',
        'support' => 'Support',
        'signature' => 'Mit freundlichen Grüßen',
        'team' => 'Ihr :salon_name Team',
        'footer' => [
            'privacy' => 'Datenschutz',
            'terms' => 'AGB',
            'imprint' => 'Impressum',
        ],
    ],

    // Email templates placeholders
    'placeholders' => [
        'salon_name' => 'SalonManager',
        'salon_tagline' => 'Beauty & Wellness',
        'salon_address' => 'Musterstraße 123, 12345 Musterstadt, Deutschland',
        'salon_phone' => '+49 123 456 789',
        'salon_email' => 'info@salonmanager.de',
        'salon_website' => 'https://salonmanager.de',
        'support_email' => 'support@salonmanager.de',
    ],
];
