import 'sankalp_model.dart';

class SankalpProgressModel {
  final UserSankalpModel userSankalp;
  final ProgressStats progress;

  SankalpProgressModel({required this.userSankalp, required this.progress});

  factory SankalpProgressModel.fromJson(Map<String, dynamic> json) {
    return SankalpProgressModel(
      userSankalp: UserSankalpModel.fromJson(json['userSankalp'] ?? {}),
      progress: ProgressStats.fromJson(json['progress'] ?? {}),
    );
  }
}

class ProgressStats {
  final int yesCount;
  final int noCount;
  final int notReportedCount;
  final int progressPercentage;
  final int currentDay;
  final int totalDays;
  final int karmaEarned;
  final int completionBonusEarned;

  ProgressStats({
    required this.yesCount,
    required this.noCount,
    required this.notReportedCount,
    required this.progressPercentage,
    required this.currentDay,
    required this.totalDays,
    required this.karmaEarned,
    required this.completionBonusEarned,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      yesCount: json['yesCount'] ?? 0,
      noCount: json['noCount'] ?? 0,
      notReportedCount: json['notReportedCount'] ?? 0,
      progressPercentage: json['progressPercentage'] ?? 0,
      currentDay: json['currentDay'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      karmaEarned: json['karmaEarned'] ?? 0,
      completionBonusEarned: json['completionBonusEarned'] ?? 0,
    );
  }
}
