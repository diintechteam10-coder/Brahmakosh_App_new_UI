class SpiritualCheckinResponse {
  bool? success;
  Data? data;

  SpiritualCheckinResponse({this.success, this.data});

  SpiritualCheckinResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<Activities>? activities;
  Stats? stats;
  CategoryStats? categoryStats;
  List<RecentActivities>? recentActivities;
  Motivation? motivation;

  Data({
    this.activities,
    this.stats,
    this.categoryStats,
    this.recentActivities,
    this.motivation,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['activities'] != null) {
      activities = <Activities>[];
      json['activities'].forEach((v) {
        activities!.add(Activities.fromJson(v));
      });
    }
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    categoryStats = json['categoryStats'] != null
        ? CategoryStats.fromJson(json['categoryStats'])
        : null;
    if (json['recentActivities'] != null) {
      recentActivities = <RecentActivities>[];
      json['recentActivities'].forEach((v) {
        recentActivities!.add(RecentActivities.fromJson(v));
      });
    }
    motivation = json['motivation'] != null
        ? Motivation.fromJson(json['motivation'])
        : null;
  }
}

class Activities {
  String? id;
  String? title;
  String? desc;
  String? icon;
  String? image;
  String? route;
  bool? isActive;

  Activities({
    this.id,
    this.title,
    this.desc,
    this.icon,
    this.image,
    this.route,
    this.isActive,
  });

  Activities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    desc = json['desc'];
    icon = json['icon'];
    image = json['image'];
    route = json['route'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['desc'] = desc;
    data['icon'] = icon;
    data['image'] = image;
    data['route'] = route;
    data['isActive'] = isActive;
    return data;
  }
}

class Stats {
  int? days;
  int? points;
  int? sessions;
  int? completed;
  int? minutes;
  int? averageCompletion;

  Stats({
    this.days,
    this.points,
    this.sessions,
    this.completed,
    this.minutes,
    this.averageCompletion,
  });

  Stats.fromJson(Map<String, dynamic> json) {
    days = json['days'];
    points = json['points'];
    sessions = json['sessions'];
    completed = json['completed'];
    minutes = json['minutes'];
    averageCompletion = json['averageCompletion'];
  }
}

class CategoryStats {
  CategoryDetail? meditation;
  CategoryDetail? chanting;
  CategoryDetail? prayer;
  CategoryDetail? silence;

  CategoryStats({this.meditation, this.chanting, this.prayer, this.silence});

  CategoryStats.fromJson(Map<String, dynamic> json) {
    meditation = json['meditation'] != null
        ? CategoryDetail.fromJson(json['meditation'])
        : null;
    chanting = json['chanting'] != null
        ? CategoryDetail.fromJson(json['chanting'])
        : null;
    prayer = json['prayer'] != null
        ? CategoryDetail.fromJson(json['prayer'])
        : null;
    silence = json['silence'] != null
        ? CategoryDetail.fromJson(json['silence'])
        : null;
  }
}

class CategoryDetail {
  int? sessions;
  int? completed;
  int? minutes;
  int? karmaPoints;

  CategoryDetail({
    this.sessions,
    this.completed,
    this.minutes,
    this.karmaPoints,
  });

  CategoryDetail.fromJson(Map<String, dynamic> json) {
    sessions = json['sessions'];
    completed = json['completed'];
    minutes = json['minutes'];
    karmaPoints = json['karmaPoints'];
  }
}

class RecentActivities {
  String? id;
  String? title;
  String? type;
  String? status;
  int? completionPercentage;
  int? karmaPoints;
  String? emotion;
  String? createdAt;
  int? targetDuration;
  int? actualDuration;
  int? chantCount;
  String? chantingName;

  RecentActivities({
    this.id,
    this.title,
    this.type,
    this.status,
    this.completionPercentage,
    this.karmaPoints,
    this.emotion,
    this.createdAt,
    this.targetDuration,
    this.actualDuration,
    this.chantCount,
    this.chantingName,
  });

  RecentActivities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    status = json['status'];
    completionPercentage = json['completionPercentage'];
    karmaPoints = json['karmaPoints'];
    emotion = json['emotion'];
    createdAt = json['createdAt'];
    targetDuration = json['targetDuration'];
    actualDuration = json['actualDuration'];
    chantCount = json['chantCount'];
    chantingName = json['chantingName'];
  }
}

class Motivation {
  String? emoji;
  String? title;
  String? text;

  Motivation({this.emoji, this.title, this.text});

  Motivation.fromJson(Map<String, dynamic> json) {
    emoji = json['emoji'];
    title = json['title'];
    text = json['text'];
  }
}
