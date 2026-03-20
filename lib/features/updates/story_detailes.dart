import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/updates/controller/status_controller.dart';

class WhatsAppStatusPage extends StatelessWidget {
  WhatsAppStatusPage({super.key});

  final StatusController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              /// 🔝 TOP SEGMENTED PROGRESS BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: List.generate(
                    controller.totalStatus,
                    (index) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: LinearProgressIndicator(
                          value: index < controller.currentIndex.value
                              ? 1
                              : index == controller.currentIndex.value
                                  ? controller.progressController.value
                                  : 0,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 📄 STATUS CONTENT
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.totalStatus,
                  itemBuilder: (_, index) {
                    return Stack(
                      children: [
                        Center(
                          child: Text(
                            "Status ${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: controller.goToNextStatus,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
