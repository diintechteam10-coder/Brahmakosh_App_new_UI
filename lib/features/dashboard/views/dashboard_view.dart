import 'package:brahmakosh/features/ai_rashmi/ai_rashmi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../core/common_imports.dart';
import '../../../common/utils.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../../home/views/new_home_view.dart';
import '../widgets/brahmakosh_bottom_bar.dart';

import '../../services/controllers/services_controller.dart';
import '../../report/views/report_view.dart';
import '../../check_in/views/check_in_view.dart';
import '../../astrology/views/astrology_experts_view.dart';
import '../../rewards/views/rewards_view.dart';
import '../../../common/widgets/custom_popups.dart';

import '../../sankalp/blocs/sankalp_bloc.dart';
import '../../sankalp/blocs/sankalp_event.dart';
import '../../sankalp/repositories/sankalp_repository.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.print("DashboardView build method triggered");
    // Initialize ServicesController if not already registered
    if (!Get.isRegistered<ServicesController>()) {
      Get.put(ServicesController());
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final viewModel = DashboardViewModel();
            if (Get.arguments != null && Get.arguments is int) {
              viewModel.changeTab(Get.arguments);
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.initLocationUpdate(null);
            });
            return viewModel;
          },
        ),
      ],
      child: BlocProvider(
        create: (context) => SankalpBloc(
          repository: SankalpRepository(),
        )..add(FetchUserSankalps()),
        child: const DashboardLayout(),
      ),
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

  void _onPopInvoked(bool didPop) async {
    if (didPop) return;

    final viewModel = Provider.of<DashboardViewModel>(context, listen: false);

    // If we're not on the Home Tab, intercept the back gesture
    if (viewModel.currentIndex != 0) {
      viewModel.changeTab(0);
      return; // Prevent popping the app
    }

    // If we are on the Home Tab, confirm app exit
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return ActionConfirmationPopup(
          title: 'exit_app'.tr,
          description: 'exit_description'.tr,
          confirmLabel: 'yes'.tr,
          cancelLabel: 'no'.tr,
          onConfirm: () {}, // Handled by showDialog return value
          confirmColor: Colors.red,
        );
      },
    );
    if (shouldPop ?? false) {
      SystemNavigator.pop();
    }
  }

  // This method is incomplete based on the provided snippet.
  // Assuming it's meant to be a private helper method within the state class.
  // The `homeController` variable is not defined in the current scope,
  // and `Obx` is not imported. To make this syntactically correct,
  // these would need to be added, but the instruction only provides the method body.
  // As per instructions, only the provided code edit is applied.
  // This will result in syntax errors if `homeController` and `Obx` are not defined/imported elsewhere.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _onPopInvoked(didPop),
      child: Scaffold(
        extendBody: true,
        body: Selector<DashboardViewModel, int>(
          selector: (_, viewModel) => viewModel.currentIndex,
          builder: (context, currentIndex, child) {
            // Detect tab change and reset the NEW tab's scroll position
            if (currentIndex != _previousIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _resetScrollForTab(currentIndex);
              });
              _previousIndex = currentIndex;
            }

            return RepaintBoundary(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  NewHomeView(scrollController: _homeScrollController),
                  CheckInView(scrollController: _checkInScrollController),
                  RashmiAi(),
                  AstrologyExpertsView(
                    screenTitle: "connect".tr,
                    scrollController: _connectScrollController,
                  ),
                  // Only load WebView when active to prevent crashes/memory issues
                  RewardsView(),
                  ReportView(), // Keeping ReportView for My Kosh (Drawer navigation)
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Selector<DashboardViewModel, int>(
          selector: (_, viewModel) => viewModel.currentIndex,
          builder: (context, currentIndex, child) {
            return BrahmakoshBottomBar(
              currentIndex: currentIndex,
              onTap: (index) => Provider.of<DashboardViewModel>(context, listen: false).changeTab(index),
            );
          },
        ),
      ),
    );
  }
}
