import '../../core/common_imports.dart';

class ServiceModel {
  final String title;
  final Color color;
  final String lottie;
  final String description;
  final List<ServiceFeature> features;
  final bool isStore;
  final List<String>? storeItems;
  final String? imageUrl; // For API image support

  ServiceModel({
    required this.title,
    required this.color,
    required this.lottie,
    required this.description,
    required this.features,
    this.isStore = false,
    this.storeItems,
    this.imageUrl,
  });

  // Factory constructor to create from ServiceItem (API model)
  factory ServiceModel.fromServiceItem(ServiceItem item) {
    // Map service names to colors and lottie files
    final serviceConfig = _getServiceConfig(item.name ?? '');
    
    return ServiceModel(
      title: item.name ?? 'Service',
      color: serviceConfig['color'] as Color,
      lottie: serviceConfig['lottie'] as String,
      description: item.description ?? '',
      features: [], // Can be populated later if needed
      imageUrl: item.image,
    );
  }

  static Map<String, dynamic> _getServiceConfig(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('astrology') || lowerName.contains('astrolog')) {
      return {
        'color': Colors.orangeAccent,
        'lottie': 'assets/lotties/Astrology.json',
      };
    } else if (lowerName.contains('yoga')) {
      return {
        'color': Colors.greenAccent,
        'lottie': 'assets/lotties/Meditating.json',
      };
    } else if (lowerName.contains('healing')) {
      return {
        'color': Colors.redAccent,
        'lottie': 'assets/lotties/Yoga Developer.json',
      };
    } else if (lowerName.contains('reiki')) {
      return {
        'color': Colors.indigoAccent,
        'lottie': 'assets/lotties/reiki.json',
      };
    } else if (lowerName.contains('spell')) {
      return {
        'color': Colors.purpleAccent,
        'lottie': 'assets/lotties/Yoga Developer.json',
      };
    } else {
      // Default
      return {
        'color': Colors.blueAccent,
        'lottie': 'assets/lotties/Astrology.json',
      };
    }
  }
}

class ServiceFeature {
  final String title;
  final String description;
  final IconData icon;

  ServiceFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}

final List<ServiceModel> servicesList = [
  ServiceModel(
    title: 'Astrology',
    color: Colors.orangeAccent,
    lottie: 'assets/lotties/Astrology.json',
    description:
        'Discover your destiny through the ancient science of astrology. Get personalized horoscope readings, birth chart analysis, and guidance for life decisions from our expert astrologers.',
    features: [
      ServiceFeature(
        title: 'Birth Chart Analysis',
        description: 'Detailed analysis of your natal chart',
        icon: Icons.stars,
      ),
      ServiceFeature(
        title: 'Daily Horoscope',
        description: 'Get your daily predictions',
        icon: Icons.calendar_today,
      ),
      ServiceFeature(
        title: 'Compatibility Check',
        description: 'Check compatibility with loved ones',
        icon: Icons.favorite,
      ),
    ],
  ),
   ServiceModel(
    title: 'Yoga',
    color: Colors.greenAccent,
    lottie: 'assets/lotties/Meditating.json',
    description:
        'Transform your mind, body, and soul through the practice of yoga. Learn from experienced instructors with personalized sessions for all levels - from beginners to advanced practitioners.',
    features: [
      ServiceFeature(
        title: 'Personalized Sessions',
        description: 'One-on-one yoga classes',
        icon: Icons.person,
      ),
      ServiceFeature(
        title: 'Multiple Styles',
        description: 'Hatha, Vinyasa, Ashtanga and more',
        icon: Icons.fitness_center,
      ),
      ServiceFeature(
        title: 'Meditation Guidance',
        description: 'Learn meditation techniques',
        icon: Icons.self_improvement,
      ),
    ],
  ),
  ServiceModel(
    title: 'Healing',
    color: Colors.redAccent,
    lottie: 'assets/lotties/Yoga Developer.json',
    description:
        'Experience powerful energy healing sessions to restore balance and harmony in your life. Our certified healers use various techniques to help you overcome physical, emotional, and spiritual blockages.',
    features: [
      ServiceFeature(
        title: 'Energy Healing',
        description: 'Restore your energy balance',
        icon: Icons.healing,
      ),
      ServiceFeature(
        title: 'Chakra Balancing',
        description: 'Align and balance your chakras',
        icon: Icons.brightness_1,
      ),
      ServiceFeature(
        title: 'Distance Healing',
        description: 'Remote healing sessions available',
        icon: Icons.wifi,
      ),
    ],
  ),
  ServiceModel(
    title: 'Reiki',
    color: Colors.indigoAccent,
    lottie: 'assets/lotties/reiki.json',
    description:
        'Receive the gentle yet powerful healing energy of Reiki. This Japanese technique promotes relaxation, reduces stress, and accelerates natural healing processes through energy channeling.',
    features: [
      ServiceFeature(
        title: 'Reiki Sessions',
        description: 'Professional Reiki healing',
        icon: Icons.handshake,
      ),
      ServiceFeature(
        title: 'Reiki Attunement',
        description: 'Learn to practice Reiki yourself',
        icon: Icons.school,
      ),
      ServiceFeature(
        title: 'Stress Relief',
        description: 'Deep relaxation and stress reduction',
        icon: Icons.spa,
      ),
    ],
  ),
  ServiceModel(
    title: 'Spell',
    color: Colors.purpleAccent,
    lottie: 'assets/lotties/Yoga Developer.json',
    description:
        'Connect with ancient magical practices and rituals. Our experienced practitioners offer spell casting services for love, protection, prosperity, and spiritual growth with ethical and safe methods.',
    features: [
      ServiceFeature(
        title: 'Custom Spells',
        description: 'Personalized spell casting',
        icon: Icons.auto_awesome,
      ),
      ServiceFeature(
        title: 'Ritual Guidance',
        description: 'Learn sacred rituals and practices',
        icon: Icons.candlestick_chart,
      ),
      ServiceFeature(
        title: 'Protection Spells',
        description: 'Shield yourself from negative energy',
        icon: Icons.shield,
      ),
    ],
  ),
];


// API Models
class ServiceModelResponse {
  bool? success;
  ServiceListData? data;

  ServiceModelResponse({this.success, this.data});

  ServiceModelResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? ServiceListData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['success'] = success;
    if (data != null) {
      json['data'] = data!.toJson();
    }
    return json;
  }
}

class ServiceListData {
  bool? success;
  List<ServiceItem>? data;
  int? count;

  ServiceListData({this.success, this.data, this.count});

  ServiceListData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <ServiceItem>[];
      json['data'].forEach((v) {
        data!.add(ServiceItem.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['success'] = success;
    if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }
    json['count'] = count;
    return json;
  }
}

class ServiceItem {
  String? id;
  String? name;
  String? description;
  String? image;
  String? imageKey;
  String? clientId;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? version;

  ServiceItem({
    this.id,
    this.name,
    this.description,
    this.image,
    this.imageKey,
    this.clientId,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  ServiceItem.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    imageKey = json['imageKey'];
    clientId = json['clientId'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    version = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['_id'] = id;
    json['name'] = name;
    json['description'] = description;
    json['image'] = image;
    json['imageKey'] = imageKey;
    json['clientId'] = clientId;
    json['isActive'] = isActive;
    json['isDeleted'] = isDeleted;
    json['createdAt'] = createdAt;
    json['updatedAt'] = updatedAt;
    json['__v'] = version;
    return json;
  }
}

