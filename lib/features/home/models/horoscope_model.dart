class DailyHoroscope {
  final bool? status;
  final String? sunSign;
  final String? predictionDate;
  final DailyPrediction? prediction;

  DailyHoroscope({
    this.status,
    this.sunSign,
    this.predictionDate,
    this.prediction,
  });

  factory DailyHoroscope.fromJson(Map<String, dynamic> json) {
    return DailyHoroscope(
      status: json['status'],
      sunSign: json['sun_sign'],
      predictionDate: json['prediction_date'],
      prediction: json['prediction'] != null
          ? DailyPrediction.fromJson(json['prediction'])
          : null,
    );
  }
}

class DailyPrediction {
  final String? personalLife;
  final String? profession;
  final String? health;
  final String? travel;
  final String? luck;
  final String? emotions;

  DailyPrediction({
    this.personalLife,
    this.profession,
    this.health,
    this.travel,
    this.luck,
    this.emotions,
  });

  factory DailyPrediction.fromJson(Map<String, dynamic> json) {
    return DailyPrediction(
      personalLife: json['personal_life'],
      profession: json['profession'],
      health: json['health'],
      travel: json['travel'],
      luck: json['luck'],
      emotions: json['emotions'],
    );
  }

  Map<String, String?> toMap() {
    return {
      'Personal Life': personalLife,
      'Profession': profession,
      'Health': health,
      'Travel': travel,
      'Luck': luck,
      'Emotions': emotions,
    };
  }
}

class MonthlyHoroscope {
  final bool? status;
  final String? sunSign;
  final String? predictionMonth;
  final List<String>? prediction;

  MonthlyHoroscope({
    this.status,
    this.sunSign,
    this.predictionMonth,
    this.prediction,
  });

  factory MonthlyHoroscope.fromJson(Map<String, dynamic> json) {
    return MonthlyHoroscope(
      status: json['status'],
      sunSign: json['sun_sign'],
      predictionMonth: json['prediction_month'],
      prediction: json['prediction'] != null
          ? List<String>.from(json['prediction'])
          : null,
    );
  }
}
