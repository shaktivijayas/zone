# ZONE App Shell + Splash + Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up a running Flutter app (`shaktivijayas/zone`) with theming, device identity, routing, and three working screens — Splash, 3-slide Onboarding, and a placeholder 4-tab Main Shell — matching the light-theme reference screenshot, verified in Chrome.

**Architecture:** Flutter + `flutter_riverpod` for state, `go_router` for navigation across `/splash`, `/onboarding`, `/home`. Feature code under `lib/features/{splash,onboarding,shell}`, cross-cutting concerns under `lib/core/{theme,device,prefs,router}`. Pure logic (device hashing, onboarding-complete flag) gets plain Dart unit tests; screens get Flutter widget tests using a test-local `GoRouter` so navigation assertions don't need the full app.

**Tech Stack:** Flutter (stable channel, cloned to `C:\src\flutter`), Dart, `flutter_riverpod`, `go_router`, `google_fonts`, `shared_preferences`, `uuid`, `crypto`, `flutter_test`.

## Global Constraints

- Flutter SDK lives at `C:\src\flutter` (stable channel) — not yet on PATH permanently; Task 1 fixes that.
- Package/project name: `zone` (so imports are `package:zone/...`). Org: `com.chennaicit.zone`.
- Target platforms for `flutter create`: `android,ios,web` (matches the original spec's Android+iOS target, plus web for local verification — no Android/iOS SDK needed just to scaffold or run on web).
- Every new widget/screen uses the color/text tokens from Task 1 (`AppColors`, `AppTextStyles`) — no raw hex colors in feature code, except inside the explicitly-decorative placeholder-image gradients called out in the design spec.
- Design spec is authoritative for copy, layout, and colors: `docs/superpowers/specs/2026-07-24-app-shell-splash-onboarding-design.md`.
- Every task ends with `flutter analyze` clean (no new errors/warnings) and its own test file passing via `flutter test <path>`.
- Commit after every task. Push to the `shaktivijayas/zone` GitHub remote (created in Task 1) after every commit.
- GitHub CLI (`gh`) is authenticated as `shaktivijayas` at `C:\Program Files\GitHub CLI\gh.exe`.

---

### Task 1: Flutter project bootstrap, theme tokens, GitHub repo

**Files:**
- Create: `pubspec.yaml` and full `flutter create` scaffold (via CLI, not hand-written)
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_text_styles.dart`
- Create: `lib/core/theme/app_theme.dart`
- Test: `test/core/theme/app_colors_test.dart`

**Interfaces:**
- Consumes: nothing (first task)
- Produces: `AppColors` (static const `Color` fields: `background`, `textPrimary`, `textSecondary`, `cardBorder`, `cardFill`, `ctaBlack`, `semanticAlert`, `semanticHot`, `semanticInfo`, `semanticChill`, `navActive`, `navInactive`), `AppTextStyles` (static getters: `headingDisplay`, `bodyRegular`, `bodySmallSecondary`, all returning `TextStyle`), `AppTheme.light` (a `ThemeData` getter). GitHub remote `origin` pointing at `https://github.com/shaktivijayas/zone.git`.

- [ ] **Step 1: Put Flutter on PATH permanently and verify**

```powershell
setx PATH "$($env:PATH);C:\src\flutter\bin"
```

Then open a fresh terminal (or use the full path directly in this same session) and run:

```bash
"/c/src/flutter/bin/flutter" --version
```

Expected: prints a Flutter/Dart version banner (stable channel), no errors.

- [ ] **Step 2: Scaffold the Flutter project in place**

```bash
cd "/c/Users/shakthi/Documents/zone"
"/c/src/flutter/bin/flutter" create --project-name zone --org com.chennaicit.zone --platforms=android,ios,web .
```

Expected: Flutter reports "Wrote N files" and does not overwrite `docs/`, `.superpowers/`, or `.git/` (it only adds `lib/`, `pubspec.yaml`, `test/`, platform folders, `.gitignore`, `analysis_options.yaml`).

- [ ] **Step 3: Add extra dependencies**

```bash
cd "/c/Users/shakthi/Documents/zone"
"/c/src/flutter/bin/flutter" pub add flutter_riverpod go_router google_fonts shared_preferences uuid crypto
```

Expected: `pubspec.yaml` gains these five entries under `dependencies:`; command exits 0.

- [ ] **Step 4: Write the failing test for theme tokens**

Create `test/core/theme/app_colors_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zone/core/theme/app_colors.dart';

void main() {
  test('token values match the design spec', () {
    expect(AppColors.background, const Color(0xFFFAFAFA));
    expect(AppColors.textPrimary, const Color(0xFF111111));
    expect(AppColors.textSecondary, const Color(0xFF6B7280));
    expect(AppColors.cardBorder, const Color(0xFFE5E7EB));
    expect(AppColors.cardFill, const Color(0xFFFFFFFF));
    expect(AppColors.ctaBlack, const Color(0xFF111111));
    expect(AppColors.semanticAlert, const Color(0xFFDC2626));
    expect(AppColors.semanticHot, const Color(0xFFEA580C));
    expect(AppColors.semanticInfo, const Color(0xFFD97706));
    expect(AppColors.semanticChill, const Color(0xFF16A34A));
    expect(AppColors.navActive, const Color(0xFF111111));
    expect(AppColors.navInactive, const Color(0xFF9CA3AF));
  });
}
```

- [ ] **Step 5: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/core/theme/app_colors_test.dart
```

Expected: FAIL — `Error: Couldn't resolve the package 'zone'` or `Target of URI doesn't exist: 'package:zone/core/theme/app_colors.dart'` (the file doesn't exist yet).

- [ ] **Step 6: Implement the theme token files**

Create `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFFAFAFA);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF6B7280);
  static const cardBorder = Color(0xFFE5E7EB);
  static const cardFill = Color(0xFFFFFFFF);
  static const ctaBlack = Color(0xFF111111);

  static const semanticAlert = Color(0xFFDC2626);
  static const semanticHot = Color(0xFFEA580C);
  static const semanticInfo = Color(0xFFD97706);
  static const semanticChill = Color(0xFF16A34A);

  static const navActive = Color(0xFF111111);
  static const navInactive = Color(0xFF9CA3AF);
}
```

Create `lib/core/theme/app_text_styles.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headingDisplay => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 34 / 28,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyRegular => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 21 / 15,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmallSecondary => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 13,
        height: 18 / 13,
        color: AppColors.textSecondary,
      );
}
```

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ctaBlack,
      onPrimary: Colors.white,
      secondary: AppColors.textSecondary,
      onSecondary: Colors.white,
      error: AppColors.semanticAlert,
      onError: Colors.white,
      surface: AppColors.cardFill,
      onSurface: AppColors.textPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      dividerColor: AppColors.cardBorder,
    );
  }
}
```

- [ ] **Step 7: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/core/theme/app_colors_test.dart
```

Expected: PASS (1 test).

- [ ] **Step 8: Run analyzer on the whole project**

```bash
"/c/src/flutter/bin/flutter" analyze
```

Expected: "No issues found!" (the default `flutter create` template's own `test/widget_test.dart` will fail to reference — delete it, since it references a default counter app that no longer matches our `main.dart` plan; it will be replaced by our own tests in later tasks):

```bash
rm test/widget_test.dart
```

- [ ] **Step 9: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add -A
git commit -m "Bootstrap Flutter project with theme tokens"
```

- [ ] **Step 10: Create the GitHub repo and push**

```bash
"/c/Program Files/GitHub CLI/gh.exe" repo create shaktivijayas/zone --public --source=. --remote=origin --push
```

Expected: prints the new repo URL (`https://github.com/shaktivijayas/zone`) and pushes `main` (and other local branches) successfully.

---

### Task 2: OnboardingPrefs helper

**Files:**
- Create: `lib/core/prefs/onboarding_prefs.dart`
- Test: `test/core/prefs/onboarding_prefs_test.dart`

**Interfaces:**
- Consumes: `shared_preferences` package (`SharedPreferences` instance passed in by caller)
- Produces: `OnboardingPrefs` class with constructor `OnboardingPrefs(SharedPreferences prefs)`, method `bool isOnboardingComplete()`, method `Future<void> setOnboardingComplete()`. Later tasks (Splash, Onboarding screens) depend on these exact names.

- [ ] **Step 1: Write the failing test**

Create `test/core/prefs/onboarding_prefs_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/prefs/onboarding_prefs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isOnboardingComplete defaults to false', () async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingPrefs = OnboardingPrefs(prefs);

    expect(onboardingPrefs.isOnboardingComplete(), isFalse);
  });

  test('setOnboardingComplete persists true', () async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingPrefs = OnboardingPrefs(prefs);

    await onboardingPrefs.setOnboardingComplete();

    expect(onboardingPrefs.isOnboardingComplete(), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/core/prefs/onboarding_prefs_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:zone/core/prefs/onboarding_prefs.dart'`.

- [ ] **Step 3: Implement**

Create `lib/core/prefs/onboarding_prefs.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

const onboardingCompleteKey = 'zone_onboarding_complete';

class OnboardingPrefs {
  OnboardingPrefs(this._prefs);

  final SharedPreferences _prefs;

  bool isOnboardingComplete() {
    return _prefs.getBool(onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(onboardingCompleteKey, true);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/core/prefs/onboarding_prefs_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add lib/core/prefs/onboarding_prefs.dart test/core/prefs/onboarding_prefs_test.dart
git commit -m "Add OnboardingPrefs helper for onboarding-complete flag"
git push
```

---

### Task 3: DeviceService (UUID + hashing) with Riverpod providers

**Files:**
- Create: `lib/core/device/device_service.dart`
- Test: `test/core/device/device_service_test.dart`

**Interfaces:**
- Consumes: `shared_preferences`, `uuid`, `crypto` packages
- Produces: `DeviceService` class with constructor `DeviceService(SharedPreferences prefs)`, methods `Future<String> getOrCreateUuid()`, `String hashUuid(String uuid)`, `Future<String> getOrCreateHashedDeviceId()`. Riverpod providers: `sharedPreferencesProvider` (a `Provider<SharedPreferences>` that throws `UnimplementedError` until overridden — Task 8's `main.dart` overrides it), `deviceServiceProvider` (`Provider<DeviceService>`), `hashedDeviceIdProvider` (`FutureProvider<String>`). Later slices (Profile, karma) depend on these exact provider names.

- [ ] **Step 1: Write the failing test**

Create `test/core/device/device_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getOrCreateUuid generates and persists a uuid on first call', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = DeviceService(prefs);

    final first = await service.getOrCreateUuid();
    final second = await service.getOrCreateUuid();

    expect(first, isNotEmpty);
    expect(second, equals(first));
  });

  test('hashUuid produces a deterministic 16-character hash', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = DeviceService(prefs);

    final hash1 = service.hashUuid('11111111-1111-1111-1111-111111111111');
    final hash2 = service.hashUuid('11111111-1111-1111-1111-111111111111');
    final hash3 = service.hashUuid('22222222-2222-2222-2222-222222222222');

    expect(hash1.length, 16);
    expect(hash1, equals(hash2));
    expect(hash1, isNot(equals(hash3)));
  });

  test('getOrCreateHashedDeviceId returns hash of the persisted uuid', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = DeviceService(prefs);

    final hashedId = await service.getOrCreateHashedDeviceId();
    final uuid = await service.getOrCreateUuid();

    expect(hashedId, equals(service.hashUuid(uuid)));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/core/device/device_service_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:zone/core/device/device_service.dart'`.

- [ ] **Step 3: Implement**

Create `lib/core/device/device_service.dart`:

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _deviceUuidKey = 'zone_device_uuid';
const _hashSalt = 'zone_salt_2024';

class DeviceService {
  DeviceService(this._prefs);

  final SharedPreferences _prefs;

  Future<String> getOrCreateUuid() async {
    final existing = _prefs.getString(_deviceUuidKey);
    if (existing != null) return existing;
    final generated = const Uuid().v4();
    await _prefs.setString(_deviceUuidKey, generated);
    return generated;
  }

  String hashUuid(String uuid) {
    final bytes = utf8.encode(uuid + _hashSalt);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  Future<String> getOrCreateHashedDeviceId() async {
    final uuid = await getOrCreateUuid();
    return hashUuid(uuid);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('overridden in main.dart via ProviderScope overrides');
});

final deviceServiceProvider = Provider<DeviceService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DeviceService(prefs);
});

final hashedDeviceIdProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(deviceServiceProvider);
  return service.getOrCreateHashedDeviceId();
});
```

- [ ] **Step 4: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/core/device/device_service_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add lib/core/device/device_service.dart test/core/device/device_service_test.dart
git commit -m "Add DeviceService for anonymous UUID identity and hashing"
git push
```

---

### Task 4: Main Shell (bottom nav + placeholder tabs)

**Files:**
- Create: `lib/features/shell/main_shell.dart`
- Create: `lib/features/shell/placeholder_tab.dart`
- Test: `test/features/shell/main_shell_test.dart`

**Interfaces:**
- Consumes: `AppColors` (Task 1)
- Produces: `MainShell` widget (no constructor params besides `key`), `PlaceholderTab` widget (constructor `PlaceholderTab({required String label})`). Task 8's router routes `/home` to `MainShell()`.

- [ ] **Step 1: Write the failing test**

Create `test/features/shell/main_shell_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/shell/main_shell.dart';

void main() {
  testWidgets('shows Map tab content by default and switches on tap', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    expect(find.text('Map — coming in the next slice'), findsOneWidget);
    expect(find.text('Feed — coming in the next slice'), findsNothing);

    await tester.tap(find.text('Feed'));
    await tester.pumpAndSettle();

    expect(find.text('Feed — coming in the next slice'), findsOneWidget);
    expect(find.text('Map — coming in the next slice'), findsNothing);
  });

  testWidgets('all four tab labels are present', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/features/shell/main_shell_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:zone/features/shell/main_shell.dart'`.

- [ ] **Step 3: Implement**

Create `lib/features/shell/placeholder_tab.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label — coming in the next slice',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
      ),
    );
  }
}
```

Create `lib/features/shell/main_shell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'placeholder_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    _TabSpec(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Map'),
    _TabSpec(icon: Icons.article_outlined, activeIcon: Icons.article, label: 'Feed'),
    _TabSpec(icon: Icons.groups_outlined, activeIcon: Icons.groups, label: 'Community'),
    _TabSpec(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  void _onTap(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (final tab in _tabs) PlaceholderTab(label: tab.label),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      spec: _tabs[i],
                      selected: i == _index,
                      onTap: () => _onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.spec, required this.selected, required this.onTap});

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navActive : AppColors.navInactive;
    return InkWell(
      onTap: onTap,
      child: Semantics(
        label: spec.label,
        selected: selected,
        button: true,
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? spec.activeIcon : spec.icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                spec.label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/features/shell/main_shell_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add lib/features/shell test/features/shell
git commit -m "Add MainShell with 4-tab bottom nav and placeholder bodies"
git push
```

---

### Task 5: Onboarding supporting widgets (progress pill + mock cards)

**Files:**
- Create: `lib/features/onboarding/widgets/onboarding_progress_pill.dart`
- Create: `lib/features/onboarding/widgets/map_pin_mock_card.dart`
- Create: `lib/features/onboarding/widgets/feed_post_mock_card.dart`
- Create: `lib/features/onboarding/widgets/showcase_mock_card.dart`
- Test: `test/features/onboarding/onboarding_widgets_test.dart`

**Interfaces:**
- Consumes: `AppColors` (Task 1)
- Produces: `OnboardingProgressPill` (constructor `{required int count, required int activeIndex}`), `MapPinMockCard`, `FeedPostMockCard`, `ShowcaseMockCard` (all no-arg constructors). Task 6's `OnboardingSlide` data list references these four widgets by name.

- [ ] **Step 1: Write the failing test**

Create `test/features/onboarding/onboarding_widgets_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/onboarding/widgets/onboarding_progress_pill.dart';
import 'package:zone/features/onboarding/widgets/map_pin_mock_card.dart';
import 'package:zone/features/onboarding/widgets/feed_post_mock_card.dart';
import 'package:zone/features/onboarding/widgets/showcase_mock_card.dart';

void main() {
  testWidgets('OnboardingProgressPill renders one segment per count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OnboardingProgressPill(count: 3, activeIndex: 1)),
      ),
    );

    expect(find.byType(Container), findsNWidgets(3));
  });

  testWidgets('MapPinMockCard shows the pin label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MapPinMockCard())),
    );

    expect(find.textContaining('Library AC working today'), findsOneWidget);
  });

  testWidgets('FeedPostMockCard shows title, counts, and flair', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FeedPostMockCard())),
    );

    expect(find.text('Staff near C Block'), findsOneWidget);
    expect(find.textContaining('Alert'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('ShowcaseMockCard shows project name and tech chips', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ShowcaseMockCard())),
    );

    expect(find.text('Campus Dashboard'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Firebase'), findsOneWidget);
    expect(find.text('Groq'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/features/onboarding/onboarding_widgets_test.dart
```

Expected: FAIL — `Target of URI doesn't exist` for all four widget imports.

- [ ] **Step 3: Implement**

Create `lib/features/onboarding/widgets/onboarding_progress_pill.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingProgressPill extends StatelessWidget {
  const OnboardingProgressPill({super.key, required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: 24,
            height: 4,
            decoration: BoxDecoration(
              color: i == activeIndex ? AppColors.ctaBlack : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}
```

Create `lib/features/onboarding/widgets/map_pin_mock_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MapPinMockCard extends StatelessWidget {
  const MapPinMockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4B5563), Color(0xFF1F2937)],
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(
                '📌 Library AC working today',
                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

Create `lib/features/onboarding/widgets/feed_post_mock_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FeedPostMockCard extends StatelessWidget {
  const FeedPostMockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: AppColors.semanticAlert.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🚨 Alert',
                  style: TextStyle(fontSize: 12, color: AppColors.semanticAlert, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              const Text('2 min ago', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Staff near C Block',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Faculty checking IDs.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.arrow_upward, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text('42', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text('18', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Spacer(),
              Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
```

Create `lib/features/onboarding/widgets/showcase_mock_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ShowcaseMockCard extends StatelessWidget {
  const ShowcaseMockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF312E81)],
                  ),
                ),
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: Icon(Icons.bookmark_border, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campus Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: const [
                    _TechChip('Flutter'),
                    _TechChip('Firebase'),
                    _TechChip('Groq'),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    CircleAvatar(radius: 8, backgroundColor: AppColors.cardBorder),
                    SizedBox(width: 6),
                    Text('Anonymous', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/features/onboarding/onboarding_widgets_test.dart
```

Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add lib/features/onboarding/widgets test/features/onboarding/onboarding_widgets_test.dart
git commit -m "Add onboarding progress pill and mock preview card widgets"
git push
```

---

### Task 6: Onboarding slide data + OnboardingScreen

**Files:**
- Create: `lib/features/onboarding/onboarding_slide.dart`
- Create: `lib/features/onboarding/onboarding_screen.dart`
- Test: `test/features/onboarding/onboarding_screen_test.dart`

**Interfaces:**
- Consumes: `OnboardingProgressPill`, `MapPinMockCard`, `FeedPostMockCard`, `ShowcaseMockCard` (Task 5); `OnboardingPrefs` (Task 2); `AppColors`, `AppTextStyles` (Task 1); `go_router`'s `context.go(String)` extension.
- Produces: `onboardingSlides` (a `List<OnboardingSlide>` of length 3), `OnboardingScreen` widget (no-arg constructor). Task 8's router routes `/onboarding` to `OnboardingScreen()`.

- [ ] **Step 1: Write the failing test**

Create `test/features/onboarding/onboarding_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/prefs/onboarding_prefs.dart';
import 'package:zone/features/onboarding/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp() {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('HOME'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows first slide heading initially', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Your campus.'), findsOneWidget);
  });

  testWidgets('tapping Skip completes onboarding and navigates home', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(OnboardingPrefs(prefs).isOnboardingComplete(), isTrue);
  });

  testWidgets('swiping through all slides and tapping Get Started navigates home', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.fling(find.textContaining('Your campus.'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    await tester.fling(find.textContaining('Say what'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/features/onboarding/onboarding_screen_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:zone/features/onboarding/onboarding_screen.dart'`.

- [ ] **Step 3: Implement**

Create `lib/features/onboarding/onboarding_slide.dart`:

```dart
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
```

Create `lib/features/onboarding/onboarding_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/prefs/onboarding_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'onboarding_slide.dart';
import 'widgets/onboarding_progress_pill.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await OnboardingPrefs(prefs).setOnboardingComplete();
    if (mounted) context.go('/home');
  }

  void _next() {
    if (_index == onboardingSlides.length - 1) {
      _completeOnboarding();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: OnboardingProgressPill(
                        count: onboardingSlides.length,
                        activeIndex: _index,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingSlides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final slide = onboardingSlides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(slide.heading, style: AppTextStyles.headingDisplay),
                        const SizedBox(height: 8),
                        Text(slide.subtext, style: AppTextStyles.bodySmallSecondary),
                        const SizedBox(height: 24),
                        Expanded(child: slide.mockCard),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _index == onboardingSlides.length - 1
                  ? SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ctaBlack,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: _next,
                        child: const Text('Get Started', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.ctaBlack,
                            shape: const CircleBorder(),
                          ),
                          onPressed: _next,
                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/features/onboarding/onboarding_screen_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add lib/features/onboarding/onboarding_slide.dart lib/features/onboarding/onboarding_screen.dart test/features/onboarding/onboarding_screen_test.dart
git commit -m "Add OnboardingScreen with 3-slide PageView, Skip and Get Started flows"
git push
```

---

### Task 7: SplashScreen

**Files:**
- Create: `lib/features/splash/splash_screen.dart`
- Test: `test/features/splash/splash_screen_test.dart`

**Interfaces:**
- Consumes: `OnboardingPrefs` (Task 2); `go_router`'s `context.go(String)`.
- Produces: `SplashScreen` widget (no-arg constructor). Task 8's router routes `/splash` (initial route) to `SplashScreen()`.

- [ ] **Step 1: Write the failing test**

Create `test/features/splash/splash_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/prefs/onboarding_prefs.dart';
import 'package:zone/features/splash/splash_screen.dart';

void main() {
  Widget buildTestApp() {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const Scaffold(body: Text('ONBOARDING'))),
        GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('HOME'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('navigates to onboarding when onboarding not complete', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(buildTestApp());

    expect(find.text('ZONE'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('navigates to home when onboarding already complete', (tester) async {
    SharedPreferences.setMockInitialValues({onboardingCompleteKey: true});
    await tester.pumpWidget(buildTestApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/features/splash/splash_screen_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:zone/features/splash/splash_screen.dart'`.

- [ ] **Step 3: Implement**

Create `lib/features/splash/splash_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/prefs/onboarding_prefs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = OnboardingPrefs(prefs).isOnboardingComplete();
    if (!mounted) return;
    context.go(onboardingDone ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111111), Color(0xFF0B0B0F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white70, size: 20),
                ),
                const Spacer(),
                const Text(
                  'ZONE',
                  style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Know your campus, before you step in.',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Loading your campus...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/features/splash/splash_screen_test.dart
```

Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add lib/features/splash test/features/splash
git commit -m "Add SplashScreen with 2s delay and onboarding-complete routing"
git push
```

---

### Task 8: App router + main.dart wiring

**Files:**
- Create: `lib/core/router/app_router.dart`
- Modify: `lib/main.dart` (replace the default `flutter create` counter-app content entirely)
- Test: `test/app_integration_test.dart`

**Interfaces:**
- Consumes: `SplashScreen` (Task 7), `OnboardingScreen` (Task 6), `MainShell` (Task 4), `AppTheme.light` (Task 1), `sharedPreferencesProvider` (Task 3).
- Produces: `appRouter` (a `GoRouter` instance), `ZoneApp` widget (the app root, no-arg constructor), `main()` entrypoint.

- [ ] **Step 1: Write the failing test**

Create `test/app_integration_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/main.dart';

void main() {
  testWidgets('full flow: splash -> onboarding -> skip -> main shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ZoneApp(),
      ),
    );

    expect(find.text('ZONE'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Map — coming in the next slice'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
"/c/src/flutter/bin/flutter" test test/app_integration_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:zone/main.dart'` exports `ZoneApp` (compile error, since `main.dart` still has the default counter app).

- [ ] **Step 3: Implement**

Create `lib/core/router/app_router.dart`:

```dart
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (context, state) => const MainShell()),
  ],
);
```

Replace the full contents of `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/device/device_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ZoneApp(),
    ),
  );
}

class ZoneApp extends StatelessWidget {
  const ZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZONE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
"/c/src/flutter/bin/flutter" test test/app_integration_test.dart
```

Expected: PASS (1 test).

- [ ] **Step 5: Run the full test suite and analyzer**

```bash
"/c/src/flutter/bin/flutter" test
"/c/src/flutter/bin/flutter" analyze
```

Expected: all tests pass, "No issues found!".

- [ ] **Step 6: Commit**

```bash
cd "/c/Users/shakthi/Documents/zone"
git add lib/core/router/app_router.dart lib/main.dart test/app_integration_test.dart
git commit -m "Wire up go_router and app entrypoint connecting Splash, Onboarding, and Main Shell"
git push
```

---

### Task 9: Manual visual verification against the reference screenshot

**Files:** none (verification only)

**Interfaces:**
- Consumes: the fully wired app from Task 8.
- Produces: a pass/fail verification note appended to this plan file's Task 9 section (or a follow-up fix task if visual issues are found).

- [ ] **Step 1: Run the app in Chrome**

```bash
cd "/c/Users/shakthi/Documents/zone"
"/c/src/flutter/bin/flutter" run -d chrome
```

- [ ] **Step 2: Click through the full flow**

Verify, comparing side-by-side against the reference screenshot at `C:\Users\shakthi\Downloads\zone ui.png`:
- Splash shows the dark gradient, "ZONE" wordmark, tagline, and loading bar, then auto-advances after ~2 seconds.
- Onboarding slide 1 shows the progress pill (1st segment filled), "Skip" top-right, heading "Your campus. Unfiltered.", the map-pin mock card, and the circular next arrow.
- Tapping next arrow advances through slides 2 and 3, each with correct heading/subtext/mock card and progress pill state.
- Slide 3 shows the full-width black "Get Started" button instead of the circular arrow.
- Tapping "Get Started" lands on the Main Shell with 4 bottom-nav tabs; tapping each tab switches the placeholder body and updates active/inactive icon+label color.
- Relaunch the app (refresh the Chrome tab): confirm Splash now routes straight to the Main Shell (skipping Onboarding), since `onboarding_complete` is persisted.
- From a fresh state (clear browser local storage or use a new incognito window), confirm tapping "Skip" on slide 1 also reaches the Main Shell directly.

- [ ] **Step 3: Record the result**

If everything matches, note "Visual verification passed" in the plan file under this task and check it off. If something doesn't match the screenshot (spacing, color, copy), file it as a specific fix and apply it directly (small, targeted CSS/widget property changes — no new task needed for minor visual tweaks), then re-run Step 1-2.

- [ ] **Step 4: Final push**

```bash
cd "/c/Users/shakthi/Documents/zone"
git push
```

Confirm `https://github.com/shaktivijayas/zone` shows all commits from this plan on `main`.
