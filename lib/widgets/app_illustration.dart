import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Centralized visual illustration component for HomeGuardian
/// Uses local asset images with graceful fallback to styled vector painters
class AppIllustration extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallbackWidget;

  const AppIllustration({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackWidget,
  });

  /// Welcome Home Banner
  static Widget homeBanner({double height = 140}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/illustrations/home_banner.png',
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _VectorHomeBanner(height: height),
      ),
    );
  }

  /// Empty Tasks State
  static Widget emptyTasks({double size = 110}) {
    return Image.asset(
      'assets/illustrations/empty_tasks.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.checklist_rtl_rounded,
        size: size * 0.7,
        color: AppColors.sand,
      ),
    );
  }

  /// Empty Appliances State
  static Widget emptyAppliances({double size = 110}) {
    return Image.asset(
      'assets/illustrations/empty_appliances.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.kitchen_rounded,
        size: size * 0.7,
        color: AppColors.sand,
      ),
    );
  }

  /// Empty Reminders State
  static Widget emptyReminders({double size = 110}) {
    return Image.asset(
      'assets/illustrations/empty_reminders.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.notifications_off_outlined,
        size: size * 0.7,
        color: AppColors.sand,
      ),
    );
  }

  /// Maintenance Service Illustration
  static Widget maintenance({double size = 110}) {
    return Image.asset(
      'assets/illustrations/maintenance_service.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.build_circle_outlined,
        size: size * 0.7,
        color: AppColors.terracotta,
      ),
    );
  }

  /// Family & Household Illustration
  static Widget family({double size = 110}) {
    return Image.asset(
      'assets/illustrations/family_household.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.family_restroom,
        size: size * 0.7,
        color: AppColors.terracotta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) =>
          fallbackWidget ??
          Icon(Icons.image, size: width ?? 48, color: AppColors.sand),
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
      return 'assets/images/appliances/refrigerator.png';
    } else if (query.contains('wash') || query.contains('laundry')) {
      return 'assets/images/appliances/washing_machine.png';
    } else if (query.contains('ac') ||
        query.contains('air') ||
        query.contains('cool') ||
        query.contains('conditioner')) {
      return 'assets/images/appliances/air_conditioner.png';
    } else if (query.contains('micro') ||
        query.contains('wave') ||
        query.contains('oven')) {
      return 'assets/images/appliances/microwave.png';
    }
    return 'assets/images/appliances/default_appliance.png';
  }

  IconData _resolveFallbackIcon() {
    final query = '${name.toLowerCase()} ${brand?.toLowerCase() ?? ""}';
    if (query.contains('fridge') || query.contains('refrigerator')) {
      return Icons.kitchen;
    } else if (query.contains('wash') || query.contains('laundry')) {
      return Icons.local_laundry_service;
    } else if (query.contains('ac') ||
        query.contains('air') ||
        query.contains('cool') ||
        query.contains('conditioner')) {
      return Icons.ac_unit;
    } else if (query.contains('micro') ||
        query.contains('wave') ||
        query.contains('oven')) {
      return Icons.microwave;
    }
    return Icons.devices_other;
  }

  @override
  Widget build(BuildContext context) {
    final asset = _resolveAssetPath();
    final fallbackIcon = _resolveFallbackIcon();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.sand.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sand, width: 1.2),
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
