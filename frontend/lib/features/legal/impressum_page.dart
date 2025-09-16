import 'package:flutter/material.dart';
import '../../common/layout/page_scaffold.dart';
import '../../core/theme/tokens.dart';

class ImpressumPage extends StatelessWidget {
  const ImpressumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Impressum',
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
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: SMTokens.s3),
                  Text(
                    'TODO: Impressum-Inhalte einspielen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SMTokens.s2),
                  Text(
                    'Die echten Impressum-Inhalte müssen noch von dir bereitgestellt und hier eingespielt werden.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: SMTokens.s3),
                  Text(
                    'Erforderliche Angaben:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SMTokens.s2),
                  const Text('• Firmenname/Inhaber'),
                  const Text('• Anschrift'),
                  const Text('• Kontaktdaten (Telefon, E-Mail)'),
                  const Text('• Handelsregister-Nr. (falls vorhanden)'),
                  const Text('• Umsatzsteuer-ID (falls vorhanden)'),
                  const Text('• Berufshaftpflichtversicherung'),
                  const Text('• Aufsichtsbehörde'),
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
              'Diese Seite ist ein Platzhalter. Bitte ersetze den Inhalt durch die tatsächlichen Impressum-Daten deines Salons.',
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
