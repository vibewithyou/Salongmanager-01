import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pos_repository.dart';

final zReportProvider = FutureProvider.family<Map<String, dynamic>, DateTimeRange?>((ref, dateRange) {
  final repo = ref.read(posRepositoryProvider);
  return repo.zReport(
    from: dateRange?.start,
    to: dateRange?.end,
  );
});

final posRepositoryProvider = Provider<PosRepository>((_) => PosRepository());

class ZReportPage extends ConsumerWidget {
  const ZReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dateRange = DateTimeRange(
      start: DateTime(today.year, today.month, today.day),
      end: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );

    final reportAsync = ref.watch(zReportProvider(dateRange));

    return Scaffold(
      appBar: AppBar(title: const Text('Z-Bericht')),
      body: reportAsync.when(
        data: (report) => _buildReport(report),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Fehler: $error'),
        ),
      ),
    );
  }

  Widget _buildReport(Map<String, dynamic> report) {
    final summary = report['summary'] as Map<String, dynamic>;
    final payments = report['payments'] as Map<String, dynamic>;
    final count = report['count_invoices'] as int;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tagesabschluss',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _summaryLine('Rechnungen', count.toString()),
                  _summaryLine('Netto', '€ ${(summary['net'] as num).toStringAsFixed(2)}'),
                  _summaryLine('Steuer', '€ ${(summary['tax'] as num).toStringAsFixed(2)}'),
                  _summaryLine('Brutto', '€ ${(summary['gross'] as num).toStringAsFixed(2)}', isBold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zahlungsarten',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ...payments.entries.map((entry) => 
                    _summaryLine(_getPaymentMethodName(entry.key), '€ ${(entry.value as num).toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value, {bool isBold = false}) {
    final style = isBold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Bar';
      case 'card':
        return 'Karte';
      case 'external':
        return 'Extern';
      default:
        return method;
    }
  }
}