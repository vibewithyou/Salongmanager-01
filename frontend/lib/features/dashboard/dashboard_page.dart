import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/layout/page_scaffold.dart';
import '../../common/layout/responsive_layout.dart';
import '../../common/ui/sm_card.dart';
import '../../common/ui/sm_button.dart';
import '../../common/ui/sm_badge.dart';
import '../../common/ui/empty_state.dart';
import '../../core/theme/tokens.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return ResponsivePageScaffold(
      title: 'Dashboard',
      actions: [
        SMIconButton(
          icon: Icons.notifications_outlined,
          onPressed: () {},
          tooltip: 'Benachrichtigungen',
        ),
        SMIconButton(
          icon: Icons.settings_outlined,
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          tooltip: 'Einstellungen',
        ),
      ],
      floatingActionButton: SMFloatingButton(
        onPressed: () {
          Navigator.pushNamed(context, '/bookings/new');
        },
        tooltip: 'Neue Buchung',
        child: const Icon(Icons.add),
      ),
      padding: const EdgeInsets.all(SMTokens.s4),
      mobileBody: _buildMobileLayout(context),
      tabletBody: _buildTabletLayout(context),
      desktopBody: _buildDesktopLayout(context),
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return ListView(
      children: [
        _buildQuickStats(context, columns: 2),
        const SizedBox(height: SMTokens.s4),
        _buildTodaySection(context),
        const SizedBox(height: SMTokens.s4),
        _buildRecentBookings(context),
      ],
    );
  }
  
  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ListView(
            children: [
              _buildQuickStats(context, columns: 2),
              const SizedBox(height: SMTokens.s4),
              _buildTodaySection(context),
            ],
          ),
        ),
        const SizedBox(width: SMTokens.s4),
        Expanded(
          child: _buildRecentBookings(context),
        ),
      ],
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildQuickStats(context, columns: 4),
              const SizedBox(height: SMTokens.s4),
              Expanded(child: _buildTodaySection(context)),
            ],
          ),
        ),
        const SizedBox(width: SMTokens.s4),
        SizedBox(
          width: 320,
          child: _buildRecentBookings(context),
        ),
      ],
    );
  }
  
  Widget _buildQuickStats(BuildContext context, {required int columns}) {
    final stats = [
      _StatItem(
        icon: Icons.calendar_today,
        label: 'Heute',
        value: '12',
        color: Theme.of(context).colorScheme.primary,
      ),
      _StatItem(
        icon: Icons.people,
        label: 'Kunden',
        value: '248',
        color: Theme.of(context).colorScheme.secondary,
      ),
      _StatItem(
        icon: Icons.euro,
        label: 'Umsatz',
        value: '1.2k',
        color: SMTokens.success,
      ),
      _StatItem(
        icon: Icons.trending_up,
        label: 'Wachstum',
        value: '+15%',
        color: SMTokens.info,
      ),
    ];
    
    return ResponsiveGrid(
      mobileColumns: columns,
      tabletColumns: columns,
      desktopColumns: columns,
      spacing: SMTokens.s3,
      children: stats.map((stat) => _buildStatCard(context, stat)).toList(),
    );
  }
  
  Widget _buildStatCard(BuildContext context, _StatItem stat) {
    final theme = Theme.of(context);
    
    return SMCard(
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                stat.icon,
                color: stat.color.withOpacity(0.8),
                size: 24,
              ),
              if (stat.badge != null)
                SMBadge.dot(
                  backgroundColor: stat.color,
                  child: const SizedBox.shrink(),
                ),
            ],
          ),
          const SizedBox(height: SMTokens.s3),
          Text(
            stat.value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SMTokens.s1),
          Text(
            stat.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTodaySection(BuildContext context) {
    final theme = Theme.of(context);
    final hasAppointments = true; // Demo toggle
    
    return SMCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heutige Termine',
                style: theme.textTheme.titleLarge,
              ),
              SMGhostButton(
                onPressed: () {},
                child: const Text('Alle anzeigen'),
              ),
            ],
          ),
          const SizedBox(height: SMTokens.s4),
          if (hasAppointments) ...[
            _buildAppointmentItem(
              context,
              time: '09:00',
              customer: 'Anna Schmidt',
              service: 'Haarschnitt & Styling',
              staff: 'Maria',
              status: StatusType.active,
            ),
            const Divider(height: SMTokens.s4),
            _buildAppointmentItem(
              context,
              time: '10:30',
              customer: 'Max Müller',
              service: 'Herrenhaarschnitt',
              staff: 'Tom',
              status: StatusType.pending,
            ),
            const Divider(height: SMTokens.s4),
            _buildAppointmentItem(
              context,
              time: '14:00',
              customer: 'Lisa Weber',
              service: 'Coloration & Schnitt',
              staff: 'Sarah',
              status: StatusType.pending,
            ),
          ] else
            EmptyState.noData(
              title: 'Keine Termine heute',
              subtitle: 'Genieße deinen freien Tag!',
              action: SMPrimaryButton(
                onPressed: () {},
                child: const Text('Termin erstellen'),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildAppointmentItem(
    BuildContext context, {
    required String time,
    required String customer,
    required String service,
    required String staff,
    required StatusType status,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(
            horizontal: SMTokens.s2,
            vertical: SMTokens.s1,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: SMTokens.rSm,
          ),
          child: Text(
            time,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: SMTokens.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      customer,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: SMTokens.s2),
                  SMStatusBadge(
                    label: status == StatusType.active ? 'Aktiv' : 'Ausstehend',
                    type: status,
                  ),
                ],
              ),
              const SizedBox(height: SMTokens.s1),
              Text(
                '$service • $staff',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentBookings(BuildContext context) {
    final theme = Theme.of(context);
    
    return SMCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Letzte Buchungen',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: SMTokens.s4),
          _buildBookingItem(
            context,
            customer: 'Julia Hoffmann',
            service: 'Balayage',
            time: 'vor 2 Stunden',
          ),
          const Divider(height: SMTokens.s3),
          _buildBookingItem(
            context,
            customer: 'Thomas Klein',
            service: 'Bart trimmen',
            time: 'vor 3 Stunden',
          ),
          const Divider(height: SMTokens.s3),
          _buildBookingItem(
            context,
            customer: 'Sophie Bauer',
            service: 'Maniküre',
            time: 'vor 5 Stunden',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookingItem(
    BuildContext context, {
    required String customer,
    required String service,
    required String time,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Text(
          customer.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(customer),
      subtitle: Text(service),
      trailing: Text(
        time,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool? badge;
  
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.badge,
  });
}