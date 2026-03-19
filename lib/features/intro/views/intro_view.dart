import '../../../../core/common_imports.dart';
import '../viewmodels/intro_viewmodel.dart';
import 'package:sizer/sizer.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntroViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<IntroViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                // 1. Sliding Content
                PageView.builder(
                  controller: viewModel.pageController,
                  onPageChanged: viewModel.onPageChanged,
                  itemCount: viewModel.introPages.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = viewModel.introPages[index];
                    return _OnboardingPage(data: data);
                  },
                ),

                // 2. Skip Button (Top Right)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: viewModel.skipIntro,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Skip",
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Page Indicator (Bottom Centerish)
                Positioned(
                  bottom: 160,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      viewModel.introPages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        width: viewModel.currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: viewModel.currentPage == index
                              ? const Color(0xFFD4AF37)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Action Buttons (Bottom)
                Positioned(
                  bottom: 50,
                  left: 30,
                  right: 30,
                  child: _buildActionButtons(viewModel),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(IntroViewModel viewModel) {
    if (viewModel.currentPage == 0) {
      return Center(
        child: _PrimaryButton(
          text: "Next",
          onTap: viewModel.nextPage,
        ),
      );
    } else if (viewModel.currentPage == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SecondaryButton(
            text: "Back",
            onTap: () {
              viewModel.pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          _PrimaryButton(
            text: "Next",
            onTap: viewModel.nextPage,
          ),
        ],
      );
    } else {
      return Center(
        child: _PrimaryButton(
          text: "Continue",
          width: 200,
          onTap: viewModel.skipIntro,
        ),
      );
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  final IntroPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image as full background
        Image.asset(
          data.assetPath,
          fit: BoxFit.cover,
        ),
        // Gradient overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.8),
                Colors.black,
              ],
              stops: const [0.4, 0.6, 0.8, 1.0],
            ),
          ),
        ),
        // Text content
        Positioned(
          left: 40,
          right: 40,
          bottom: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                  height: 1.3,
                ),
              ),
              if (data.description.isNotEmpty) ...[
                const SizedBox(height: 15),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 120,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ),
      ),
    );
  }
}

