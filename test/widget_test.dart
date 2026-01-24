import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brahmakosh/main.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/splash/views/splash_view.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {}

  @override
  Future<int> create(DataSource dataSource) async {
    return 0;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> dispose(int textureId) async {}

  @override
  Widget buildView(int textureId) {
    return Container();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return const Stream.empty();
  }
}

void main() {
  testWidgets('App starts with SplashView smoke test', (
    WidgetTester tester,
  ) async {
    // Set a realistic screen size to avoid overflow errors
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Mock VideoPlayerPlatform
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MyApp(initialRoute: AppConstants.routeSplash),
    );

    // Verify that our app starts with the SplashView
    expect(find.byType(SplashView), findsOneWidget);

    // Allow the splash timer to complete to avoid "Timer is still pending" error
    await tester.pump(const Duration(seconds: AppConstants.splashDuration));
    await tester.pumpAndSettle();
  });
}
