import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../config/app_theme.dart';
import '../helpers/font_helper.dart';

class OnboardingScreen extends StatefulWidget {
  final ThemeService themeService;
  final VoidCallback onCompleted;

  const OnboardingScreen({
    super.key,
    required this.themeService,
    required this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Sarah',
  );
  String _selectedLayout = 'playful';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    widget.themeService.setUserName(name);
    widget.themeService.setTimelineLayout(_selectedLayout);
    widget.themeService.setOnboardingCompleted(true);
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final palette = widget.themeService.themePalette;

    final bgGradient = AppTheme.getScreenBackground(brightness, palette);
    final cardBg = AppTheme.getCardBackground(brightness, palette);
    final headingColor = AppTheme.getHeadingColor(brightness);
    final bodyColor = AppTheme.getBodyColor(brightness);
    final primaryColor = AppTheme.getPrimaryColor(palette);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Logo/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.getAccentGradient(palette),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌷', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 24),

                // Welcome Title
                Text(
                  "A diary you'll want to open",
                  textAlign: TextAlign.center,
                  style: safeGoogleFont(
                    'Quicksand',
                    color: headingColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's personalize your journal experience.",
                  textAlign: TextAlign.center,
                  style: safeGoogleFont(
                    'Quicksand',
                    color: bodyColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),

                // Name Input Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WHAT IS YOUR NAME?",
                        style: safeGoogleFont(
                          'Space Mono',
                          color: AppTheme.getFaintColor(brightness),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: safeGoogleFont(
                          'Quicksand',
                          color: headingColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your name...',
                          hintStyle: TextStyle(
                            color: AppTheme.getFaintColor(brightness),
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.getHairlineColor(brightness),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Layout Selector Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 12),
                    child: Text(
                      "CHOOSE A STARTING LAYOUT",
                      style: safeGoogleFont(
                        'Space Mono',
                        color: AppTheme.getFaintColor(brightness),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                // Playful Layout Card
                _buildLayoutCard(
                  id: 'playful',
                  title: 'Cards',
                  description: 'Rounded cards on a dotted thread',
                  previewIcon: '🪁',
                  activeColor: primaryColor,
                  cardBg: cardBg,
                  headingColor: headingColor,
                  bodyColor: bodyColor,
                ),
                const SizedBox(height: 12),

                // Compact Layout Card
                _buildLayoutCard(
                  id: 'compact',
                  title: 'Compact',
                  description: 'Slim rows · scan more at once',
                  previewIcon: '📄',
                  activeColor: primaryColor,
                  cardBg: cardBg,
                  headingColor: headingColor,
                  bodyColor: bodyColor,
                ),
                const SizedBox(height: 12),

                // Hero Layout Card
                _buildLayoutCard(
                  id: 'hero',
                  title: 'Spacious',
                  description: 'One moment at a time · big card',
                  previewIcon: '🖼️',
                  activeColor: primaryColor,
                  cardBg: cardBg,
                  headingColor: headingColor,
                  bodyColor: bodyColor,
                ),
                const SizedBox(height: 12),

                // Feed Layout Card
                _buildLayoutCard(
                  id: 'feed',
                  title: 'Moments',
                  description: 'Two-column · photo-led feed',
                  previewIcon: '🧱',
                  activeColor: primaryColor,
                  cardBg: cardBg,
                  headingColor: headingColor,
                  bodyColor: bodyColor,
                ),
                const SizedBox(height: 40),

                // Continue button
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.getAccentGradient(palette),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Get Started',
                        style: safeGoogleFont(
                          'Quicksand',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutCard({
    required String id,
    required String title,
    required String description,
    required String previewIcon,
    required Color activeColor,
    required Color cardBg,
    required Color headingColor,
    required Color bodyColor,
  }) {
    final isSelected = _selectedLayout == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayout = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Preview shape / icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(previewIcon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: safeGoogleFont(
                      'Quicksand',
                      color: headingColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: safeGoogleFont(
                      'Quicksand',
                      color: bodyColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Custom Radio Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? activeColor
                      : AppTheme.getHairlineColor(Theme.of(context).brightness),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
