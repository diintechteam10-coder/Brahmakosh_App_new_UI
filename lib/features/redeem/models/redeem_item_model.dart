class RedeemItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subcategory;
  final int requiredPoints;
  final int numberOfDevotees;
  final String devoteeMessage;
  final String greetings;
  final bool isActive;
  final String imagePath;
  final String imageKey;
  final String banner;
  final String bannerKey;
  // Actually, looking at the response:
  // description: "jsfgvkdfjvh"
  // devoteeMessage: "egkjrhd"
  // greetings: "igugfvifgvh"
  // The UI has "detailedDescription". The prompt implies "description" is short?
  // User's previous mock data had "description" (short) and "detailedDescription" (long).
  // API has "description", "devoteeMessage", "greetings".
  // Let's map:
  // title -> title
  // description -> description
  // category -> category
  // karmaPointsRequired -> requiredPoints
  // numberOfDevotees -> devoteesRedeemed (renamed for UI compatibility or keep as is?)
  // image -> imagePath
  // banner -> banner (for detail view?)

  // Let's update the model to reflect API fields but keep some getters/aliases for UI compatibility if needed, or update UI.
  // I will update the UI to use the new fields.

  RedeemItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.requiredPoints,
    required this.numberOfDevotees,
    required this.devoteeMessage,
    required this.greetings,
    required this.isActive,
    required this.imagePath,
    required this.imageKey,
    required this.banner,
    required this.bannerKey,
  });

  factory RedeemItemModel.fromJson(Map<String, dynamic> json) {
    return RedeemItemModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      requiredPoints: json['karmaPointsRequired'] ?? 0,
      numberOfDevotees: json['numberOfDevotees'] ?? 0,
      devoteeMessage: json['devoteeMessage'] ?? '',
      greetings: json['greetings'] ?? '',
      isActive: json['isActive'] ?? false,
      imagePath: json['image'] ?? '',
      imageKey: json['imageKey'] ?? '',
      banner: json['banner'] ?? '',
      bannerKey: json['bannerKey'] ?? '',
    );
  }

  // Getters for UI compatibility where names changed slightly or logic is needed
  // UI used `requiredPoints` (matched), `imagePath` (matched), `title` (matched).
  // UI used `detailedDescription`. API has `description` which seems short/medium.
  // API also has `devoteeMessage` and `greetings`.
  // Let's use `description` for list view (short).
  // For detail view, we might want `devoteeMessage` or `description` depending on content length.
  // Let's alias detailedDescription to description for now to minimize UI breakage, or update UI.
  String get detailedDescription => description;
  int get devoteesRedeemed => numberOfDevotees;
}
