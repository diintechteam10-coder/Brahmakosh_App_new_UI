import '../../../../core/common_imports.dart';

class IntroViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;

  int get currentPage => _currentPage;

  List<IntroPageData> introPages = [
    IntroPageData(
      title: 'Welcome to Brahmakosh',
      description: 'Your spiritual journey begins here. Discover peace, wisdom, and guidance.',
      icon: Icons.spa,
      color: const Color(0xFFD4AF37), // Gold
    ),
    IntroPageData(
      title: 'Expert Services',
      description: 'Connect with experienced astrologers and spiritual guides for personalized consultations.',
      icon: Icons.stars,
      color: const Color(0xFFFF8C00), // Orange
    ),
    IntroPageData(
      title: 'Rashmi AI Assistant',
      description: 'Get instant answers to your spiritual questions with our AI-powered assistant.',
      icon: Icons.smart_toy,
      color: const Color(0xFF8208BF), // Purple
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
  final String description;
  final IconData icon;
  final Color color;

  IntroPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

