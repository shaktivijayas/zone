import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'providers/pins_provider.dart';
import 'widgets/pin_composer_sheet.dart';
import 'widgets/pin_list_tile.dart';

/// The Map tab: a functional, data-complete pin feed for the campus map.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinsAsync = ref.watch(pinsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      // TODO(map-visual): replace ListView with GoogleMap once GOOGLE_MAPS_API_KEY is wired into AndroidManifest.xml
      body: RefreshIndicator(
        onRefresh: () => ref.read(pinsProvider.notifier).refresh(),
        child: pinsAsync.when(
          data: (pins) {
            if (pins.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(
                    child: Text(
                      'No pins yet — be the first to drop one',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: pins.length,
              itemBuilder: (context, index) => PinListTile(pin: pins[index]),
            );
          },
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, stackTrace) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 140),
              Center(
                child: Text(
                  'Couldn\'t load pins. Pull to try again.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ctaBlack,
        foregroundColor: Colors.white,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const PinComposerSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
