import 'package:flutter/widgets.dart';
import 'widgets/map_pin_mock_card.dart';
import 'widgets/feed_post_mock_card.dart';
import 'widgets/showcase_mock_card.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.heading,
    required this.subtext,
    required this.mockCard,
  });

  final String heading;
  final String subtext;
  final Widget mockCard;
}

final onboardingSlides = <OnboardingSlide>[
  const OnboardingSlide(
    heading: 'Your campus.\nUnfiltered.',
    subtext: 'Anonymous pins on the map to keep everyone informed.',
    mockCard: MapPinMockCard(),
  ),
  const OnboardingSlide(
    heading: 'Say what\nyou think.',
    subtext: 'Share updates, ask questions and help your peers.',
    mockCard: FeedPostMockCard(),
  ),
  const OnboardingSlide(
    heading: 'Learn. Build.\nShow off.',
    subtext: 'Discover projects, get help and grow together.',
    mockCard: ShowcaseMockCard(),
  ),
];
