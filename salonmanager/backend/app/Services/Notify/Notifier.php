<?php
namespace App\Services\Notify;

use App\Models\{NotificationTemplate, NotificationSetting, NotificationLog, Webhook, User, Salon};
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Http;

class Notifier {

  /** Hauptmethode: schickt an 1 User + optional Webhooks */
  public static function send(array $opts): void {
    // $opts: ['salon_id','event','user'=>User|null,'channel'=>'mail|sms|webhook|auto','data'=>[], 'ref'=>['type'=>..,'id'=>..]]
    $salonId = $opts['salon_id']; $event = $opts['event']; $user = $opts['user'] ?? null;
    $data = $opts['data'] ?? []; $channel = $opts['channel'] ?? 'auto';
    $ref = $opts['ref'] ?? null;

    // channels to try
    $channels = $channel === 'auto' ? ['mail','sms'] : [$channel];

    foreach ($channels as $ch) {
      $ok = self::sendChannel($salonId, $event, $ch, $user, $data, $ref);
      if ($ok) break; // first success wins in auto
    }

    // admin-level salon webhooks (fan-out)
    self::fanoutWebhooks($salonId, $event, $data, $ref);
  }

  protected static function sendChannel(int $salonId, string $event, string $channel, ?User $user, array $data, ?array $ref): bool {
    // user pref
    if ($user) {
      $pref = NotificationSetting::where(compact('salonId'))->where('user_id',$user->id)->where('event',$event)->where('channel',$channel)->first();
      if ($pref && !$pref->enabled) {
        self::log($salonId,$user?->id,$event,$channel,'skipped', 'pref disabled', $ref, ['data'=>$data]);
        return false;
      }
    }

    // template resolve (salon override -> global)
    $tpl = NotificationTemplate::where('salon_id',$salonId)->where('event',$event)->where('channel',$channel)->first()
        ?? NotificationTemplate::whereNull('salon_id')->where('event',$event)->where('channel',$channel)->first();

    try {
      switch ($channel) {
        case 'mail':
          if (!$user || !$user->email) return false;
          $subject = $tpl?->subject ? TemplateRenderer::render($tpl->subject, $data) : "[SalonManager] $event";
          $bodyMd  = $tpl?->body_markdown ?? self::defaultMd($event);
          $body    = TemplateRenderer::render($bodyMd, $data);
          Mail::send('emails.generic', ['subject'=>$subject,'markdown'=>$body], function($m) use ($user,$subject){ $m->to($user->email)->subject($subject); });
          self::log($salonId,$user->id,$event,'mail','sent', null, $ref, ['subject'=>$subject]);
          return true;

        case 'sms': // stub
          if (!$user || !$user->phone) return false;
          $text = $tpl?->body_markdown ? TemplateRenderer::render($tpl->body_markdown, $data) : "Event: $event";
          // TODO: integrate real provider; currently just log 'sent'
          self::log($salonId,$user->id,$event,'sms','sent', null, $ref, ['text'=>$text]);
          return true;

        case 'webhook':
          // per-user webhook (rare); prefer salon webhooks in fanout()
          $payload = $tpl?->webhook_json ? json_decode(TemplateRenderer::render($tpl->webhook_json,$data), true) : ['event'=>$event,'data'=>$data];
          $url = $user?->meta['webhook_url'] ?? null; // requires user.meta json col
          if (!$url) return false;
          $res = Http::withHeaders(['User-Agent'=>'SalonManager/Notify'])->post($url, $payload);
          $status = $res->successful() ? 'sent' : 'failed';
          self::log($salonId,$user?->id,$event,'webhook',$status, $res->body(), $ref, $payload);
          return $res->successful();
      }
    } catch (\Throwable $e) {
      self::log($salonId,$user?->id,$event,$channel,'failed', $e->getMessage(), $ref, ['data'=>$data]);
      return false;
    }
    return false;
  }

  protected static function fanoutWebhooks(int $salonId, string $event, array $data, ?array $ref): void {
    $hooks = Webhook::where('salon_id',$salonId)->where('event',$event)->where('active',true)->get();
    foreach ($hooks as $h) {
      try {
        $payload = ['event'=>$event,'data'=>$data,'ref'=>$ref,'ts'=>now()->toIso8601String()];
        $req = Http::withHeaders(array_merge(['User-Agent'=>'SalonManager/Webhook'], $h->headers ?? []));
        if ($h->secret) {
          $sig = hash_hmac('sha256', json_encode($payload), $h->secret);
          $req = $req->withHeaders(['X-Webhook-Signature'=>$sig]);
        }
        $res = $req->post($h->url, $payload);
        NotificationLog::create([
          'salon_id'=>$salonId,'user_id'=>null,'event'=>$event,'channel'=>'webhook',
          'status'=>$res->successful()?'sent':'failed','ref_type'=>$ref['type']??null,'ref_id'=>$ref['id']??null,
          'target'=>$h->url,'error'=>$res->successful()?null:$res->body(),'payload'=>$payload
        ]);
      } catch (\Throwable $e) {
        NotificationLog::create(['salon_id'=>$salonId,'event'=>$event,'channel'=>'webhook','status'=>'failed','error'=>$e->getMessage()]);
      }
    }
  }

  protected static function defaultMd(string $event): string {
    return <<<MD
# Benachrichtigung: {{$event}}
Hallo {{user.name}},
es gab ein Ereignis in deinem Salon: **{{$event}}**.
MD;
  }

  protected static function log(int $salonId, ?int $userId, string $event, string $channel, string $status, ?string $error, ?array $ref, ?array $payload): void {
    \App\Models\NotificationLog::create([
      'salon_id'=>$salonId,'user_id'=>$userId,'event'=>$event,'channel'=>$channel,'status'=>$status,
      'ref_type'=>$ref['type']??null,'ref_id'=>$ref['id']??null,'target'=>null,'error'=>$error,'payload'=>$payload
    ]);
  }
}