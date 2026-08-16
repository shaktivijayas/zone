import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pins_provider.dart';
import 'flair_style.dart';

/// Fixed campus-center coordinate used whenever live location is denied or
/// unavailable (permission refused, service disabled, platform channel
/// missing in tests, etc.) — location capture must never block submission.
const double kCampusCenterLat = 13.0827;
const double kCampusCenterLng = 80.2707;

/// Bottom-sheet content for composing a new map pin: text, an optional
/// flair selection (server auto-suggests one when omitted), and a submit
/// button that captures the device's current location behind the scenes.
class PinComposerSheet extends ConsumerStatefulWidget {
  const PinComposerSheet({super.key});

  @override
  ConsumerState<PinComposerSheet> createState() => _PinComposerSheetState();
}

class _PinComposerSheetState extends ConsumerState<PinComposerSheet> {
  final _textController = TextEditingController();
  String? _selectedFlair;
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<(double, double)> _resolveLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return (kCampusCenterLat, kCampusCenterLng);
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (kCampusCenterLat, kCampusCenterLng);
      }
      final position = await Geolocator.getCurrentPosition();
      return (position.latitude, position.longitude);
    } catch (_) {
      // Any platform-channel failure (denied, disabled, unavailable in
      // tests, etc.) falls back to campus center rather than blocking.
      return (kCampusCenterLat, kCampusCenterLng);
    }
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    try {
      final (lat, lng) = await _resolveLocation();
      await ref.read(pinsProvider.notifier).createPin(
        text: text,
        lat: lat,
        lng: lng,
        flair: _selectedFlair,
      );
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Drop a pin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your current location is attached automatically.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 4,
            maxLength: 280,
            decoration: InputDecoration(
              hintText: "What's happening?",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kPinFlairs.map((flair) {
              final selected = _selectedFlair == flair;
              final color = flairColor(flair);
              return ChoiceChip(
                label: Text('${flairEmoji(flair)} $flair'),
                selected: selected,
                onSelected: (isSelected) {
                  setState(() => _selectedFlair = isSelected ? flair : null);
                },
                labelStyle: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                selectedColor: color,
                backgroundColor: color.withValues(alpha: 0.1),
                side: BorderSide(color: color.withValues(alpha: 0.3)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ctaBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Drop pin'),
            ),
          ),
        ],
      ),
    );
  }
}
