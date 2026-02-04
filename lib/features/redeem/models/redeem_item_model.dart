class RedeemItemModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'All', 'Seva', 'Puja', 'Yatra'
  final int requiredPoints;
  final String imagePath; // Asset or Network path
  final String detailedDescription;
  final int devoteesRedeemed;

  RedeemItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.requiredPoints,
    required this.imagePath,
    required this.detailedDescription,
    required this.devoteesRedeemed,
  });
}
