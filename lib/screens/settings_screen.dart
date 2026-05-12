import 'package:flutter/material.dart';
import '../helpers/font_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF141316)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Settings',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: const Color(0xFF141316),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader('DATA & PRIVACY'),
          _buildSettingsCard([
            _buildInfoItem(
              icon: Icons.phone_iphone,
              title: 'Local storage',
              subtitle: 'Entries are saved on this device.',
              showBorder: true,
            ),
            _buildInfoItem(
              icon: Icons.lock_outline,
              title: 'Device privacy',
              subtitle: 'Use your device passcode to protect local data.',
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionHeader('APPEARANCE'),
          _buildSettingsCard([
            _buildInfoItem(
              icon: Icons.light_mode_outlined,
              title: 'Theme',
              subtitle: 'Light mode',
            ),
          ]),
          const SizedBox(height: 32),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: safeGoogleFont(
          'IBM Plex Sans',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF141316).withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCAC4D0).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: const Color(0xFFCAC4D0).withValues(alpha: 0.3),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          _buildIconContainer(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: safeGoogleFont(
                    'IBM Plex Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF141316),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: safeGoogleFont(
                    'IBM Plex Sans',
                    fontSize: 14,
                    color: const Color(0xFF141316).withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF141316), size: 24),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Icon(
          Icons.info_outline,
          size: 24,
          color: const Color(0xFF141316).withValues(alpha: 0.55),
        ),
        const SizedBox(height: 8),
        Text(
          'Version 0.1.0',
          style: safeGoogleFont(
            'IBM Plex Sans',
            fontSize: 12,
            color: const Color(0xFF141316).withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
