<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Salon;
use App\Models\Booking;
use App\Models\NotificationSetting;
use App\Models\NotificationTemplate;
use App\Services\Notify\Notifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Http;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_notification_preferences_api()
    {
        // Create test data
        $salon = Salon::factory()->create();
        $user = User::factory()->create(['current_salon_id' => $salon->id]);
        
        // Set tenant
        app()->instance('tenant', $salon);
        
        // Create notification setting
        NotificationSetting::create([
            'salon_id' => $salon->id,
            'user_id' => $user->id,
            'event' => 'booking.confirmed',
            'channel' => 'mail',
            'enabled' => true,
        ]);

        // Test GET /api/v1/notify/prefs
        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/notify/prefs');

        $response->assertStatus(200)
            ->assertJsonStructure(['items' => [
                '*' => ['id', 'salon_id', 'user_id', 'event', 'channel', 'enabled']
            ]]);

        // Test POST /api/v1/notify/prefs
        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/notify/prefs', [
                'items' => [
                    [
                        'event' => 'booking.confirmed',
                        'channel' => 'mail',
                        'enabled' => false,
                    ]
                ]
            ]);

        $response->assertStatus(200)
            ->assertJson(['ok' => true]);

        // Verify the setting was updated
        $this->assertDatabaseHas('notification_settings', [
            'user_id' => $user->id,
            'event' => 'booking.confirmed',
            'channel' => 'mail',
            'enabled' => false,
        ]);
    }

    public function test_template_renderer()
    {
        $template = 'Hello {{user.name}}, your booking for {{booking.service}} is confirmed.';
        $data = [
            'user' => ['name' => 'John Doe'],
            'booking' => ['service' => 'Haircut']
        ];

        $result = \App\Services\Notify\TemplateRenderer::render($template, $data);
        
        $this->assertEquals('Hello John Doe, your booking for Haircut is confirmed.', $result);
    }

    public function test_notifier_mail_channel()
    {
        Mail::fake();

        // Create test data
        $salon = Salon::factory()->create();
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'current_salon_id' => $salon->id
        ]);

        // Create template
        NotificationTemplate::create([
            'salon_id' => null,
            'event' => 'booking.confirmed',
            'channel' => 'mail',
            'locale' => 'de',
            'subject' => 'Booking Confirmed',
            'body_markdown' => 'Hello {{user.name}}, your booking is confirmed.',
            'active' => true,
        ]);

        // Set tenant
        app()->instance('tenant', $salon);

        // Send notification
        Notifier::send([
            'salon_id' => $salon->id,
            'event' => 'booking.confirmed',
            'user' => $user,
            'data' => [
                'user' => ['name' => $user->name],
                'booking' => ['service' => 'Haircut'],
                'salon' => ['name' => $salon->name]
            ],
            'ref' => ['type' => 'Booking', 'id' => 1]
        ]);

        // Assert email was sent
        Mail::assertSent(\Illuminate\Mail\Mailable::class, function ($mail) use ($user) {
            return $mail->hasTo($user->email);
        });
    }
}