import '../../../../core/common_imports.dart';
import '../viewmodels/intro_viewmodel.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntroViewModel(),
      child: Scaffold(
        body: Consumer<IntroViewModel>(
          builder: (context, viewModel, child) {
            return SafeArea(
              child: Column(
                children: [
                  // Skip Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: viewModel.skipIntro,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.cinzel(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: viewModel.pageController,
                      onPageChanged: viewModel.onPageChanged,
                      itemCount: viewModel.introPages.length,
                      itemBuilder: (context, index) {
                        final pageData = viewModel.introPages[index];
                        return _IntroPageWidget(pageData: pageData);
                      },
                    ),
                  ),
                  
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      viewModel.introPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: viewModel.currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: viewModel.currentPage == index
                              ? AppTheme.primaryGold
                              : AppTheme.lightGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Next/Get Started Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.nextPage,
                        child: Text(
                          viewModel.currentPage == viewModel.introPages.length - 1
                              ? 'Get Started'
                              : 'Next',
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IntroPageWidget extends StatelessWidget {
  final IntroPageData pageData;

  const _IntroPageWidget({required this.pageData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: pageData.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pageData.icon,
              size: 100,
              color: pageData.color,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            pageData.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: pageData.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            pageData.description,
            style: GoogleFonts.lora(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

