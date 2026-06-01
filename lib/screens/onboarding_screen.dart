import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'club_head_login_screen.dart';
import 'event_feed_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation1;
  late Animation<Offset> _slideAnimation2;
  int? _hoveredCard;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation1 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    _slideAnimation2 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo / brand area
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryTeal, AppColors.accentViolet],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 17,
                      ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primaryTeal, AppColors.accentViolet],
                  ).createShader(bounds),
                  child: Text(
                    'Campus Pulse',
                    style:
                        Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose your identity to get started.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 52),
                // Role cards
                SlideTransition(
                  position: _slideAnimation1,
                  child: _buildRoleCard(
                    index: 0,
                    icon: Icons.school_rounded,
                    iconBgColor: AppColors.primaryTealLight,
                    iconColor: AppColors.primaryTeal,
                    title: "I'm a Student",
                    subtitle:
                        'Discover clubs, attend events, track activities',
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const EventFeedScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SlideTransition(
                  position: _slideAnimation2,
                  child: _buildRoleCard(
                    index: 1,
                    icon: Icons.admin_panel_settings_rounded,
                    iconBgColor: AppColors.accentVioletLight,
                    iconColor: AppColors.accentViolet,
                    title: "I'm a Club Head",
                    subtitle: 'Manage events, broadcast updates',
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const ClubHeadLoginScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Campus Pulse v1.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary.withValues(alpha: 0.6),
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

  Widget _buildRoleCard({
    required int index,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isHovered = _hoveredCard == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCard = index),
      onExit: (_) => setState(() => _hoveredCard = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHovered
                  ? iconColor.withValues(alpha: 0.3)
                  : AppColors.borderGray,
              width: isHovered ? 1.5 : 1,
            ),
            boxShadow: isHovered ? AppShadows.medium : AppShadows.soft,
          ),
          transform: isHovered
              ? (Matrix4.identity()..setTranslationRaw(0.0, -2.0, 0.0))
              : Matrix4.identity(),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textTertiary,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isHovered ? iconColor : AppColors.iconGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
