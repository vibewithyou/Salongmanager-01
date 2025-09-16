import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentBanner extends StatefulWidget {
  final VoidCallback? onAccepted;
  final VoidCallback? onDeclined;
  const ConsentBanner({super.key, this.onAccepted, this.onDeclined});

  @override
  State<ConsentBanner> createState() => _ConsentBannerState();
}

class _ConsentBannerState extends State<ConsentBanner> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final sp = await SharedPreferences.getInstance();
    final seen = sp.getBool('consent.accepted') ?? false;
    setState(() => _visible = !seen);
  }

  Future<void> _accept([bool accept=true]) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('consent.accepted', accept);
    setState(() => _visible = false);
    // Optional: API call to log consent
    widget.onAccepted?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      elevation: 8,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Wir verwenden Cookies/ähnliche Technologien für die Kernfunktionen (z. B. Login, Buchung). '
                 'Mehr Infos in Datenschutzerklärung.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextButton(onPressed: ()=>_accept(false), child: const Text('Ablehnen'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: _accept, child: const Text('Akzeptieren'))),
            ]),
          ]),
        ),
      ),
    );
  }
}
