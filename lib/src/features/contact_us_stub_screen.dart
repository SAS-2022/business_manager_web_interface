import 'package:flutter/material.dart';

/// Placeholder for the real Contact Us feature (mobile app's
/// features/user_details/contact_us.dart), not yet ported. Exists so the
/// 'contactUs' link on the login screen has somewhere to go.
class ContactUsStubScreen extends StatelessWidget {
  const ContactUsStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: const Center(child: Text('Contact Us — coming soon.')),
    );
  }
}
