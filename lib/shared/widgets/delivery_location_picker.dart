import 'package:flutter/material.dart';

import '../../core/geo/nouakchott_neighborhoods.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/heyn_theme.dart';
import '../models/delivery_location.dart';

class DeliveryLocationPicker extends StatefulWidget {
  const DeliveryLocationPicker({
    super.key,
    required this.location,
    required this.onChanged,
    this.compact = false,
  });

  final DeliveryLocation location;
  final ValueChanged<DeliveryLocation> onChanged;
  final bool compact;

  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  late final TextEditingController _landmarkController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _landmarkController = TextEditingController(text: widget.location.landmark);
    _phoneController = TextEditingController(text: widget.location.phone);
  }

  @override
  void didUpdateWidget(covariant DeliveryLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location.landmark != widget.location.landmark &&
        _landmarkController.text != widget.location.landmark) {
      _landmarkController.text = widget.location.landmark;
    }
    if (oldWidget.location.phone != widget.location.phone &&
        _phoneController.text != widget.location.phone) {
      _phoneController.text = widget.location.phone;
    }
  }

  @override
  void dispose() {
    _landmarkController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _selectNeighborhood(NouakchottNeighborhood neighborhood) {
    widget.onChanged(
      widget.location.copyWith(
        neighborhood: neighborhood.name,
        latitude: neighborhood.latitude,
        longitude: neighborhood.longitude,
      ),
    );
  }

  void _movePin(Offset localPosition, Size size) {
    final dx = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final dy = (localPosition.dy / size.height).clamp(0.0, 1.0);
    final longitude =
        NouakchottMapBounds.minLongitude +
        (NouakchottMapBounds.maxLongitude - NouakchottMapBounds.minLongitude) *
            dx;
    final latitude =
        NouakchottMapBounds.maxLatitude -
        (NouakchottMapBounds.maxLatitude - NouakchottMapBounds.minLatitude) *
            dy;

    NouakchottNeighborhood nearest = nouakchottNeighborhoods.first;
    var bestDistance = double.infinity;
    for (final neighborhood in nouakchottNeighborhoods) {
      final distance =
          (neighborhood.latitude - latitude).abs() +
          (neighborhood.longitude - longitude).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        nearest = neighborhood;
      }
    }

    widget.onChanged(
      widget.location.copyWith(
        neighborhood: nearest.name,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deliveryLocationTitle,
          style: HeynTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(l10n.deliveryLocationSubtitle, style: HeynTextStyles.subtitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: nouakchottNeighborhoods.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final neighborhood = nouakchottNeighborhoods[index];
              return _NeighborhoodChip(
                label: neighborhood.name,
                selected: widget.location.neighborhood == neighborhood.name,
                onTap: () => _selectNeighborhood(neighborhood),
              );
            },
          ),
        ),
        if (!widget.compact) ...[
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const height = 180.0;
              final size = Size(constraints.maxWidth, height);
              final dx =
                  ((widget.location.longitude -
                              NouakchottMapBounds.minLongitude) /
                          (NouakchottMapBounds.maxLongitude -
                              NouakchottMapBounds.minLongitude))
                      .clamp(0.0, 1.0);
              final dy =
                  ((NouakchottMapBounds.maxLatitude -
                              widget.location.latitude) /
                          (NouakchottMapBounds.maxLatitude -
                              NouakchottMapBounds.minLatitude))
                      .clamp(0.0, 1.0);

              return GestureDetector(
                onTapDown: (details) => _movePin(details.localPosition, size),
                onPanUpdate: (details) => _movePin(details.localPosition, size),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: height,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE8F5E9),
                                Color(0xFFE0F2F1),
                                Color(0xFFFFF8E1),
                              ],
                            ),
                          ),
                          child: SizedBox.expand(),
                        ),
                        Positioned(
                          left: size.width * 0.08,
                          top: 28,
                          child: const _MapBlob(
                            width: 90,
                            height: 54,
                            color: Color(0xFFC8E6C9),
                          ),
                        ),
                        Positioned(
                          right: 18,
                          top: 18,
                          child: const _MapBlob(
                            width: 120,
                            height: 70,
                            color: Color(0xFFB2DFDB),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          bottom: 16,
                          child: const _MapBlob(
                            width: 150,
                            height: 40,
                            color: Color(0xFFFFE0B2),
                          ),
                        ),
                        const Positioned(
                          left: 12,
                          bottom: 10,
                          child: Text(
                            'Google',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Positioned(
                          left: dx * size.width - 18,
                          top: dy * size.height - 34,
                          child: const Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: HeynColors.turquoise,
                                size: 34,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: (dx * size.width).clamp(8.0, size.width - 110),
                          top: (dy * size.height + 4).clamp(
                            8.0,
                            size.height - 28,
                          ),
                          child: const Text(
                            'Nouakchott',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
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
        ],
        const SizedBox(height: 14),
        HeynSilverField(
          fieldKey: const Key('checkout-landmark'),
          controller: _landmarkController,
          hintText: l10n.deliveryLandmark,
          icon: Icons.location_on_outlined,
          onChanged: (value) =>
              widget.onChanged(widget.location.copyWith(landmark: value)),
        ),
        const SizedBox(height: 12),
        HeynSilverField(
          fieldKey: const Key('checkout-phone'),
          controller: _phoneController,
          hintText: l10n.deliveryPhoneNumber,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onChanged: (value) =>
              widget.onChanged(widget.location.copyWith(phone: value)),
        ),
      ],
    );
  }
}

class _NeighborhoodChip extends StatelessWidget {
  const _NeighborhoodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HeynSelectionChip(label: label, selected: selected, onTap: onTap);
  }
}

class _MapBlob extends StatelessWidget {
  const _MapBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}
