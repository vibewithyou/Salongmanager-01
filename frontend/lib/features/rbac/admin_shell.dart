import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/layout/page_scaffold.dart';
import '../../common/ui/sm_card.dart';
import '../../common/ui/sm_button.dart';
import '../../core/theme/tokens.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return PageScaffold(
      title: 'Administration',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SMTokens.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            SMCard(
              color: cs.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: cs.primary,
                    size: 32,
                  ),
                  const SizedBox(width: SMTokens.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Willkommen im Admin-Bereich',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: SMTokens.s1),
                        Text(
                          'Verwalte dein Salon-System',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SMTokens.s6),

            // Admin sections
            Text(
              'Verwaltung',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: SMTokens.s4),

            // Team & Roles
            _buildAdminCard(
              context,
              icon: Icons.group_outlined,
              title: 'Team & Rollen',
              description: 'Mitarbeiter verwalten und Berechtigungen zuweisen',
              route: '/admin/staff',
              color: cs.primary,
            ),

            const SizedBox(height: SMTokens.s3),

            // Schedule Management
            _buildAdminCard(
              context,
              icon: Icons.schedule_outlined,
              title: 'Dienstpläne',
              description: 'Schichtpläne erstellen und verwalten',
              route: '/admin/schedule',
              color: cs.secondary,
            ),

            const SizedBox(height: SMTokens.s3),

            // Services & Pricing
            _buildAdminCard(
              context,
              icon: Icons.work_outline,
              title: 'Leistungen & Preise',
              description: 'Service-Katalog und Preise verwalten',
              route: '/admin/services',
              color: SMTokens.success,
            ),

            const SizedBox(height: SMTokens.s3),

            // POS & Billing
            _buildAdminCard(
              context,
              icon: Icons.point_of_sale_outlined,
              title: 'POS & Kasse',
              description: 'Kassensystem und Rechnungen verwalten',
              route: '/admin/pos',
              color: SMTokens.warning,
            ),

            const SizedBox(height: SMTokens.s3),

            // Inventory
            _buildAdminCard(
              context,
              icon: Icons.inventory_outlined,
              title: 'Inventar',
              description: 'Lagerbestände und Artikel verwalten',
              route: '/admin/inventory',
              color: SMTokens.info,
            ),

            const SizedBox(height: SMTokens.s6),

            // Quick stats
            Text(
              'Übersicht',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: SMTokens.s4),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.people,
                    label: 'Mitarbeiter',
                    value: '8',
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: SMTokens.s3),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Heutige Termine',
                    value: '12',
                    color: cs.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: SMTokens.s3),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.euro,
                    label: 'Tagesumsatz',
                    value: '1.2k€',
                    color: SMTokens.success,
                  ),
                ),
                const SizedBox(width: SMTokens.s3),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.inventory,
                    label: 'Artikel',
                    value: '45',
                    color: SMTokens.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String route,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return SMCard(
      onTap: () => context.push(route),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SMTokens.s3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: SMTokens.rMd,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: SMTokens.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SMTokens.s1),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return SMCard(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: SMTokens.s2),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
