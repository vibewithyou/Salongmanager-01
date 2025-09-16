<?php
namespace App\Services\Notify;

class TemplateRenderer {
  public static function render(string $tpl, array $data): string {
    return preg_replace_callback('/\{\{\s*([a-z0-9_.]+)\s*\}\}/i', function($m) use ($data){
      $keys = explode('.', $m[1]); $val = $data;
      foreach ($keys as $k) { if (is_array($val) && array_key_exists($k,$val)) $val = $val[$k]; else return ''; }
      return is_scalar($val) ? (string)$val : json_encode($val);
    }, $tpl);
  }
}