import '../../../../core/common_imports.dart';

class IntroViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;

  int get currentPage => _currentPage;

  List<IntroPageData> introPages = [
    IntroPageData(
      title: 'Karma Points',
      subtitle: "Help others with your's\nkarma points",
      description: 'Your spiritual check-in earns karma points\nthat feed cows, educate children,\nand help those in need.',
      assetPath: "assets/icons/Onboarding1.png",
      color: const Color(0xFFD4AF37), // Gold
    ),
    IntroPageData(
      title: 'Your Destiny, In Your Hands',
      subtitle: 'Vedic astrology, tarot reading, vastu and\ncareer insights - tailored for you.',
      description: '',
      assetPath: "assets/icons/Onboarding Screen 2.png",
      color: const Color(0xFFD4AF37), // Gold
    ),
    IntroPageData(
      title: 'BRAHMAKOSH INTELLIGENCE',
      subtitle: '(Krishna - Your Spiritual Guide)',
      description: '',
      assetPath: "assets/icons/Onboarding Screen 3.png",
      color: const Color(0xFFD4AF37), // Gold
    ),
  ];

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < introPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeIntro();
    }
  }

  void skipIntro() {
    _completeIntro();
  }

  Future<void> _completeIntro() async {
    await StorageService.setBool(AppConstants.keyIsFirstLaunch, false);
    Get.offAllNamed(AppConstants.routeLogin);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class IntroPageData {
  final String title;
  final String subtitle;
  final String description;
  final String assetPath;
  final Color color;

  IntroPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.assetPath,
    required this.color,
  });
}

