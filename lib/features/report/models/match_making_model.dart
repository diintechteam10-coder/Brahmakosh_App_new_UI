class MatchMakingResponse {
  bool? success;
  String? message;
  MatchMakingData? data;

  MatchMakingResponse({this.success, this.message, this.data});

  MatchMakingResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = MatchMakingData.fromJson(json['data']);
    } else if (success == true) {
      // Fallback to root
      data = MatchMakingData.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class MatchMakingData {
  int? totalPoints;
  int? maxPoints;
  String? conclusion;
  List<KootaDetail>? kootaDetails;
  dynamic providerResponse;

  MatchMakingData({
    this.totalPoints,
    this.maxPoints,
    this.conclusion,
    this.kootaDetails,
    this.providerResponse,
  });

  MatchMakingData.fromJson(Map<String, dynamic> json) {
    // 1. Handle points from root or ashtakoota
    totalPoints = (json['total_points'] ?? json['totalPoints'] ?? 
                  json['ashtakoota']?['total_points'] ?? 
                  json['ashtakoota']?['totalPoints'])?.toInt();
    
    maxPoints = (json['max_points'] ?? json['maxPoints'] ?? 
                json['ashtakoota']?['max_points'] ?? 
                json['ashtakoota']?['maxPoints'])?.toInt();

    // 2. Handle conclusion (improved Map handling)
    final dynamic conclusionVal = json['conclusion'] ?? 
                                  json['conclusion_detail'] ??
                                  json['ashtakoota']?['conclusion'] ??
                                  json['ashtakoota']?['conclusion_detail'];
    
    if (conclusionVal is Map) {
      conclusion = conclusionVal['match_report']?.toString() ?? 
                   conclusionVal['report']?.toString() ?? 
                   conclusionVal.values.firstOrNull?.toString();
    } else {
      conclusion = conclusionVal?.toString();
    }

    // 3. Handle koota_details (List vs Map)
    if (json['koota_details'] != null && json['koota_details'] is List) {
      kootaDetails = <KootaDetail>[];
      json['koota_details'].forEach((v) {
        kootaDetails!.add(KootaDetail.fromJson(v));
      });
    } else if (json['kootaDetails'] != null && json['kootaDetails'] is List) {
      kootaDetails = <KootaDetail>[];
      json['kootaDetails'].forEach((v) {
        kootaDetails!.add(KootaDetail.fromJson(v));
      });
    } else if (json['ashtakoota'] != null && json['ashtakoota'] is Map) {
      final Map<String, dynamic> ashMap = json['ashtakoota'];
      kootaDetails = <KootaDetail>[];
      ashMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          kootaDetails!.add(KootaDetail.fromMapWithName(key, value));
        }
      });
    }

    // 4. Fallback: Calculate totals if missing or zero
    if ((totalPoints == null || totalPoints == 0) && kootaDetails != null && kootaDetails!.isNotEmpty) {
      double calculatedTotal = 0;
      double calculatedMax = 0;
      for (var k in kootaDetails!) {
        calculatedTotal += (k.obtainedPoints?.toDouble() ?? 0.0);
        calculatedMax += (k.totalPoints?.toDouble() ?? 0.0);
      }
      totalPoints = calculatedTotal.round();
      if (maxPoints == null || maxPoints == 0) {
        maxPoints = calculatedMax.round();
      }
    }

    providerResponse = json['providerResponse'] ?? json['provider_response'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_points'] = totalPoints;
    data['max_points'] = maxPoints;
    data['conclusion'] = conclusion;
    if (kootaDetails != null) {
      data['koota_details'] = kootaDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  /// Compatibility percentage
  double get compatibilityPercent {
    if (maxPoints == null || maxPoints == 0) return 0;
    return ((totalPoints ?? 0) / maxPoints!) * 100;
  }
}

class KootaDetail {
  String? name;
  num? obtainedPoints;
  num? totalPoints;
  String? description;

  KootaDetail({
    this.name,
    this.obtainedPoints,
    this.totalPoints,
    this.description,
  });

  KootaDetail.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    obtainedPoints = json['obtained_points'] ?? json['obtainedPoints'] ?? json['received_points'];
    totalPoints = json['total_points'] ?? json['totalPoints'];
    description = json['description']?.toString() ?? json['result']?.toString();
  }

  /// Special factory for reading'varna': {...} Map entries
  KootaDetail.fromMapWithName(String keyName, Map<String, dynamic> json) {
    name = keyName[0].toUpperCase() + keyName.substring(1);
    obtainedPoints = json['received_points'] ?? json['obtained_points'] ?? json['obtainedPoints'];
    totalPoints = json['total_points'] ?? json['totalPoints'];
    description = json['description']?.toString() ?? json['result']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['obtained_points'] = obtainedPoints;
    data['total_points'] = totalPoints;
    data['description'] = description;
    return data;
  }
}

class MatchMakingRequest {
  final int mDay;
  final int mMonth;
  final int mYear;
  final int mHour;
  final int mMin;
  final double mLat;
  final double mLon;
  final double mTzone;
  final int fDay;
  final int fMonth;
  final int fYear;
  final int fHour;
  final int fMin;
  final double fLat;
  final double fLon;
  final double fTzone;

  MatchMakingRequest({
    required this.mDay,
    required this.mMonth,
    required this.mYear,
    required this.mHour,
    required this.mMin,
    required this.mLat,
    required this.mLon,
    required this.mTzone,
    required this.fDay,
    required this.fMonth,
    required this.fYear,
    required this.fHour,
    required this.fMin,
    required this.fLat,
    required this.fLon,
    required this.fTzone,
  });

  Map<String, dynamic> toJson() {
    return {
      'm_day': mDay,
      'm_month': mMonth,
      'm_year': mYear,
      'm_hour': mHour,
      'm_min': mMin,
      'm_lat': mLat,
      'm_lon': mLon,
      'm_tzone': mTzone,
      'f_day': fDay,
      'f_month': fMonth,
      'f_year': fYear,
      'f_hour': fHour,
      'f_min': fMin,
      'f_lat': fLat,
      'f_lon': fLon,
      'f_tzone': fTzone,
    };
  }
}
