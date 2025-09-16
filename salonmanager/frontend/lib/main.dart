import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';

void main() async {
  await SentryFlutter.init(
    (opts) {
      opts.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      opts.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(const ProviderScope(child: SalonManagerApp())),
  );
}