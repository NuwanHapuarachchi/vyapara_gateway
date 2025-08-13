import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/navigation_bar_provider.dart';
import '../../shared/widgets/animated_navigation_bars.dart';
import '../../shared/widgets/neumorphic_widgets.dart';

/// Demo screen to showcase and test different navigation bar styles
class NavigationBarDemoScreen extends ConsumerStatefulWidget {
  const NavigationBarDemoScreen({super.key});

  @override
  ConsumerState<NavigationBarDemoScreen> createState() =>
      _NavigationBarDemoScreenState();
}

class _NavigationBarDemoScreenState
    extends ConsumerState<NavigationBarDemoScreen> {
  int _currentIndex = 2; // Start at home
  NavigationBarType? _demoType; // For temporary preview

  final List<_PageInfo> _pages = [
    _PageInfo(
      title: 'Applications',
      icon: Icons.folder,
      color: const Color(0xFF092F63),
      bgColor: const Color(0xFFBBD8FF),
    ),
    _PageInfo(
      title: 'Notifications',
      icon: Icons.notifications,
      color: const Color(0xFFEA580C),
      bgColor: const Color(0xFFFFF7ED),
    ),
    _PageInfo(
      title: 'Home',
      icon: Icons.home,
      color: AppColors.accent,
      bgColor: AppColors.accent.withOpacity(0.1),
    ),
    _PageInfo(
      title: 'Community',
      icon: Icons.people,
      color: const Color(0xFF6B7280),
      bgColor: const Color(0xFFDCE2E3),
    ),
    _PageInfo(
      title: 'Settings',
      icon: Icons.settings,
      color: const Color(0xFFDC2626),
      bgColor: const Color(0xFFFEE2E2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationType = _demoType ?? ref.watch(navigationBarTypeProvider);
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Navigation Bar Demo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _demoType = null;
                _currentIndex = 2;
              });
            },
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Style Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Navigation Style',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: NavigationBarType.values.map((type) {
                      final isSelected = type == navigationType;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(_getTypeName(type)),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _demoType = type;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (_demoType != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Preview mode. Go to Settings to save your preference.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Current Page Display
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_currentIndex),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: currentPage.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentPage.icon,
                        size: 60,
                        color: currentPage.color,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      currentPage.title,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.headlineLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Page ${_currentIndex + 1} of ${_pages.length}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Features Info
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      tint: currentPage.color,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Navigation Features',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem('✨ Smooth animations on tap'),
                          _buildFeatureItem('🎨 Beautiful visual effects'),
                          _buildFeatureItem('📱 Haptic feedback support'),
                          _buildFeatureItem('🌙 Dark mode compatible'),
                          _buildFeatureItem('♿ Accessibility ready'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(navigationType),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildNavigationBar(NavigationBarType? type) {
    switch (type) {
      case NavigationBarType.fluidGlass:
        return FluidGlassNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      case NavigationBarType.bubble:
        return BubbleNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      case NavigationBarType.neumorphic:
      case null:
      default:
        return NeumorphicBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
    }
  }

  String _getTypeName(NavigationBarType type) {
    switch (type) {
      case NavigationBarType.neumorphic:
        return 'Classic';
      case NavigationBarType.fluidGlass:
        return 'Fluid Glass';
      case NavigationBarType.bubble:
        return 'Bubble';
    }
  }
}

class _PageInfo {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _PageInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
