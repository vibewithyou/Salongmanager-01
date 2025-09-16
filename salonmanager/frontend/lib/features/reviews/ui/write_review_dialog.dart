import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../state/review_list_controller.dart';

class WriteReviewDialog extends ConsumerStatefulWidget {
  final Review? existingReview;

  const WriteReviewDialog({
    super.key,
    this.existingReview,
  });

  @override
  ConsumerState<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends ConsumerState<WriteReviewDialog> {
  late int _rating;
  late TextEditingController _bodyController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _bodyController = TextEditingController(
      text: widget.existingReview?.body ?? '',
    );
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingReview != null;

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wählen Sie eine Bewertung')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(myReviewControllerProvider.notifier);
      
      if (_isEditing) {
        await controller.updateReview(
          reviewId: widget.existingReview!.id,
          rating: _rating,
          body: _bodyController.text.isEmpty ? null : _bodyController.text,
        );
      } else {
        await controller.createReview(
          rating: _rating,
          body: _bodyController.text.isEmpty ? null : _bodyController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
              ? 'Bewertung wurde aktualisiert' 
              : 'Vielen Dank für Ihre Bewertung!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_isEditing ? 'Bewertung bearbeiten' : 'Bewertung schreiben'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating selection
            Text(
              'Ihre Bewertung',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starRating = index + 1;
                return IconButton(
                  icon: Icon(
                    starRating <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() => _rating = starRating);
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            // Review text
            Text(
              'Ihre Erfahrung (optional)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'Teilen Sie Ihre Erfahrung mit anderen Kunden...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(_isEditing ? 'Aktualisieren' : 'Bewertung abgeben'),
        ),
      ],
    );
  }
}