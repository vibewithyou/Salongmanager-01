import 'package:flutter/material.dart';
import '../../common/layout/page_scaffold.dart';
import '../../core/theme/tokens.dart';

class AgbPage extends StatelessWidget {
  const AgbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Allgemeine Geschäftsbedingungen',
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
                    Icons.description_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: SMTokens.s3),
                  Text(
                    'TODO: AGB-Inhalte einspielen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SMTokens.s2),
                  Text(
                    'Die echten AGB müssen noch von dir bereitgestellt und hier eingespielt werden.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: SMTokens.s3),
                  Text(
                    'Empfohlene Inhalte:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SMTokens.s2),
                  const Text('• Geltungsbereich'),
                  const Text('• Vertragsschluss'),
                  const Text('• Leistungen und Preise'),
                  const Text('• Zahlungsbedingungen'),
                  const Text('• Stornierungs- und Umbuchungsregelungen'),
                  const Text('• Haftung und Gewährleistung'),
                  const Text('• Datenschutz'),
                  const Text('• Schlussbestimmungen'),
                  const Text('• Gerichtsstand'),
                ],
              ),
            ),
            const SizedBox(height: SMTokens.s6),
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
                        Icons.schedule_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: SMTokens.s2),
                      Text(
                        'Stornierungsregelungen',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SMTokens.s2),
                  Text(
                    'Definiere klare Regeln für Stornierungen und Umbuchungen, z.B.:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: SMTokens.s2),
                  const Text('• Kostenlose Stornierung bis 24h vor Termin'),
                  const Text('• 50% Stornogebühr bei Stornierung am selben Tag'),
                  const Text('• Keine Stornierung bei No-Show'),
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
              'Diese Seite ist ein Platzhalter. Bitte ersetze den Inhalt durch deine individuellen AGB, die rechtlich geprüft wurden.',
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
