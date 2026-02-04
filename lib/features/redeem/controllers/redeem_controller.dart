import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:get/get.dart';

class RedeemController extends GetxController {
  var selectedCategory = 'All'.obs;
  var redeemItems = <RedeemItemModel>[].obs;
  var userPoints = 4182.obs; // Mock user points

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  List<RedeemItemModel> get filteredItems {
    if (selectedCategory.value == 'All') {
      return redeemItems;
    }
    return redeemItems
        .where((item) => item.category == selectedCategory.value)
        .toList();
  }

  void loadMockData() {
    redeemItems.value = [
      RedeemItemModel(
        id: '1',
        title: 'Feed a Cow (Gau Seva)',
        description: 'Show your compassion to the sacred.',
        category: 'Seva',
        requiredPoints: 699,
        imagePath: 'assets/images/gau_seva.png', // Placeholder
        detailedDescription:
            'In Hindu tradition, the cow symbolizes abundance and purity. Feeding a sacred cow is an act of seva that nurtures compassion, humility, and spiritual merit.',
        devoteesRedeemed: 1248,
      ),
      RedeemItemModel(
        id: '2',
        title: 'Char Dham Online Puja',
        description:
            'Perform sacred rites remotely at holy temples, where traditional rituals are performed on your behalf.',
        category: 'Puja',
        requiredPoints: 500,
        imagePath: 'assets/images/char_dham.png', // Placeholder
        detailedDescription:
            'Participate in the sacred Char Dham yatra remotely through online puja. Experienced priests will perform rituals on your behalf, bringing blessings directly to you.',
        devoteesRedeemed: 856,
      ),
      RedeemItemModel(
        id: '3',
        title: 'Ganga Aarti Sponsorship',
        description:
            'Sponsor the evening Aarti at the banks of the holy Ganges.',
        category: 'Puja',
        requiredPoints: 1200,
        imagePath: 'assets/images/ganga_aarti.png', // Placeholder
        detailedDescription:
            'Be a part of the divine Ganga Aarti. Your sponsorship supports the daily rituals and maintenance of the ghats.',
        devoteesRedeemed: 432,
      ),
      RedeemItemModel(
        id: '4',
        title: 'Visit Kashi Vishwanath',
        description: 'A guided spiritual tour to the city of Lord Shiva.',
        category: 'Yatra',
        requiredPoints: 2500,
        imagePath: 'assets/images/kashi.png', // Placeholder
        detailedDescription:
            'Experience the divinity of Kashi Vishwanath temple with a guided tour properly arranged for your comfort and spiritual gain.',
        devoteesRedeemed: 120,
      ),
    ];
  }

  void redeemItem(int cost) {
    // Mock deduction
    if (userPoints.value >= cost) {
      // logic to deduct would go here in real app
      // userPoints.value -= cost;
    }
  }
}
