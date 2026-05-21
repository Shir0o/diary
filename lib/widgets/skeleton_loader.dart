import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'timeline_node.dart';

/// A base skeleton placeholder widget that pulses its opacity to indicate loading.
class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: widget.child,
      ),
    );
  }
}

/// A skeleton entry card that mirrors the layout of [EntryCard].
class SkeletonEntryCard extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const SkeletonEntryCard({
    super.key,
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and Mood row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Skeleton(width: 60, height: 12),
                Skeleton(
                  width: 24,
                  height: 24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            // Title
            const Skeleton(width: 140, height: 16),
            const SizedBox(height: AppTheme.spacingSmall),
            // Content Lines
            const Skeleton(width: double.infinity, height: 14),
            const SizedBox(height: AppTheme.spacingExtraSmall),
            const Skeleton(width: double.infinity, height: 14),
            const SizedBox(height: AppTheme.spacingExtraSmall),
            const Skeleton(width: 100, height: 14),
            const SizedBox(height: AppTheme.spacingSmall),
            // Tags Row
            Row(
              children: [
                Skeleton(
                  width: 50,
                  height: 18,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingExtraSmall),
                Skeleton(
                  width: 65,
                  height: 18,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 4),
                const Skeleton(width: 90, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for [TimelineScreen].
class TimelineScreenSkeleton extends StatelessWidget {
  const TimelineScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        final isFirst = index == 0;
        final isLast = index == 3;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TimelineNode(
                isFirst: isFirst,
                isLast: isLast,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 4),
                      child: Skeleton(width: 80, height: 14),
                    ),
                    Expanded(
                      child: SkeletonEntryCard(
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A generic skeleton list of cards, used for Archive and Trash screens.
class EntryListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool showActions;

  const EntryListSkeleton({
    super.key,
    this.itemCount = 3,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              const SkeletonEntryCard(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (showActions)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Skeleton(width: 80, height: 28),
                      SizedBox(width: 8),
                      Skeleton(width: 100, height: 28),
                    ],
                  ),
                ),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton loader for the Calendar Screen.
class CalendarScreenSkeleton extends StatelessWidget {
  const CalendarScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Simulated Calendar view (large header box)
        Container(
          margin: const EdgeInsets.all(16),
          height: 280,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 100, height: 20),
                    Row(
                      children: [
                        Skeleton(width: 28, height: 28),
                        SizedBox(width: 16),
                        Skeleton(width: 28, height: 28),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Calendar days header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    7,
                    (_) => const Skeleton(width: 24, height: 12),
                  ),
                ),
                const SizedBox(height: 16),
                // Calendar grid rows
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (_) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          7,
                          (_) => Skeleton(
                            width: 24,
                            height: 24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
        // Bottom entries skeleton list
        const Expanded(
          child: EntryListSkeleton(itemCount: 1, showActions: false),
        ),
      ],
    );
  }
}

/// Skeleton loader for the Media Screen.
class MediaScreenSkeleton extends StatelessWidget {
  const MediaScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
            child: Stack(
              children: [
                const Positioned.fill(child: Skeleton()),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black38,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: const Skeleton(width: 80, height: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader for the Analytics Screen.
class AnalyticsScreenSkeleton extends StatelessWidget {
  const AnalyticsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Two summary cards
        Row(
          children: [
            Expanded(
              child: _buildCardSkeleton(
                context,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 24, height: 24),
                    SizedBox(height: 12),
                    Skeleton(width: 40, height: 24),
                    SizedBox(height: 6),
                    Skeleton(width: 70, height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardSkeleton(
                context,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 24, height: 24),
                    SizedBox(height: 12),
                    Skeleton(width: 50, height: 24),
                    SizedBox(height: 6),
                    Skeleton(width: 70, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Mood distribution skeleton header
        const Skeleton(width: 130, height: 16),
        const SizedBox(height: 8),
        _buildCardSkeleton(
          context,
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Skeleton(
                      width: 24,
                      height: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Skeleton(height: 8)),
                    const SizedBox(width: 12),
                    const Skeleton(width: 30, height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Tag distribution skeleton header
        const Skeleton(width: 120, height: 16),
        const SizedBox(height: 8),
        _buildCardSkeleton(
          context,
          child: Column(
            children: List.generate(
              2,
              (index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Skeleton(width: 16, height: 16),
                    SizedBox(width: 8),
                    Expanded(flex: 3, child: Skeleton(height: 12)),
                    SizedBox(width: 12),
                    Expanded(flex: 5, child: Skeleton(height: 8)),
                    SizedBox(width: 12),
                    Skeleton(width: 45, height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Weekly activity skeleton header
        const Skeleton(width: 110, height: 16),
        const SizedBox(height: 8),
        _buildCardSkeleton(
          context,
          child: SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (index) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Skeleton(
                      width: 20,
                      height: (20 * (index % 3 + 1) + 20).toDouble(),
                    ),
                    const SizedBox(height: 8),
                    const Skeleton(width: 12, height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Insights skeleton card
        _buildCardSkeleton(
          context,
          child: const Row(
            children: [
              Skeleton(width: 20, height: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 4),
                    Skeleton(width: 180, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardSkeleton(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

/// Skeleton loader for the Settings Screen.
class SettingsScreenSkeleton extends StatelessWidget {
  const SettingsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: AppTheme.spacingSmall),
        _buildHeaderSkeleton(),
        _buildCardSkeleton([_buildItemSkeleton(hasAvatar: true)]),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildHeaderSkeleton(),
        _buildCardSkeleton([
          _buildItemSkeleton(hasToggle: true, showDivider: true),
          _buildItemSkeleton(hasDropdown: true),
        ]),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildHeaderSkeleton(),
        _buildCloudSyncCardSkeleton(context),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Skeleton(width: 90, height: 12),
    );
  }

  Widget _buildCardSkeleton(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildItemSkeleton({
    bool hasAvatar = false,
    bool hasToggle = false,
    bool hasDropdown = false,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (hasAvatar)
                Skeleton(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20),
                )
              else
                const Skeleton(width: 40, height: 40),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 120, height: 16),
                    SizedBox(height: 6),
                    Skeleton(width: 180, height: 12),
                  ],
                ),
              ),
              if (hasToggle)
                const Skeleton(width: 34, height: 20)
              else if (hasDropdown)
                const Skeleton(width: 60, height: 24)
              else
                const Skeleton(width: 24, height: 24),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildCloudSyncCardSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 80, height: 16),
                    SizedBox(height: 6),
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 4),
                    Skeleton(width: 200, height: 14),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Skeleton(width: 34, height: 20),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.15),
            height: 1,
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Skeleton(width: 18, height: 18),
              SizedBox(width: 8),
              Skeleton(width: 200, height: 14),
            ],
          ),
          const SizedBox(height: 12),
          const Skeleton(width: double.infinity, height: 44),
        ],
      ),
    );
  }
}

/// Skeleton loader for the Info Screen (Help / About).
class InfoScreenSkeleton extends StatelessWidget {
  const InfoScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: Skeleton(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        const SizedBox(height: 24),
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 120, height: 16),
                    SizedBox(height: 12),
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    Skeleton(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    Skeleton(width: 180, height: 14),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton loader for search suggestions in [LocationSelectionSheet].
class LocationSuggestionsSkeleton extends StatelessWidget {
  const LocationSuggestionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Skeleton(width: 18, height: 18),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 180, height: 14),
                    SizedBox(height: 4),
                    Skeleton(width: 100, height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
