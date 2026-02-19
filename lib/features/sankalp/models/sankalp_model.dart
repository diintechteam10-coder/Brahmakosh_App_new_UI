class SankalpModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subcategory;
  final String durationType;
  final int totalDays;
  final String completionRule;
  final int karmaPointsPerDay;
  final int completionBonusKarma;
  final String bannerImage;
  final String dailyMotivationMessage;
  final String completionMessage;
  final String status;
  final String visibility;
  final String slug;
  final int participantsCount;
  final int completedCount;
  // UI helper fields
  final bool
  isCompleted; // From old model, might not be needed in base model but kept for compatibility if needed

  SankalpModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.durationType,
    required this.totalDays,
    required this.completionRule,
    required this.karmaPointsPerDay,
    required this.completionBonusKarma,
    required this.bannerImage,
    required this.dailyMotivationMessage,
    required this.completionMessage,
    required this.status,
    required this.visibility,
    required this.slug,
    required this.participantsCount,
    required this.completedCount,
    this.isCompleted = false,
  });

  factory SankalpModel.fromJson(Map<String, dynamic> json) {
    return SankalpModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      durationType: json['durationType'] ?? '',
      totalDays: json['totalDays'] ?? 0,
      completionRule: json['completionRule'] ?? '',
      karmaPointsPerDay: json['karmaPointsPerDay'] ?? 0,
      completionBonusKarma: json['completionBonusKarma'] ?? 0,
      bannerImage: json['bannerImage'] ?? '',
      dailyMotivationMessage: json['dailyMotivationMessage'] ?? '',
      completionMessage: json['completionMessage'] ?? '',
      status: json['status'] ?? '',
      visibility: json['visibility'] ?? '',
      slug: json['slug'] ?? '',
      participantsCount: json['participantsCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
    );
  }
}

class DailyReport {
  final int day;
  final DateTime? date;
  final String status;

  DailyReport({required this.day, this.date, required this.status});

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      day: json['day'] ?? 0,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      status: json['status'] ?? 'not_reported',
    );
  }
}

class UserSankalpModel {
  final String id;
  final String userId;
  final SankalpModel sankalp;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final int currentDay;
  final int totalDays;
  final List<DailyReport> dailyReports;
  final int karmaEarned;
  final int completionBonusEarned;

  UserSankalpModel({
    required this.id,
    required this.userId,
    required this.sankalp,
    this.startDate,
    this.endDate,
    required this.status,
    required this.currentDay,
    required this.totalDays,
    required this.dailyReports,
    required this.karmaEarned,
    required this.completionBonusEarned,
  });

  factory UserSankalpModel.fromJson(Map<String, dynamic> json) {
    return UserSankalpModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      sankalp: SankalpModel.fromJson(json['sankalpId'] ?? {}),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'])
          : null,
      status: json['status'] ?? '',
      currentDay: json['currentDay'] ?? 1,
      totalDays: json['totalDays'] ?? 0,
      dailyReports:
          (json['dailyReports'] as List<dynamic>?)
              ?.map((e) => DailyReport.fromJson(e))
              .toList() ??
          [],
      karmaEarned: json['karmaEarned'] ?? 0,
      completionBonusEarned: json['completionBonusEarned'] ?? 0,
    );
  }
}
