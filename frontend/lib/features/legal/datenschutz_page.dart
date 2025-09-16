import 'package:flutter/material.dart';
import '../../common/layout/page_scaffold.dart';
import '../../core/theme/tokens.dart';

class DatenschutzPage extends StatelessWidget {
  const DatenschutzPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Datenschutzerklärung',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SMTokens.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(SMTokens.s4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: SMTokens.rLg,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: SMTokens.s3),
                  Text(
                    'TODO: Datenschutzerklärung einspielen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SMTokens.s2),
                  Text(
                    'Die echte Datenschutzerklärung muss noch von dir bereitgestellt und hier eingespielt werden.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: SMTokens.s3),
                  Text(
                    'Erforderliche Inhalte:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SMTokens.s2),
                  const Text('• Verantwortlicher für die Datenverarbeitung'),
                  const Text('• Zweck der Datenverarbeitung'),
                  const Text('• Rechtsgrundlage (Art. 6 DSGVO)'),
                  const Text('• Speicherdauer der Daten'),
                  const Text('• Rechte der betroffenen Person'),
                  const Text('• Kontaktdaten des Datenschutzbeauftragten'),
                  const Text('• Cookies und Tracking'),
                  const Text('• Datenübertragung an Dritte'),
                  const Text('• Änderungen der Datenschutzerklärung'),
                ],
              ),
            ),
            const SizedBox(height: SMTokens.s6),
            Text(
              'Cookie-Einstellungen:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SMTokens.s2),
            Container(
              padding: const EdgeInsets.all(SMTokens.s4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                borderRadius: SMTokens.rMd,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cookie_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: SMTokens.s2),
                      Text(
                        'Cookie-Banner',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SMTokens.s2),
                  Text(
                    'Das Cookie-Banner ist bereits implementiert und wird automatisch angezeigt. Die Einstellungen können hier verwaltet werden.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: SMTokens.s6),
            Text(
              'Hinweis:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SMTokens.s2),
            Text(
              'Diese Seite ist ein Platzhalter. Bitte ersetze den Inhalt durch eine rechtlich korrekte Datenschutzerklärung, die auf dein Salon zugeschnitten ist.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
