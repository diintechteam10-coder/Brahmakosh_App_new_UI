class NumerologyDetailResponse {
  bool? success;
  String? source;
  NumerologyDetailData? data;

  NumerologyDetailResponse({this.success, this.source, this.data});

  NumerologyDetailResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    source = json['source'];
    data = json['data'] != null
        ? NumerologyDetailData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['source'] = source;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class NumerologyDetailData {
  String? sId;
  String? userId;
  int? iV;
  String? createdAt;
  int? day;
  String? lastUpdated;
  int? month;
  String? name;
  NumeroReport? numeroReport;
  NumeroTable? numeroTable;
  String? updatedAt;
  int? year;
  DailyPrediction? dailyPrediction;
  Doshas? doshas;

  NumerologyDetailData({
    this.sId,
    this.userId,
    this.iV,
    this.createdAt,
    this.day,
    this.lastUpdated,
    this.month,
    this.name,
    this.numeroReport,
    this.numeroTable,
    this.updatedAt,
    this.year,
    this.dailyPrediction,
    this.doshas,
  });

  NumerologyDetailData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    day = json['day'];
    lastUpdated = json['lastUpdated'];
    month = json['month'];
    name = json['name'];
    numeroReport = json['numeroReport'] != null
        ? NumeroReport.fromJson(json['numeroReport'])
        : null;
    numeroTable = json['numeroTable'] != null
        ? NumeroTable.fromJson(json['numeroTable'])
        : null;
    updatedAt = json['updatedAt'];
    year = json['year'];
    dailyPrediction = json['dailyPrediction'] != null
        ? DailyPrediction.fromJson(json['dailyPrediction'])
        : null;
    doshas = json['doshas'] != null ? Doshas.fromJson(json['doshas']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['__v'] = iV;
    data['createdAt'] = createdAt;
    data['day'] = day;
    data['lastUpdated'] = lastUpdated;
    data['month'] = month;
    data['name'] = name;
    if (numeroReport != null) {
      data['numeroReport'] = numeroReport!.toJson();
    }
    if (numeroTable != null) {
      data['numeroTable'] = numeroTable!.toJson();
    }
    data['updatedAt'] = updatedAt;
    data['year'] = year;
    if (dailyPrediction != null) {
      data['dailyPrediction'] = dailyPrediction!.toJson();
    }
    if (doshas != null) {
      data['doshas'] = doshas!.toJson();
    }
    return data;
  }
}

class NumeroReport {
  String? title;
  String? description;

  NumeroReport({this.title, this.description});

  NumeroReport.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}

class NumeroTable {
  String? name;
  String? date;
  int? destinyNumber;
  int? radicalNumber;
  int? nameNumber;
  String? evilNum;
  String? favColor;
  String? favDay;
  String? favGod;
  String? favMantra;
  String? favMetal;
  String? favStone;
  String? favSubstone;
  String? friendlyNum;
  String? neutralNum;
  String? radicalNum;
  String? radicalRuler;

  NumeroTable({
    this.name,
    this.date,
    this.destinyNumber,
    this.radicalNumber,
    this.nameNumber,
    this.evilNum,
    this.favColor,
    this.favDay,
    this.favGod,
    this.favMantra,
    this.favMetal,
    this.favStone,
    this.favSubstone,
    this.friendlyNum,
    this.neutralNum,
    this.radicalNum,
    this.radicalRuler,
  });

  NumeroTable.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    date = json['date'];
    destinyNumber = json['destiny_number'];
    radicalNumber = json['radical_number'];
    nameNumber = json['name_number'];
    evilNum = json['evil_num'];
    favColor = json['fav_color'];
    favDay = json['fav_day'];
    favGod = json['fav_god'];
    favMantra = json['fav_mantra'];
    favMetal = json['fav_metal'];
    favStone = json['fav_stone'];
    favSubstone = json['fav_substone'];
    friendlyNum = json['friendly_num'];
    neutralNum = json['neutral_num'];
    radicalNum = json['radical_num'];
    radicalRuler = json['radical_ruler'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['date'] = date;
    data['destiny_number'] = destinyNumber;
    data['radical_number'] = radicalNumber;
    data['name_number'] = nameNumber;
    data['evil_num'] = evilNum;
    data['fav_color'] = favColor;
    data['fav_day'] = favDay;
    data['fav_god'] = favGod;
    data['fav_mantra'] = favMantra;
    data['fav_metal'] = favMetal;
    data['fav_stone'] = favStone;
    data['fav_substone'] = favSubstone;
    data['friendly_num'] = friendlyNum;
    data['neutral_num'] = neutralNum;
    data['radical_num'] = radicalNum;
    data['radical_ruler'] = radicalRuler;
    return data;
  }
}

class DailyPrediction {
  String? prediction;
  String? luckyColor;
  String? luckyNumber;
  String? predictionDate;

  DailyPrediction({
    this.prediction,
    this.luckyColor,
    this.luckyNumber,
    this.predictionDate,
  });

  DailyPrediction.fromJson(Map<String, dynamic> json) {
    prediction = json['prediction'];
    luckyColor = json['lucky_color'];
    luckyNumber = json['lucky_number'];
    predictionDate = json['prediction_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prediction'] = prediction;
    data['lucky_color'] = luckyColor;
    data['lucky_number'] = luckyNumber;
    data['prediction_date'] = predictionDate;
    return data;
  }
}

class Doshas {
  BirthData? birthData;
  // Add other dosha fields if strictly needed, otherwise skip to keep it light as we only need simple visuals

  Doshas({this.birthData});

  Doshas.fromJson(Map<String, dynamic> json) {
    birthData = json['birthData'] != null
        ? BirthData.fromJson(json['birthData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (birthData != null) {
      data['birthData'] = birthData!.toJson();
    }
    return data;
  }
}

class BirthData {
  int? day;
  int? month;
  int? year;
  int? hour;
  int? min;
  double? lat;
  double? lon;
  double? tzone;

  BirthData({
    this.day,
    this.month,
    this.year,
    this.hour,
    this.min,
    this.lat,
    this.lon,
    this.tzone,
  });

  BirthData.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    month = json['month'];
    year = json['year'];
    hour = json['hour'];
    min = json['min'];
    lat = json['lat'];
    lon = json['lon'];
    tzone = json['tzone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['month'] = month;
    data['year'] = year;
    data['hour'] = hour;
    data['min'] = min;
    data['lat'] = lat;
    data['lon'] = lon;
    data['tzone'] = tzone;
    return data;
  }
}
