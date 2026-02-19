class SpiritualStatsResponse {
  bool? success;
  SpiritualStatsData? data;

  SpiritualStatsResponse({this.success, this.data});

  SpiritualStatsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? SpiritualStatsData.fromJson(json['data'])
        : null;
  }
}

class SpiritualStatsData {
  TotalStats? totalStats;
  CategoryStats? categoryStats;
  List<RecentActivity>? recentActivities;
  UserDetails? userDetails;

  SpiritualStatsData({
    this.totalStats,
    this.categoryStats,
    this.recentActivities,
    this.userDetails,
  });

  SpiritualStatsData.fromJson(Map<String, dynamic> json) {
    totalStats = json['totalStats'] != null
        ? TotalStats.fromJson(json['totalStats'])
        : null;
    categoryStats = json['categoryStats'] != null
        ? CategoryStats.fromJson(json['categoryStats'])
        : null;
    if (json['recentActivities'] != null) {
      recentActivities = <RecentActivity>[];
      json['recentActivities'].forEach((v) {
        recentActivities!.add(RecentActivity.fromJson(v));
      });
    }
    userDetails = json['userDetails'] != null
        ? UserDetails.fromJson(json['userDetails'])
        : null;
  }
}

class TotalStats {
  int? sessions;
  int? completed;
  int? incomplete;
  int? minutes;
  int? karmaPoints;
  int? averageCompletion;

  TotalStats({
    this.sessions,
    this.completed,
    this.incomplete,
    this.minutes,
    this.karmaPoints,
    this.averageCompletion,
  });

  TotalStats.fromJson(Map<String, dynamic> json) {
    sessions = json['sessions'];
    completed = json['completed'];
    incomplete = json['incomplete'];
    minutes = json['minutes'];
    karmaPoints = json['karmaPoints'];
    averageCompletion = json['averageCompletion'];
  }
}

class CategoryStats {
  StatDetail? chanting;
  StatDetail? prayer;
  StatDetail? silence;
  StatDetail? meditation;

  CategoryStats({this.chanting, this.prayer, this.silence, this.meditation});

  CategoryStats.fromJson(Map<String, dynamic> json) {
    chanting = json['chanting'] != null
        ? StatDetail.fromJson(json['chanting'])
        : null;
    prayer = json['prayer'] != null
        ? StatDetail.fromJson(json['prayer'])
        : null;
    silence = json['silence'] != null
        ? StatDetail.fromJson(json['silence'])
        : null;
    meditation = json['meditation'] != null
        ? StatDetail.fromJson(json['meditation'])
        : null;
  }
}

class StatDetail {
  int? sessions;
  int? completed;
  int? incomplete;
  int? minutes;
  int? karmaPoints;
  int? averageCompletion;

  StatDetail({
    this.sessions,
    this.completed,
    this.incomplete,
    this.minutes,
    this.karmaPoints,
    this.averageCompletion,
  });

  StatDetail.fromJson(Map<String, dynamic> json) {
    sessions = json['sessions'];
    completed = json['completed'];
    incomplete = json['incomplete'];
    minutes = json['minutes'];
    karmaPoints = json['karmaPoints'];
    averageCompletion = json['averageCompletion'];
  }
}

class RecentActivity {
  String? id;
  String? title;
  String? type;
  String? status;
  int? completionPercentage;
  int? karmaPoints;
  String? emotion;
  bool? isActive;
  String? createdAt;
  String? videoUrl;
  String? audioUrl;
  UserDetails? userDetails;
  int? chantCount;
  int? targetDuration;
  int? actualDuration;

  RecentActivity({
    this.id,
    this.title,
    this.type,
    this.status,
    this.completionPercentage,
    this.karmaPoints,
    this.emotion,
    this.isActive,
    this.createdAt,
    this.videoUrl,
    this.audioUrl,
    this.userDetails,
    this.chantCount,
    this.targetDuration,
    this.actualDuration,
  });

  RecentActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    status = json['status'];
    completionPercentage = json['completionPercentage'];
    karmaPoints = json['karmaPoints'];
    emotion = json['emotion'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    videoUrl = json['videoUrl'];
    audioUrl = json['audioUrl'];
    userDetails = json['userDetails'] != null
        ? UserDetails.fromJson(json['userDetails'])
        : null;
    chantCount = json['chantCount'];
    targetDuration = json['targetDuration'];
    actualDuration = json['actualDuration'];
  }
}

class UserDetails {
  String? email;
  String? name;
  String? dob;
  String? profileImage; // Added profileImage

  UserDetails({this.email, this.name, this.dob, this.profileImage});

  UserDetails.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    dob = json['dob'];
    // profileImage is not in JSON usually, but we can set it manually
  }
}
