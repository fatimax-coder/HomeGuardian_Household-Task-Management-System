import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Centralized visual photographic & illustration component for HomeGuardian
/// Uses high-quality realistic photographs with elegant fallback vectors
class AppIllustration extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallbackWidget;

  const AppIllustration({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackWidget,
  });

  /// Modern living room interior banner for the Dashboard Welcome card
  static Widget homeBanner({double height = 160}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/banner/home_interior.jpg',
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _VectorHomeBanner(height: height),
            ),
            // Subtle warm gradient overlay to integrate seamlessly with the Warm Minimalist theme
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.darkBrown.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Realistic Home Tasks & Cleaning photograph
  static Widget emptyTasks({double size = 96, double? width, double? height}) {
    final w = width ?? size;
    final h = height ?? size;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sand.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          'assets/images/tasks/cleaning.jpg',
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              Icons.checklist_rtl_rounded,
              size: (w < h ? w : h) * 0.55,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ),
    );
  }

  /// Realistic Modern Appliances Overview photograph
  static Widget emptyAppliances(
      {double size = 96, double? width, double? height}) {
    final w = width ?? size;
    final h = height ?? size;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sand.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          'assets/images/appliances/default_appliance.jpg',
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              Icons.kitchen_rounded,
              size: (w < h ? w : h) * 0.55,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ),
    );
  }

  /// Realistic Reminders & Documents/Calendar photograph
  static Widget emptyReminders(
      {double size = 96, double? width, double? height}) {
    final w = width ?? size;
    final h = height ?? size;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sand.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          'assets/images/reminders/documents_bills.jpg',
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              Icons.notifications_active_outlined,
              size: (w < h ? w : h) * 0.55,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ),
    );
  }

  /// Realistic Professional Service Technician photograph
  static Widget maintenance(
      {double size = 96, double? width, double? height}) {
    final w = width ?? size;
    final h = height ?? size;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sand.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          'assets/images/maintenance/technician.jpg',
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              Icons.engineering_outlined,
              size: (w < h ? w : h) * 0.55,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ),
    );
  }

  /// Realistic Family photograph for Household section
  static Widget family({double size = 96, double? width, double? height}) {
    final w = width ?? size;
    final h = height ?? size;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sand.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(
          'assets/images/household/family.jpg',
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              Icons.groups_outlined,
              size: (w < h ? w : h) * 0.55,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) =>
            fallbackWidget ??
            Container(
              width: width ?? 48,
              height: height ?? 48,
              color: AppColors.sand.withValues(alpha: 0.4),
              child: Icon(Icons.image_outlined,
                  size: (width ?? 48) * 0.5, color: AppColors.brown),
            ),
      ),
    );
  }
}

/// Fallback custom vector home banner
class _VectorHomeBanner extends StatelessWidget {
  final double height;
  const _VectorHomeBanner({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.sand.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: height * 0.45,
          color: AppColors.terracotta,
        ),
      ),
    );
  }
}

/// Dynamic appliance thumbnail based on appliance type/keywords
/// Uses real high-resolution product photography
class ApplianceThumbnail extends StatelessWidget {
  final String name;
  final String? brand;
  final double size;

  const ApplianceThumbnail({
    super.key,
    required this.name,
    this.brand,
    this.size = 64,
  });

  String _resolveAssetPath() {
    final query = '${name.toLowerCase()} ${brand?.toLowerCase() ?? ""}';
    if (query.contains('fridge') || query.contains('refrigerator')) {
      return 'assets/images/appliances/refrigerator.jpg';
    } else if (query.contains('wash') ||
        query.contains('laundry') ||
        query.contains('dryer')) {
      return 'assets/images/appliances/washing_machine.jpg';
    } else if (query.contains('ac') ||
        query.contains('air') ||
        query.contains('cool') ||
        query.contains('conditioner')) {
      return 'assets/images/appliances/air_conditioner.jpg';
    } else if (query.contains('micro') ||
        query.contains('wave') ||
        query.contains('oven')) {
      return 'assets/images/appliances/microwave.jpg';
    } else if (query.contains('tv') ||
        query.contains('television') ||
        query.contains('screen')) {
      return 'assets/images/appliances/television.jpg';
    }
    return 'assets/images/appliances/default_appliance.jpg';
  }

  IconData _resolveFallbackIcon() {
    final query = '${name.toLowerCase()} ${brand?.toLowerCase() ?? ""}';
    if (query.contains('fridge') || query.contains('refrigerator')) {
      return Icons.kitchen_outlined;
    } else if (query.contains('wash') || query.contains('laundry')) {
      return Icons.local_laundry_service_outlined;
    } else if (query.contains('ac') ||
        query.contains('air') ||
        query.contains('cool') ||
        query.contains('conditioner')) {
      return Icons.ac_unit_outlined;
    } else if (query.contains('micro') ||
        query.contains('wave') ||
        query.contains('oven')) {
      return Icons.microwave_outlined;
    } else if (query.contains('tv') || query.contains('television')) {
      return Icons.tv_outlined;
    }
    return Icons.devices_other_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final asset = _resolveAssetPath();
    final fallbackIcon = _resolveFallbackIcon();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.sand.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(
              fallbackIcon,
              color: AppColors.terracotta,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
