import 'package:flutter/material.dart';
import 'dart:async';

/// Debounced search field that delays search execution
class DebouncedSearchField extends StatefulWidget {
  final String? hintText;
  final String? initialValue;
  final Duration debounceDuration;
  final ValueChanged<String> onSearch;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final InputDecoration? decoration;

  const DebouncedSearchField({
    super.key,
    this.hintText,
    this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 300),
    required this.onSearch,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.keyboardType,
    this.enabled = true,
    this.contentPadding,
    this.decoration,
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  String _lastSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    // Call onChanged immediately for UI updates
    widget.onChanged?.call(value);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (value != _lastSearchTerm) {
        _lastSearchTerm = value;
        widget.onSearch(value);
      }
    });
  }

  void _onSubmitted(String value) {
    // Cancel debounce timer and search immediately
    _debounceTimer?.cancel();
    _lastSearchTerm = value;
    widget.onSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: _controller,
      onChanged: _onTextChanged,
      onSubmitted: _onSubmitted,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction ?? TextInputAction.search,
      keyboardType: widget.keyboardType,
      decoration: widget.decoration ?? InputDecoration(
        hintText: widget.hintText ?? 'Suchen...',
        prefixIcon: widget.prefixIcon ?? const Icon(Icons.search),
        suffixIcon: widget.suffixIcon,
        contentPadding: widget.contentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Search field with clear button
class ClearableSearchField extends StatefulWidget {
  final String? hintText;
  final String? initialValue;
  final Duration debounceDuration;
  final ValueChanged<String> onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;

  const ClearableSearchField({
    super.key,
    this.hintText,
    this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 300),
    required this.onSearch,
    this.onChanged,
    this.onClear,
    this.prefixIcon,
    this.textInputAction,
    this.keyboardType,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  State<ClearableSearchField> createState() => _ClearableSearchFieldState();
}

class _ClearableSearchFieldState extends State<ClearableSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {
      _hasText = value.isNotEmpty;
    });
    widget.onChanged?.call(value);
  }

  void _clearText() {
    _controller.clear();
    setState(() {
      _hasText = false;
    });
    widget.onClear?.call();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return DebouncedSearchField(
      controller: _controller,
      hintText: widget.hintText,
      debounceDuration: widget.debounceDuration,
      onSearch: widget.onSearch,
      onChanged: _onTextChanged,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      contentPadding: widget.contentPadding,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _hasText
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearText,
            )
          : null,
    );
  }
}
