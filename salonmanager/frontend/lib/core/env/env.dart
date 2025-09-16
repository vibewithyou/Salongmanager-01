class Env {
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://127.0.0.1:8000');
  static const tenantSlug = String.fromEnvironment('TENANT_SLUG', defaultValue: 'demo');
  static const usePat = bool.fromEnvironment('USE_PAT', defaultValue: false); // SPA cookie (false) vs PAT (true)
}