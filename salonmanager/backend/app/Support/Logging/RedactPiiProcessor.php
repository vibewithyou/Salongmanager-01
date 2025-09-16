<?php
namespace App\Support\Logging;

class RedactPiiProcessor {
  public function __invoke(array $record): array {
    $msg = (string)($record['message'] ?? '');
    
    // Enhanced PII redaction patterns
    $patterns = [
      // Email addresses
      '/[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}/i' => '[redacted-email]',
      
      // Phone numbers
      '/\\b(\\+?\\d[\\d\\s\\-()]{6,})\\b/' => '[redacted-phone]',
      
      // Authorization headers
      '/Authorization:\\s*[^\\s]+/i' => 'Authorization: [redacted]',
      '/Bearer\\s+[^\\s]+/i' => 'Bearer [redacted]',
      '/X-XSRF-TOKEN:\\s*[^\\s]+/i' => 'X-XSRF-TOKEN: [redacted]',
      '/Stripe-Signature:\\s*[^\\s]+/i' => 'Stripe-Signature: [redacted]',
      
      // API keys and tokens
      '/[Aa]pi[_-]?[Kk]ey["\\s]*[:=]["\\s]*[A-Za-z0-9_-]+/i' => 'api_key: [redacted]',
      '/[Aa]ccess[_-]?[Tt]oken["\\s]*[:=]["\\s]*[A-Za-z0-9_-]+/i' => 'access_token: [redacted]',
      
      // Database credentials
      '/DB_PASSWORD["\\s]*[:=]["\\s]*[^\\s]+/i' => 'DB_PASSWORD: [redacted]',
      
      // Credit card numbers
      '/\\b(?:\\d{4}[\\-\\s]?){3}\\d{4}\\b/' => '[redacted-card]',
      
      // SSN
      '/\\b\\d{3}-\\d{2}-\\d{4}\\b/' => '[redacted-ssn]',
    ];
    
    foreach ($patterns as $pattern => $replacement) {
      $msg = preg_replace($pattern, $replacement, $msg);
    }
    
    $record['message'] = $msg;
    
    // Also redact context if it exists
    if (isset($record['context']) && is_array($record['context'])) {
      $record['context'] = $this->redactContext($record['context']);
    }
    
    return $record;
  }
  
  private function redactContext(array $context): array {
    $redacted = [];
    
    foreach ($context as $key => $value) {
      if (is_array($value)) {
        $redacted[$key] = $this->redactContext($value);
      } elseif (is_string($value)) {
        $redacted[$key] = preg_replace('/[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}/i', '[redacted-email]', $value);
      } else {
        $redacted[$key] = $value;
      }
    }
    
    return $redacted;
  }
}
