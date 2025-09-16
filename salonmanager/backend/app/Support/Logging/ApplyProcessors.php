<?php
namespace App\Support\Logging;

use Monolog\Logger;

class ApplyProcessors {
  public function __invoke(Logger $logger) {
    $logger->pushProcessor(new RedactPiiProcessor());
  }
}
