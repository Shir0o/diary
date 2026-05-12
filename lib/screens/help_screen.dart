import 'package:flutter/material.dart';
import '../helpers/font_helper.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFaqItem(
            'How do I add a new entry?',
            'Tap the "+" button on the Timeline screen to start writing.',
          ),
          _buildFaqItem(
            'Are my entries private?',
            'Entries are stored locally on your device.',
          ),
          _buildFaqItem(
            'How can I back up my data?',
            'Backup and export are planned for a future release.',
          ),
          const SizedBox(height: 32),
          Text(
            'For support, open an issue on the project repository.',
            style: safeGoogleFont('Inter', color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: safeGoogleFont(
              'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: safeGoogleFont('Inter', color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
