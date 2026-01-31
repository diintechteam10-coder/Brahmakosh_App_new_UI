import 'dart:async';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:brahmakosh/features/home/views/generate_avtar_card.dart';
import 'package:brahmakosh/features/home/views/sponsor_card.dart';

import '../../../common/utils.dart';
import '../../../../core/common_imports.dart';
import '../../dashboard/viewmodels/dashboard_viewmodel.dart';

// New Imports
import 'home_top_bar.dart';
import 'talk_to_rashmi_card.dart';
import 'talk_to_krishna_card.dart';
import 'destiny_guidance_section.dart';
import 'todays_muhrat_section.dart';
import 'personality_discovery_section.dart';
import 'pahar_section.dart';
import 'luck_in_favour_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  int selectedDateIndex = 1;
  bool isAM = true;

  final HomeController homeController = Get.put(HomeController());
  final PageController _pageController = PageController();
  final PageController _cardsPageController = PageController();
  Timer? _cardsTimer;
  int _currentCardPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.fetchFounderMessages(this);
      homeController.fetchSponsors(this);
    });
    _startCardsAutoSlide();
  }

  void _startCardsAutoSlide() {
    _cardsTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentCardPage < 1) {
        _currentCardPage++;
      } else {
        _currentCardPage = 0;
      }

      if (_cardsPageController.hasClients) {
        _cardsPageController.animateToPage(
          _currentCardPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _cardsTimer?.cancel();
    _cardsPageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      homeController.fetchFounderMessages(this),
      homeController.fetchSponsors(this),
      Provider.of<DashboardViewModel>(
        context,
        listen: false,
      ).initLocationUpdate(this, forceRefresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.homeBackground,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primaryGold,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(child: HomeTopBar()),

            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.24,
                child: PageView(
                  controller: _cardsPageController,
                  onPageChanged: (index) {
                    _currentCardPage = index;
                  },
                  children: [
                    RepaintBoundary(child: TalkToRashmiCard()),
                    RepaintBoundary(child: TalkToKrishnaCard()),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            SliverToBoxAdapter(
              child: RepaintBoundary(child: DestinyGuidanceSection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(
              child: RepaintBoundary(child: TodaysMuhratSection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(
              child: RepaintBoundary(child: PersonalityDiscoverySection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(child: RepaintBoundary(child: PaharSection())),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(
              child: RepaintBoundary(child: LuckInFavourSection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // // "Add Brahm Avatar section from old screen into new screen for i'll change later"
            // SliverToBoxAdapter(
            //   child: RepaintBoundary(child: AvatarStudioCard()),
            // ),
            // const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // "our Sponsors section should also add from old screen"
            _buildSponsorsSection(),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildSponsorsSection() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (homeController.isSponsorLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (homeController.sponsors.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Sponsors',
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6D3A0C),
                  fontSize: 18,
                ),
              ),
              //const SizedBox(height: 8),
              Container(
                height: 90,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: SponsorLogoTicker(sponsors: homeController.sponsors),
              ),
            ],
          ),
        );
      }),
    );
  }
}
