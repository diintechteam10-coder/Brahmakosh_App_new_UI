import 'package:brahmakosh/features/ai_rashmi/ai_rashmi.dart';
import 'package:brahmakosh/features/dashboard/widgets/app_drawer.dart';
import 'package:brahmakosh/core/widgets/coming_soon_view.dart';
import 'package:get/get.dart';
import '../../../../core/common_imports.dart';
import '../../../common/utils.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../home/views/home_view.dart';

import '../../services/controllers/services_controller.dart';
import '../../report/views/report_view.dart';
import '../../check_in/views/check_in_view.dart';
import '../../astrology/views/astrology_experts_view.dart';
import '../../remedies/views/remedies_web_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.print("DashboardView build method triggered");
    // Initialize ServicesController if not already registered
    if (!Get.isRegistered<ServicesController>()) {
      Get.put(ServicesController());
    }

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = DashboardViewModel();
        if (Get.arguments != null && Get.arguments is int) {
          viewModel.changeTab(Get.arguments);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.initLocationUpdate(
            null,
          ); // Passing null since it's outside any TickerProvider
        });
        return viewModel;
      },
      child: const DashboardLayout(),
    );
  }
}

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout>
    with WidgetsBindingObserver {
  // ScrollControllers for tabs that need scroll-to-top on switch
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _checkInScrollController = ScrollController();
  final ScrollController _connectScrollController = ScrollController();

  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeScrollController.dispose();
    _checkInScrollController.dispose();
    _connectScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Utils.print("App resumed - updating location");
      // Update location when app comes to foreground
      Provider.of<DashboardViewModel>(
        context,
        listen: false,
      ).initLocationUpdate(null, forceRefresh: true);
    }
  }

  /// Scroll the tab at [index] back to top
  void _resetScrollForTab(int index) {
    ScrollController? ctrl;
    switch (index) {
      case 0:
        ctrl = _homeScrollController;
        break;
      case 1:
        ctrl = _checkInScrollController;
        break;
      case 3:
        ctrl = _connectScrollController;
        break;
    }
    if (ctrl != null && ctrl.hasClients) {
      ctrl.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          // Detect tab change and reset the NEW tab's scroll position
          if (viewModel.currentIndex != _previousIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resetScrollForTab(viewModel.currentIndex);
            });
            _previousIndex = viewModel.currentIndex;
          }

          return IndexedStack(
            index: viewModel.currentIndex,
            children: [
              HomeView(scrollController: _homeScrollController),
              CheckInView(scrollController: _checkInScrollController),
              RashmiAi(),
              AstrologyExpertsView(
                screenTitle: "Connect",
                scrollController: _connectScrollController,
              ),
              // Only load WebView when active to prevent crashes/memory issues
              viewModel.currentIndex == 4
                  ? RemediesWebView(onBack: () => viewModel.changeTab(0))
                  : const SizedBox(),
              ReportView(), // Keeping ReportView for My Kosh (Drawer navigation)
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          // Hide bottom navigation bar when on RashmiAi (index 2) or Remedies (index 4)
          if (viewModel.currentIndex == 2 || viewModel.currentIndex == 4) {
            return const SizedBox.shrink();
          }
          return CustomBottomNavBar(
            currentIndex: viewModel.currentIndex,
            onTap: viewModel.changeTab,
          );
        },
      ),
    );
  }
}
