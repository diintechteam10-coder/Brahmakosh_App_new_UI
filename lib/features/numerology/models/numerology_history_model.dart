class NumerologyHistoryResponse {
  bool? success;
  NumerologyData? data;

  NumerologyHistoryResponse({this.success, this.data});

  NumerologyHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? NumerologyData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class NumerologyData {
  List<NumerologyHistoryItem>? history;
  int? total;
  int? limit;
  int? skip;
  bool? hasMore;

  NumerologyData({
    this.history,
    this.total,
    this.limit,
    this.skip,
    this.hasMore,
  });

  NumerologyData.fromJson(Map<String, dynamic> json) {
    if (json['history'] != null) {
      history = <NumerologyHistoryItem>[];
      json['history'].forEach((v) {
        history!.add(NumerologyHistoryItem.fromJson(v));
      });
    }
    total = json['total'];
    limit = json['limit'];
    skip = json['skip'];
    hasMore = json['hasMore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['limit'] = limit;
    data['skip'] = skip;
    data['hasMore'] = hasMore;
    return data;
  }
}

class NumerologyHistoryItem {
  String? sId;
  int? month;
  String? userId;
  int? day;
  int? year;
  int? iV;
  String? apiCallDate;
  String? createdAt;
  DailyPrediction? dailyPrediction;
  String? date;
  String? lastUpdated;
  String? name;
  NumeroReport? numeroReport;
  NumeroTable? numeroTable;
  String? updatedAt;

  NumerologyHistoryItem({
    this.sId,
    this.month,
    this.userId,
    this.day,
    this.year,
    this.iV,
    this.apiCallDate,
    this.createdAt,
    this.dailyPrediction,
    this.date,
    this.lastUpdated,
    this.name,
    this.numeroReport,
    this.numeroTable,
    this.updatedAt,
  });

  NumerologyHistoryItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    month = json['month'];
    userId = json['userId'];
    day = json['day'];
    year = json['year'];
    iV = json['__v'];
    apiCallDate = json['apiCallDate'];
    createdAt = json['createdAt'];
    dailyPrediction = json['dailyPrediction'] != null
        ? DailyPrediction.fromJson(json['dailyPrediction'])
        : null;
    date = json['date'];
    lastUpdated = json['lastUpdated'];
    name = json['name'];
    numeroReport = json['numeroReport'] != null
        ? NumeroReport.fromJson(json['numeroReport'])
        : null;
    numeroTable = json['numeroTable'] != null
        ? NumeroTable.fromJson(json['numeroTable'])
        : null;
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['month'] = month;
    data['userId'] = userId;
    data['day'] = day;
    data['year'] = year;
    data['__v'] = iV;
    data['apiCallDate'] = apiCallDate;
    data['createdAt'] = createdAt;
    if (dailyPrediction != null) {
      data['dailyPrediction'] = dailyPrediction!.toJson();
    }
    data['date'] = date;
    data['lastUpdated'] = lastUpdated;
    data['name'] = name;
    if (numeroReport != null) {
      data['numeroReport'] = numeroReport!.toJson();
    }
    if (numeroTable != null) {
      data['numeroTable'] = numeroTable!.toJson();
    }
    data['updatedAt'] = updatedAt;
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
