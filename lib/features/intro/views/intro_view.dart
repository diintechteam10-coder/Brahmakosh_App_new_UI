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
            return Stack(
              children: [
                // 1. Sliding Images
                PageView(
                  controller: viewModel.pageController,
                  onPageChanged: viewModel.onPageChanged,
                  physics: const ClampingScrollPhysics(),
                  children: const [
                    _FullScreenImage(
                      assetPath: "assets/images/onboarding1.png",
                    ),
                    _FullScreenImage(
                      assetPath: "assets/images/onboarding2.png",
                    ),
                    _FullScreenImage(
                      assetPath: "assets/images/onboarding3.png",
                    ),
                  ],
                ),

                // 2. Static Back Button (Visible on Page 1 & 2)
                if (viewModel.currentPage > 0)
                  Positioned(
                    bottom: 40,
                    left: 30,
                    child: GestureDetector(
                      onTap: () {
                        viewModel.pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 245, 245),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Color(0xff5D4037),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Back",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff5D4037),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 3. Static Next Button (Visible on Page 0 & 1)
                if (viewModel.currentPage < 2)
                  Positioned(
                    bottom: 40,
                    right: 30,
                    child: GestureDetector(
                      onTap: viewModel.nextPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 245, 245),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Next",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff5D4037),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Color(0xff5D4037),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 4. Static Continue Button (Visible Only on Page 2)
                if (viewModel.currentPage == 2)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: viewModel.skipIntro,
                        child: Container(
                          width: 200,
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppTheme.landingButton,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Continue",
                            style: GoogleFonts.cinzel(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String assetPath;

  const _FullScreenImage({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
    );
  }
}
