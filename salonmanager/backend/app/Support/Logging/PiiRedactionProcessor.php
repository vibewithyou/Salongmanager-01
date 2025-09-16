<?php

namespace App\Support\Logging;

use Monolog\LogRecord;
use Monolog\Processor\ProcessorInterface;

class PiiRedactionProcessor implements ProcessorInterface
{
    /**
     * Sensitive patterns to redact
     */
    private array $patterns = [
        // Email addresses
        '/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/' => '[EMAIL_REDACTED]',
        
        // Phone numbers (various formats)
        '/\b(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})\b/' => '[PHONE_REDACTED]',
        
        // Credit card numbers
        '/\b(?:\d{4}[-\s]?){3}\d{4}\b/' => '[CARD_REDACTED]',
        
        // SSN
        '/\b\d{3}-\d{2}-\d{4}\b/' => '[SSN_REDACTED]',
        
        // Authorization headers
        '/Authorization:\s*[^\s]+/i' => 'Authorization: [REDACTED]',
        '/Bearer\s+[^\s]+/i' => 'Bearer [REDACTED]',
        '/X-XSRF-TOKEN:\s*[^\s]+/i' => 'X-XSRF-TOKEN: [REDACTED]',
        '/Stripe-Signature:\s*[^\s]+/i' => 'Stripe-Signature: [REDACTED]',
        
        // API keys
        '/[Aa]pi[_-]?[Kk]ey["\s]*[:=]["\s]*[A-Za-z0-9_-]+/i' => 'api_key: [REDACTED]',
        '/[Aa]ccess[_-]?[Tt]oken["\s]*[:=]["\s]*[A-Za-z0-9_-]+/i' => 'access_token: [REDACTED]',
        
        // Database credentials
        '/DB_PASSWORD["\s]*[:=]["\s]*[^\s]+/i' => 'DB_PASSWORD: [REDACTED]',
        '/DB_CONNECTION["\s]*[:=]["\s]*[^\s]+/i' => 'DB_CONNECTION: [REDACTED]',
        
        // URLs with sensitive data
        '/https?:\/\/[^\s]*[?&](?:password|token|key|secret)=[^&\s]+/i' => '[URL_REDACTED]',
    ];

    public function __invoke(LogRecord $record): LogRecord
    {
        $message = $record->message;
        $context = $record->context;

        // Redact message
        $message = $this->redactSensitiveData($message);

        // Redact context
        $context = $this->redactContext($context);

        return $record->with(message: $message, context: $context);
    }

    /**
     * Redact sensitive data from message
     */
    private function redactSensitiveData(string $message): string
    {
        foreach ($this->patterns as $pattern => $replacement) {
            $message = preg_replace($pattern, $replacement, $message);
        }

        return $message;
    }

    /**
     * Recursively redact sensitive data from context
     */
    private function redactContext(array $context): array
    {
        $redacted = [];

        foreach ($context as $key => $value) {
            $redactedKey = $this->redactSensitiveData($key);

            if (is_array($value)) {
                $redacted[$redactedKey] = $this->redactContext($value);
            } elseif (is_string($value)) {
                $redacted[$redactedKey] = $this->redactSensitiveData($value);
            } else {
                $redacted[$redactedKey] = $value;
            }
        }

        return $redacted;
    }
}
