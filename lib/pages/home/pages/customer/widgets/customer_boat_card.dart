import 'package:flutter/material.dart';
import 'package:ocean_rent/core/theme/app_theme.dart';
import 'package:ocean_rent/models/boat_model.dart';
import 'package:ocean_rent/pages/home/pages/customer/pages/customer_boat_detail_page.dart';
import 'package:ocean_rent/utils/boat_utils.dart';
import 'package:ocean_rent/widgets/boat_image_placeholder.dart';

class CustomerBoatCard extends StatelessWidget {
  final BoatModel boat;

  const CustomerBoatCard({super.key, required this.boat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppTheme.borderRadiusCard,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CustomerBoatDetailPage(boat: boat)),
        );
      },

      child: Container(
        margin: AppTheme.cardBottomMargin,
        decoration: AppTheme.cardDecoration(
          color: AppTheme.surface,
          radius: AppTheme.radiusCard,
          border: Border.all(color: AppTheme.deepNavy.withValues(alpha: AppTheme.alphaSoft)),
          boxShadow: AppTheme.softShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppTheme.borderRadiusCardTop,
              child: boat.imageUrl.isNotEmpty
                  ? Image.network(
                      boat.imageUrl,
                      height: AppTheme.customerBoatImageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => BoatImagePlaceholder(
                        name: boat.name,
                        height: AppTheme.customerBoatImageHeight,
                        iconSize: AppTheme.emptyStateIconSize,
                      ),
                    )
                  : BoatImagePlaceholder(
                      name: boat.name,
                      height: AppTheme.customerBoatImageHeight,
                      iconSize: AppTheme.emptyStateIconSize,
                    ),
            ),
            Padding(
              padding: AppTheme.compactCardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(boat.name,style: AppTheme.titleLarge.copyWith(color: AppTheme.deepNavy,fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: AppTheme.spacing10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BoatInfoItem(
                              icon: Icons.directions_boat_outlined,
                              label: formatBoatCategory(boat.category),
                            ),
                            const SizedBox(height: AppTheme.spacing6),
                            _BoatInfoItem(
                              icon: Icons.location_on_outlined,
                              label: boat.portName.trim().isEmpty? 'Sin ubicación' : boat.portName.trim(),
                            ),
                            const SizedBox(height: AppTheme.spacing6),
                            _BoatInfoItem(
                              icon: Icons.people_outline,
                              label: boat.capacity <= 0
                                  ? 'Sin capacidad'
                                  : boat.capacity == 1
                                  ? '1 persona'
                                  : '${boat.capacity} personas',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing10),
                      Text(
                        '${boat.pricePerDay.toStringAsFixed(0)} €/día',
                        style: AppTheme.titleMedium.copyWith(color: AppTheme.deepNavy,fontWeight: FontWeight.w700)
                      ),
                    ],
                  ),
                  if (boat.requiredLicense.toLowerCase() != 'none') ...[
                    const SizedBox(height: AppTheme.spacing8),
                    _LicenseBadge(license: boat.requiredLicense),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoatInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BoatInfoItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppTheme.iconSizeMedium, color: AppTheme.oceanBlue),
        const SizedBox(width: AppTheme.spacing6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}

class _LicenseBadge extends StatelessWidget {
  final String license;

  const _LicenseBadge({required this.license});

  String _licenseLabel(String license) {
    switch (license.toLowerCase()) {
      case 'pbn':
        return 'Requiere licencia PBN';
      case 'per':
        return 'Requiere licencia PER';
      default:
        return 'Requiere licencia';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.sunsetGold.withValues(alpha: AppTheme.alphaLight),
        borderRadius: BorderRadius.circular(AppTheme.spacing6),
        border: Border.all(color: AppTheme.sunsetGold.withValues(alpha: AppTheme.alphaOverlay))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_outlined,
            size: AppTheme.iconSizeMedium,
            color: AppTheme.sunsetGold,
          ),
          const SizedBox(width: AppTheme.spacing4),
          Text( _licenseLabel(license), style: AppTheme.bodySmall.copyWith(color: AppTheme.sunsetGold,fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
