import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentBanner extends StatefulWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCustomize;

  const ConsentBanner({
    Key? key,
    this.onAccept,
    this.onDecline,
    this.onCustomize,
  }) : super(key: key);

  @override
  State<ConsentBanner> createState() => _ConsentBannerState();
}

class _ConsentBannerState extends State<ConsentBanner> {
  bool _showBanner = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConsentStatus();
  }

  Future<void> _checkConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('privacy_consent') ?? false;
    
    setState(() {
      _showBanner = !hasConsent;
      _isLoading = false;
    });
  }

  Future<void> _acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_consent', true);
    await prefs.setBool('analytics_consent', true);
    await prefs.setBool('marketing_consent', true);
    
    setState(() {
      _showBanner = false;
    });
    
    widget.onAccept?.call();
  }

  Future<void> _declineConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_consent', true);
    await prefs.setBool('analytics_consent', false);
    await prefs.setBool('marketing_consent', false);
    
    setState(() {
      _showBanner = false;
    });
    
    widget.onDecline?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_showBanner) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We use cookies to enhance your experience and analyze our traffic. By continuing to use our app, you consent to our use of cookies.',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _declineConsent,
                child: const Text('Decline'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Show detailed consent options
                  widget.onCustomize?.call();
                },
                child: const Text('Customize'),
              ),
              ElevatedButton(
                onPressed: _acceptConsent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Accept All'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
