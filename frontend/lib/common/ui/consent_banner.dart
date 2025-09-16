import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';

/// Consent banner state
class ConsentBannerState {
  final bool isVisible;
  final bool hasAccepted;
  final bool hasRejected;

  const ConsentBannerState({
    this.isVisible = true,
    this.hasAccepted = false,
    this.hasRejected = false,
  });

  ConsentBannerState copyWith({
    bool? isVisible,
    bool? hasAccepted,
    bool? hasRejected,
  }) {
    return ConsentBannerState(
      isVisible: isVisible ?? this.isVisible,
      hasAccepted: hasAccepted ?? this.hasAccepted,
      hasRejected: hasRejected ?? this.hasRejected,
    );
  }

  bool get shouldShow => isVisible && !hasAccepted && !hasRejected;
}

/// Consent banner controller
final consentBannerProvider = StateNotifierProvider<ConsentBannerController, ConsentBannerState>((ref) {
  return ConsentBannerController();
});

class ConsentBannerController extends StateNotifier<ConsentBannerState> {
  ConsentBannerController() : super(const ConsentBannerState());

  void accept() {
    state = state.copyWith(
      hasAccepted: true,
      isVisible: false,
    );
    // TODO: Save consent to storage
  }

  void reject() {
    state = state.copyWith(
      hasRejected: true,
      isVisible: false,
    );
    // TODO: Save consent to storage
  }

  void show() {
    state = state.copyWith(isVisible: true);
  }

  void hide() {
    state = state.copyWith(isVisible: false);
  }
}

/// Consent banner widget
class ConsentBanner extends ConsumerWidget {
  const ConsentBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consentBannerProvider);
    final controller = ref.read(consentBannerProvider.notifier);

    if (!state.shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(SMTokens.s4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cookie_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: SMTokens.s2),
                  Expanded(
                    child: Text(
                      'Cookie-Einstellungen',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.hide,
                    icon: const Icon(Icons.close, size: 18),
                    constraints: const BoxConstraints(
                      minHeight: 32,
                      minWidth: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SMTokens.s2),
              Text(
                'Wir verwenden Cookies, um Ihnen die beste Erfahrung auf unserer Website zu bieten. Durch die Nutzung unserer Website stimmen Sie der Verwendung von Cookies zu.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SMTokens.s3),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.push('/datenschutz'),
                      child: const Text('Datenschutz'),
                    ),
                  ),
                  const SizedBox(width: SMTokens.s2),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.reject,
                      child: const Text('Ablehnen'),
                    ),
                  ),
                  const SizedBox(width: SMTokens.s2),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.accept,
                      child: const Text('Akzeptieren'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
