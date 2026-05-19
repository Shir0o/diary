import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  final bool isAuthenticating;
  final bool animate;

  const BiometricLockScreen({
    super.key,
    required this.onUnlock,
    required this.isAuthenticating,
    this.animate = true,
  });

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  String? _errorMessage;

  @override
  void didUpdateWidget(BiometricLockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAuthenticating && !widget.isAuthenticating) {
      // Authentication finished. If we are still on this screen, it means it failed.
      setState(() {
        _errorMessage = 'Authentication failed. Please try again.';
      });
    }
  }

  void _handleUnlock() {
    setState(() {
      _errorMessage = null;
    });
    widget.onUnlock();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium adaptive gradients
    final backgroundGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkGradientStart,
              AppTheme.darkGradientMiddle,
              AppTheme.darkGradientEnd,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightGradientStart,
              AppTheme.lightGradientMiddle,
              AppTheme.lightGradientEnd,
            ],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(
                        alpha: isDark ? 0.45 : 0.7,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusLarge,
                      ),
                      border: Border.all(
                        color: colorScheme.outline.withValues(
                          alpha: isDark ? 0.08 : 0.15,
                        ),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stylized top lock badge
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_person_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        Text(
                          'Diary is Locked',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          'Securely locked to keep your personal entries private.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingExtraLarge),

                        // Interactive pulsing biometric icon
                        PulsingBiometricIcon(
                          onTap: widget.isAuthenticating ? null : _handleUnlock,
                          isAuthenticating: widget.isAuthenticating,
                          animate: widget.animate,
                        ),

                        const SizedBox(height: AppTheme.spacingExtraLarge),

                        // Elegant Primary Action Button
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: widget.isAuthenticating
                              ? SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Semantics(
                                      label: 'Authenticating',
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _handleUnlock,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppTheme.spacingMedium,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.borderRadiusMedium,
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.fingerprint,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      'Unlock with Biometrics',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                        // Error message feedback
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppTheme.spacingMedium),
                          AnimatedOpacity(
                            opacity: _errorMessage != null ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: colorScheme.error,
                                  size: 16,
                                ),
                                const SizedBox(
                                  width: AppTheme.spacingExtraSmall,
                                ),
                                Flexible(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PulsingBiometricIcon extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isAuthenticating;
  final bool animate;

  const PulsingBiometricIcon({
    super.key,
    this.onTap,
    required this.isAuthenticating,
    this.animate = true,
  });

  @override
  State<PulsingBiometricIcon> createState() => _PulsingBiometricIconState();
}

class _PulsingBiometricIconState extends State<PulsingBiometricIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _ring1Scale;
  late Animation<double> _ring1Opacity;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring2Opacity;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Ripple 1
    _ring1Scale = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    _ring1Opacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    // Ripple 2
    _ring2Scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );
    _ring2Opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    // Subtle scale breathing for the center icon
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.06),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulsingBiometricIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Unlock with biometrics',
      enabled: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple 1 Animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _ring1Scale.value,
                      child: Opacity(
                        opacity: _ring1Opacity.value,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Ripple 2 Animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _ring2Scale.value,
                      child: Opacity(
                        opacity: _ring2Opacity.value,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Center button with shadow
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: widget.isAuthenticating ? 0.95 : _iconScale.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: colorScheme.primary,
                      size: 44,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
