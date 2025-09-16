import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/salon_controller.dart';
import '../models/content_block.dart';

class SalonPage extends ConsumerWidget {
  const SalonPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salonControllerProvider);
    if (state.loading && state.profile==null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(state.profile?.name ?? 'Salon'),
        actions: [
          IconButton(
            onPressed: () => context.go('/bookings'),
            icon: const Icon(Icons.calendar_today),
            tooltip: 'My Bookings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: state.blocks.where((b)=>b.isActive).map((b) => _buildBlock(context, b)).toList(),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, ContentBlock b) {
    switch (b.type) {
      case 'hero':
        final headline = b.config['headline'] ?? b.title ?? '';
        final sub = b.config['sub'] ?? '';
        return _HeroBlock(headline: headline, sub: sub);
      case 'text':
        final text = b.config['text'] ?? '';
        return _TextBlock(text: text, title: b.title);
      case 'cta':
        final label = b.config['label'] ?? 'Jetzt buchen';
        return _CtaBlock(label: label);
      case 'gallery':
        // TODO: render image grid from config['images'] (list of urls)
        return _Placeholder('Gallery (TODO)');
      default:
        return _Placeholder('Unsupported block: ${b.type}');
    }
  }
}

class _HeroBlock extends StatelessWidget {
  final String headline;
  final String sub;
  const _HeroBlock({required this.headline, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom:16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [
          Theme.of(context).colorScheme.primary.withOpacity(.15),
          Theme.of(context).colorScheme.primary.withOpacity(.05),
        ]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(headline, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(sub, style: Theme.of(context).textTheme.bodyLarge),
      ]),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String title;
  final String text;
  const _TextBlock({this.title='', required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom:16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title.isNotEmpty) ...[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
        ],
        Text(text),
      ]),
    );
  }
}

class _CtaBlock extends StatelessWidget {
  final String label;
  const _CtaBlock({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom:16),
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () {
          context.go('/book');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:16, vertical:12),
          child: Text(label),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String label;
  const _Placeholder(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom:16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label),
    );
  }
}