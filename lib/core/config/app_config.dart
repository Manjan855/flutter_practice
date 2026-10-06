import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single source of truth for every runtime configuration value.
///
/// Nothing sensitive is ever hardcoded in feature code - widgets ask for
/// `AppConfig.x` and the value is resolved here.
///
/// Resolution order for every key:
///
///   1. `--dart-define` compile-time flag  -> wins for CI / release builds
///   2. `.env` file                        -> wins for local development
///   3. Built-in dev default               -> last resort, app still starts
///
/// Example:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000
class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // 1. Compile-time values. `String.fromEnvironment` requires a literal, so
  //    every flag gets its own top-level const.
  // ---------------------------------------------------------------------------
  static const String _dApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _dKhaltiBaseUrl =
      String.fromEnvironment('KHALTI_BASE_URL');
  static const String _dKhaltiPublicKey =
      String.fromEnvironment('KHALTI_PUBLIC_KEY');
  static const String _dEsewaSecretKey =
      String.fromEnvironment('ESEWA_SECRET_KEY');
  static const String _dEsewaProductCode =
      String.fromEnvironment('ESEWA_PRODUCT_CODE');
  static const String _dEsewaUseDev = String.fromEnvironment(
    'ESEWA_USE_DEV_MODE',
  );
  static const String _dFacebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
  );
  static const String _dFacebookClientToken =
      String.fromEnvironment('FACEBOOK_CLIENT_TOKEN');
  static const String _dHttpLogging = String.fromEnvironment(
    'ENABLE_HTTP_LOGGING',
  );

  // ---------------------------------------------------------------------------
  // 2. Built-in development defaults. These keep the app runnable on a fresh
  //    clone with no configuration at all.
  // ---------------------------------------------------------------------------
  static const String _devApiBaseUrl = 'http://192.168.18.17:8000';
  static const String _devKhaltiBaseUrl =
      'https://aapi.khalti.com/api/v2';
  static const String _devKhaltiPublicKey = '';
  static const String _devEsewaSecretKey = '8gBm/:&EnhH.1/q';
  static const String _devEsewaProductCode = 'EPAYTEST';

  // ---------------------------------------------------------------------------
  // 3. Resolved getters.
  // ---------------------------------------------------------------------------

  /// Base URL of the products API (`GET /vehicles`).
  static String get apiBaseUrl =>
      _resolve(_dApiBaseUrl, 'API_BASE_URL', _devApiBaseUrl);

  /// Khalti ePayment API root (`/payment/initialize` is appended).
  static String get khaltiBaseUrl =>
      _resolve(_dKhaltiBaseUrl, 'KHALTI_BASE_URL', _devKhaltiBaseUrl);

  /// Khalti public key. Empty means "not configured yet".
  static String get khaltiPublicKey =>
      _resolve(_dKhaltiPublicKey, 'KHALTI_PUBLIC_KEY', _devKhaltiPublicKey);

  /// Whether the Khalti integration can actually be started.
  static bool get isKhaltiConfigured => khaltiPublicKey.isNotEmpty;

  /// eSewa merchant secret used to sign the payment request.
  static String get esewaSecretKey =>
      _resolve(_dEsewaSecretKey, 'ESEWA_SECRET_KEY', _devEsewaSecretKey);

  /// eSewa product/merchant code.
  static String get esewaProductCode => _resolve(
    _dEsewaProductCode,
    'ESEWA_PRODUCT_CODE',
    _devEsewaProductCode,
  );

  /// `true` -> RC/test gateway, `false` -> production gateway.
  static bool get esewaUseDevMode {
    final raw = _resolve(_dEsewaUseDev, 'ESEWA_USE_DEV_MODE', 'true');
    return raw.toLowerCase() != 'false';
  }

  /// Facebook App ID. Empty means "not configured yet".
  static String get facebookAppId =>
      _resolve(_dFacebookAppId, 'FACEBOOK_APP_ID', '');

  /// Facebook Client Token. Empty means "not configured yet".
  static String get facebookClientToken =>
      _resolve(_dFacebookClientToken, 'FACEBOOK_CLIENT_TOKEN', '');

  /// Whether Facebook login can be attempted.
  static bool get isFacebookConfigured =>
      facebookAppId.isNotEmpty && facebookClientToken.isNotEmpty;

  /// Whether raw HTTP response bodies should be logged.
  static bool get enableHttpLogging {
    final raw = _resolve(_dHttpLogging, 'ENABLE_HTTP_LOGGING', 'false');
    return raw.toLowerCase() == 'true';
  }

  // ---------------------------------------------------------------------------

  static String _resolve(
    String fromDefine,
    String envKey,
    String fallback,
  ) {
    if (fromDefine.trim().isNotEmpty) return fromDefine.trim();
    final fromEnv = _env(envKey);
    if (fromEnv.isNotEmpty) return fromEnv;
    return fallback;
  }

  static String _env(String key) {
    // Never touch dotenv before it is loaded (or when tests skip loading) -
    // `.maybeGet` would otherwise throw on an uninitialized instance.
    if (!dotenv.isInitialized) return '';
    return (dotenv.maybeGet(key) ?? '').trim();
  }

  /// Human readable summary, useful while debugging configuration problems.
  /// Secrets are never echoed in full.
  static Map<String, String> describe() => {
    'apiBaseUrl': apiBaseUrl,
    'khaltiBaseUrl': khaltiBaseUrl,
    'khaltiPublicKey': _obscure(khaltiPublicKey),
    'esewaUseDevMode': esewaUseDevMode.toString(),
    'facebookConfigured': isFacebookConfigured.toString(),
    'httpLogging': enableHttpLogging.toString(),
  };

  static String _obscure(String value) {
    if (value.isEmpty) return '(not set)';
    if (value.length <= 8) return '****';
    return '${value.substring(0, 6)}…${value.substring(value.length - 4)}';
  }
}
