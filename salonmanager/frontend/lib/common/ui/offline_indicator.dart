import 'package:flutter/material.dart';
import '../../services/api/dio_client.dart';

/// Offline indicator widget that shows when network is unavailable
class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Color? backgroundColor;
  final Color? textColor;
  final String? message;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.textColor,
    this.message,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen for offline status changes
    OfflineInterceptor.addOfflineListener(_onOfflineStatusChanged);
    _isOffline = OfflineInterceptor.isOffline;
    if (_isOffline) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    OfflineInterceptor.removeOfflineListener(_onOfflineStatusChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onOfflineStatusChanged() {
    if (mounted) {
      setState(() {
        _isOffline = OfflineInterceptor.isOffline;
      });

      if (_isOffline) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value * 50),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? cs.errorContainer,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: widget.textColor ?? cs.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.message ?? 'Keine Internetverbindung',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.textColor ?? cs.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Trigger a test request to check connectivity
                          _testConnectivity();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: widget.textColor ?? cs.onErrorContainer,
                          size: 20,
                        ),
                        tooltip: 'Verbindung testen',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _testConnectivity() async {
    try {
      // Make a simple request to test connectivity
      final dio = Dio();
      await dio.get('${Uri.base.origin}/api/v1/health');
      
      // If successful, the offline interceptor should detect we're back online
    } catch (e) {
      // Still offline
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Immer noch offline. Bitte überprüfe deine Internetverbindung.'),
          backgroundColor: cs.error,
        ),
      );
    }
  }
}

/// Offline banner that can be used in app bars
class OfflineBanner extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final String? message;

  const OfflineBanner({
    super.key,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.message,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    OfflineInterceptor.addOfflineListener(_onOfflineStatusChanged);
    _isOffline = OfflineInterceptor.isOffline;
  }

  @override
  void dispose() {
    OfflineInterceptor.removeOfflineListener(_onOfflineStatusChanged);
    super.dispose();
  }

  void _onOfflineStatusChanged() {
    if (mounted) {
      setState(() {
        _isOffline = OfflineInterceptor.isOffline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        if (_isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: widget.backgroundColor ?? cs.errorContainer,
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  color: widget.textColor ?? cs.onErrorContainer,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message ?? 'Offline',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.textColor ?? cs.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
