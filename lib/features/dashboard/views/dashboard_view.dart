import 'package:brahmakosh/features/ai_rashmi/ai_rashmi.dart';
import 'package:brahmakosh/features/dashboard/widgets/app_drawer.dart';
import 'package:brahmakosh/core/widgets/coming_soon_view.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:get/get.dart';
import '../../../../core/common_imports.dart';
import '../../../common/utils.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../home/views/home_view.dart';
import '../../services/views/services_view.dart';
import '../../services/controllers/services_controller.dart';
import '../../report/views/report_view.dart';
import '../../check_in/views/check_in_view.dart';


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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.initLocationUpdate(null); // Passing null since it's outside any TickerProvider
            });
            return viewModel;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final viewModel = ProfileViewModel();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.fetchProfile();
            });
            return viewModel;
          },
        ),
      ],
      child: Scaffold(
        drawer: const AppDrawer(),
        body: Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            return IndexedStack(
              index: viewModel.currentIndex,
              children: const [
                HomeView(),
                CheckInView(),
                RashmiAi(),
                ServicesView(),
                ComingSoonView(title: 'Remedies'),
                ReportView(), // Keeping ReportView for My Kosh (Drawer navigation)
              ],
            );
          },
        ),
        bottomNavigationBar: Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            // Hide bottom navigation bar when on RashmiAi (index 2)
            if (viewModel.currentIndex == 2) {
              return const SizedBox.shrink();
            }
            return SafeArea(
              top: false,
              child: CustomBottomNavBar(
                currentIndex: viewModel.currentIndex,
                onTap: viewModel.changeTab,
              ),
            );
          },
        ),
      ),
    );
  }
}
