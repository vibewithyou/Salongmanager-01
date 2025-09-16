import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/salon_theme_overrides.dart';
import '../../common/layout/page_scaffold.dart';
import '../../common/ui/sm_card.dart';
import '../../common/ui/sm_button.dart';
import '../../common/ui/sm_snackbar.dart';

class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});
  
  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final overrides = ref.watch(salonOverridesProvider);
    
    return PageScaffold(
      title: 'Theme & Erscheinungsbild',
      padding: const EdgeInsets.all(SMTokens.s4),
      body: ListView(
        children: [
          // Theme Mode Section
          SMCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erscheinungsbild',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: SMTokens.s4),
                _ThemeModeSelector(
                  value: themeMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).state = mode;
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: SMTokens.s4),
          
          // Color Preview
          SMCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farbschema',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: SMTokens.s4),
                Row(
                  children: [
                    _ColorSwatch(
                      label: 'Primary',
                      color: cs.primary,
                      onColor: cs.onPrimary,
                    ),
                    const SizedBox(width: SMTokens.s3),
                    _ColorSwatch(
                      label: 'Secondary',
                      color: cs.secondary,
                      onColor: cs.onSecondary,
                    ),
                    const SizedBox(width: SMTokens.s3),
                    _ColorSwatch(
                      label: 'Surface',
                      color: cs.surface,
                      onColor: cs.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: SMTokens.s4),
          
          // Salon Overrides
          if (overrides != null) ...[
            SMCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Salon Anpassungen',
                        style: theme.textTheme.titleMedium,
                      ),
                      SMIconButton(
                        icon: Icons.refresh,
                        onPressed: _resetTheme,
                        tooltip: 'Zurücksetzen',
                      ),
                    ],
                  ),
                  const SizedBox(height: SMTokens.s4),
                  if (overrides.primary != null)
                    _OverrideItem(
                      label: 'Primärfarbe',
                      value: _colorToHex(overrides.primary!),
                    ),
                  if (overrides.secondary != null)
                    _OverrideItem(
                      label: 'Sekundärfarbe',
                      value: _colorToHex(overrides.secondary!),
                    ),
                  if (overrides.fontFamily != null)
                    _OverrideItem(
                      label: 'Schriftart',
                      value: overrides.fontFamily!,
                    ),
                  if (overrides.borderRadius != null)
                    _OverrideItem(
                      label: 'Eckenradius',
                      value: '${overrides.borderRadius}px',
                    ),
                ],
              ),
            ),
            const SizedBox(height: SMTokens.s4),
          ],
          
          // Preview Components
          SMCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Komponenten Vorschau',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: SMTokens.s4),
                Wrap(
                  spacing: SMTokens.s3,
                  runSpacing: SMTokens.s3,
                  children: [
                    SMPrimaryButton(
                      onPressed: () {},
                      child: const Text('Primary Button'),
                    ),
                    SMSecondaryButton(
                      onPressed: () {},
                      child: const Text('Secondary'),
                    ),
                    SMGhostButton(
                      onPressed: () {},
                      child: const Text('Ghost'),
                    ),
                  ],
                ),
                const SizedBox(height: SMTokens.s4),
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (_) {}),
                    const SizedBox(width: SMTokens.s2),
                    const Text('Checkbox'),
                    const SizedBox(width: SMTokens.s4),
                    Switch(value: true, onChanged: (_) {}),
                    const SizedBox(width: SMTokens.s2),
                    const Text('Switch'),
                  ],
                ),
                const SizedBox(height: SMTokens.s4),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Eingabefeld',
                    hintText: 'Beispieltext eingeben',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: SMTokens.s4),
          
          // Load Test Theme
          SMCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test Salon Theme',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: SMTokens.s2),
                Text(
                  'Lade ein Test-Theme um die Anpassungen zu sehen',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: SMTokens.s4),
                SMPrimaryButton(
                  onPressed: _loadTestTheme,
                  fullWidth: true,
                  child: const Text('Test Theme laden'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _resetTheme() {
    ref.read(themeControllerProvider.notifier).resetToDefault();
    SMSnackbar.showSuccess(context, 'Theme zurückgesetzt');
  }
  
  void _loadTestTheme() {
    // Example test theme with different colors
    final testOverrides = SalonThemeOverrides(
      primary: const Color(0xFF9C27B0), // Purple
      secondary: const Color(0xFF00BCD4), // Cyan
      borderRadius: 20,
    );
    
    ref.read(themeControllerProvider.notifier).setSalonOverrides(testOverrides);
    SMSnackbar.showInfo(context, 'Test Theme geladen');
  }
  
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  
  const _ThemeModeSelector({
    required this.value,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.settings_suggest),
          label: Text('System'),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode),
          label: Text('Hell'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text('Dunkel'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;
  
  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.onColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: SMTokens.rMd,
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Aa',
            style: TextStyle(
              color: onColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: SMTokens.s1),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _OverrideItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _OverrideItem({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMTokens.s1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}