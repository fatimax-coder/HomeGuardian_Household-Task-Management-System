import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';

/// Screen: SplashView
/// Premium, modern splash screen featuring a 10-second countdown,
/// interactive promotional card, tap-anywhere skipping, and key feature highlights.
class SplashView extends StatefulWidget {
  final VoidCallback? onTimeout;

  const SplashView({super.key, this.onTimeout});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const int _totalSeconds = 10;
  int _secondsRemaining = _totalSeconds;
  Timer? _timer;
  bool _hasNavigated = false;
  bool _showPromoCard = true;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
        });
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _timer?.cancel();

    if (widget.onTimeout != null) {
      widget.onTimeout!();
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.authGate);
    }
  }

  void _showLearnMoreDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.hub_outlined, color: AppColors.terracotta, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Smart Home, Better Life',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HomeGuardian connects all your appliances, household members, and maintenance schedules into one centralized dashboard.',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            SizedBox(height: 12),
            Text(
              '• Automated warranty expiry tracking\n'
              '• Family chore assignment & reminders\n'
              '• Real-time service history and cost ledger',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Got It',
              style: TextStyle(
                color: AppColors.terracotta,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNext,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---------------------------------------------------
                        // Top Bar: Timer and Skip Prompt
                        // ---------------------------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.sand.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.touch_app_outlined,
                                      size: 15, color: AppColors.brown),
                                  SizedBox(width: 5),
                                  Text(
                                    'Tap anywhere to continue',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Circular Countdown Timer
                            _buildCircularTimer(),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // ---------------------------------------------------
                        // Hero Header: Home Interior Photo + Branding
                        // ---------------------------------------------------
                        _buildHeroBanner(),
                        const SizedBox(height: 20),

                        // ---------------------------------------------------
                        // Promotional Card (Dismissible)
                        // ---------------------------------------------------
                        if (_showPromoCard) ...[
                          _buildPromotionalCard(),
                          const SizedBox(height: 20),
                        ],

                        // ---------------------------------------------------
                        // 4 Bottom Features Grid
                        // ---------------------------------------------------
                        _buildFeaturesGrid(),
                        const SizedBox(height: 16),

                        // Tap anywhere footer indicator
                        const Center(
                          child: Text(
                            'Tap anywhere to continue',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Circular Countdown Timer Widget
  Widget _buildCircularTimer() {
    final progress = _secondsRemaining / _totalSeconds;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.2,
            backgroundColor: AppColors.sand.withValues(alpha: 0.6),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.terracotta),
          ),
          Text(
            '$_secondsRemaining',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  /// Realistic Home Interior Hero Banner with Logo & Tagline
  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.sand.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photographic Living Room Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/banner/home_interior.jpg',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: AppColors.sand,
                    child: const Center(
                      child: Icon(Icons.home,
                          size: 48, color: AppColors.terracotta),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.darkBrown.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Branding & Tagline Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Logo Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.sand.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.sand,
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.terracotta,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title and Tagline
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HomeGuardian',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'A Smarter Way to Manage Your Home.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Promotional Popup Card
  Widget _buildPromotionalCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.terracotta.withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracotta.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Home Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/promotions/smart_hub.jpg',
                width: 78,
                height: 78,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 78,
                  height: 78,
                  color: AppColors.sand.withValues(alpha: 0.5),
                  child: const Icon(Icons.devices,
                      color: AppColors.terracotta, size: 36),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Offer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Special Offer',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracotta,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      // Close (X) button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPromoCard = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.sand.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.darkBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Smart Home, Better Life.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Discover features that make home management easier.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Learn More Button
                  ElevatedButton(
                    onPressed: _showLearnMoreDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      minimumSize: const Size(0, 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4 Bottom Feature Highlights Grid
  Widget _buildFeaturesGrid() {
    final features = [
      (
        icon: Icons.verified_user_outlined,
        title: 'Secure & Reliable',
        desc: 'Protected by Supabase',
      ),
      (
        icon: Icons.home_work_outlined,
        title: 'Manage Your Home',
        desc: 'Central appliance hub',
      ),
      (
        icon: Icons.notifications_active_outlined,
        title: 'Get Timely Reminders',
        desc: 'Never miss warranties',
      ),
      (
        icon: Icons.family_restroom_outlined,
        title: 'Keep Family Connected',
        desc: 'Shared chores & roles',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final f = features[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.sand.withValues(alpha: 0.7),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.sand.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(f.icon, size: 18, color: AppColors.terracotta),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    Text(
                      f.desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
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

