<?php
namespace App\Support\Logging;

class RedactPiiProcessor {
  public function __invoke(array $record): array {
    $msg = (string)($record['message'] ?? '');
    $msg = preg_replace('/[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}/i','[redacted-email]',$msg);
    $msg = preg_replace('/\\b(\\+?\\d[\\d\\s\\-()]{6,})\\b/','[redacted-phone]',$msg);
    $record['message'] = $msg;
    return $record;
  }
}
