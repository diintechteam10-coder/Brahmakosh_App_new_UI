import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/common/models/testimonial_model.dart';
import 'package:get/get.dart';

class TestimonialsController extends GetxController {
  var isLoading = true.obs;
  var testimonials = <Testimonial>[].obs;
  var currentPage = 0.obs;

  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.85);
    fetchTestimonials();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> fetchTestimonials() async {
    try {
      
      final response = await getTestimonials(null); 
      
      if (response != null && response.data.isNotEmpty) {
        testimonials.value = response.data;
      }
    } catch (e) {
      print("Error fetching testimonials: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void updatePage(int index) {
    currentPage.value = index;
  }
}
