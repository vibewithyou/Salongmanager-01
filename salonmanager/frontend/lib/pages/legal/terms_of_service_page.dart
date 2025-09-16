import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODO: Terms of Service Content',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This page needs to be populated with actual terms of service content including:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('• Service description and scope'),
            Text('• User obligations and responsibilities'),
            Text('• Payment terms and conditions'),
            Text('• Cancellation and refund policies'),
            Text('• Limitation of liability'),
            Text('• Intellectual property rights'),
            Text('• Dispute resolution procedures'),
            Text('• Governing law and jurisdiction'),
            Text('• Modification of terms'),
            SizedBox(height: 16),
            Text(
              'Please consult with a legal professional to ensure comprehensive coverage of all necessary terms.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
