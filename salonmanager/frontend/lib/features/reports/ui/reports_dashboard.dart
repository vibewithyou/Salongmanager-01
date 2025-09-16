import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state/report_controller.dart';
import '../state/report_state.dart';
import 'widgets/revenue_chart.dart';
import 'widgets/top_services_chart.dart';
import 'widgets/date_range_picker.dart';

class ReportsDashboard extends ConsumerStatefulWidget {
  const ReportsDashboard({super.key});

  @override
  ConsumerState<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends ConsumerState<ReportsDashboard> {
  DateTime? _selectedFrom;
  DateTime? _selectedTo;
  bool _showDatePicker = false;

  @override
  void initState() {
    super.initState();
    // Set default date range to last 30 days
    _selectedTo = DateTime.now();
    _selectedFrom = DateTime.now().subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () {
              setState(() {
                _showDatePicker = !_showDatePicker;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (type) => _exportCsv(type),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'revenue',
                child: Text('Export Revenue'),
              ),
              const PopupMenuItem(
                value: 'topServices',
                child: Text('Export Top Services'),
              ),
              const PopupMenuItem(
                value: 'topStylists',
                child: Text('Export Top Stylists'),
              ),
              const PopupMenuItem(
                value: 'occupancy',
                child: Text('Export Occupancy'),
              ),
            ],
            child: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showDatePicker)
            DateRangePicker(
              fromDate: _selectedFrom,
              toDate: _selectedTo,
              onDateRangeSelected: (from, to) {
                setState(() {
                  _selectedFrom = from;
                  _selectedTo = to;
                  _showDatePicker = false;
                });
                _loadReports();
              },
            ),
          Expanded(
            child: _buildContent(reportState),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ReportState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            ElevatedButton(
              onPressed: () {
                ref.read(reportControllerProvider.notifier).clearError();
                _loadReports();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeInfo(),
          const SizedBox(height: 20),
          _buildRevenueCard(state),
          const SizedBox(height: 20),
          _buildTopServicesCard(state),
          const SizedBox(height: 20),
          _buildTopStylistsCard(state),
          const SizedBox(height: 20),
          _buildOccupancyCard(state),
        ],
      ),
    );
  }

  Widget _buildDateRangeInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text(
              'Date Range: ${_formatDate(_selectedFrom)} - ${_formatDate(_selectedTo)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(ReportState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: RevenueChart(data: state.revenueData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopServicesCard(ReportState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Services',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: TopServicesChart(data: state.topServices.take(5).toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStylistsCard(ReportState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Stylists',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...state.topStylists.take(5).map((stylist) => ListTile(
              title: Text(stylist.name),
              subtitle: Text('${stylist.count} bookings'),
              trailing: Text('€${stylist.totalRevenue.toStringAsFixed(2)}'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyCard(ReportState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Occupancy Rate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...state.occupancyData.map((data) => ListTile(
              title: Text(data.day),
              subtitle: Text('${data.bookedMinutes} / ${data.totalMinutes} minutes'),
              trailing: Text('${data.occupancyPercentage.toStringAsFixed(1)}%'),
            )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _loadReports() {
    if (_selectedFrom != null && _selectedTo != null) {
      ref.read(reportControllerProvider.notifier).loadReports(_selectedFrom!, _selectedTo!);
    }
  }

  void _exportCsv(String type) {
    ref.read(reportControllerProvider.notifier).exportCsv(type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting $type data...')),
    );
  }
}