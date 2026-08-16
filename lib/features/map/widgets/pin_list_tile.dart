import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../models/pin.dart';
import '../providers/pins_provider.dart';
import 'flair_style.dart';

/// Card-style list tile for a single [Pin], matching the visual language
/// established by FeedPostMockCard (rounded 16px corners, white fill,
/// hairline border, soft shadow, flair chip top-left, timestamp top-right).
class PinListTile extends ConsumerStatefulWidget {
  const PinListTile({super.key, required this.pin});

  final Pin pin;

  @override
  ConsumerState<PinListTile> createState() => _PinListTileState();
}

class _PinListTileState extends ConsumerState<PinListTile> {
  bool _upvoting = false;

  Future<void> _handleUpvote() async {
    if (_upvoting) return;
    setState(() => _upvoting = true);
    try {
      await ref.read(pinsProvider.notifier).upvote(widget.pin.id);
    } catch (_) {
      // Best-effort — the list simply won't reflect the new count; a future
      // refresh will reconcile it. No need to surface a SnackBar for this.
    } finally {
      if (mounted) setState(() => _upvoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pin = widget.pin;
    final color = flairColor(pin.flair);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${flairEmoji(pin.flair)} ${pin.flair}',
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Text(
                _relativeTimeLabel(pin.createdAtTime),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pin.text,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: _handleUpvote,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _upvoting ? Icons.check : Icons.arrow_upward,
                        size: 16,
                        color: _upvoting ? AppColors.semanticChill : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pin.upvotes}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _relativeTimeLabel(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
