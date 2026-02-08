class PanchangResponse {
  bool? success;
  PanchangData? data;

  PanchangResponse({this.success, this.data});

  PanchangResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? new PanchangData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PanchangData {
  String? dateKey;
  String? requestDate;
  Location? location;
  BasicPanchang? basicPanchang;
  AdvancedPanchang? advancedPanchang;
  ChaughadiyaMuhurta? chaughadiyaMuhurta;
  DailyNakshatraPrediction? dailyNakshatraPrediction;
  NumeroDailyPrediction? numeroDailyPrediction;
  String? lastCalculated;
  String? calculationSource;

  PanchangData({
    this.dateKey,
    this.requestDate,
    this.location,
    this.basicPanchang,
    this.advancedPanchang,
    this.chaughadiyaMuhurta,
    this.dailyNakshatraPrediction,
    this.numeroDailyPrediction,
    this.lastCalculated,
    this.calculationSource,
  });

  PanchangData.fromJson(Map<String, dynamic> json) {
    dateKey = json['dateKey'];
    requestDate = json['requestDate'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    basicPanchang = json['basicPanchang'] != null
        ? new BasicPanchang.fromJson(json['basicPanchang'])
        : null;
    advancedPanchang = json['advancedPanchang'] != null
        ? new AdvancedPanchang.fromJson(json['advancedPanchang'])
        : null;
    chaughadiyaMuhurta = json['chaughadiyaMuhurta'] != null
        ? new ChaughadiyaMuhurta.fromJson(json['chaughadiyaMuhurta'])
        : null;
    dailyNakshatraPrediction = json['dailyNakshatraPrediction'] != null
        ? new DailyNakshatraPrediction.fromJson(
            json['dailyNakshatraPrediction'],
          )
        : null;
    numeroDailyPrediction = json['numeroDailyPrediction'] != null
        ? new NumeroDailyPrediction.fromJson(json['numeroDailyPrediction'])
        : null;
    lastCalculated = json['lastCalculated'];
    calculationSource = json['calculationSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dateKey'] = this.dateKey;
    data['requestDate'] = this.requestDate;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    if (this.basicPanchang != null) {
      data['basicPanchang'] = this.basicPanchang!.toJson();
    }
    if (this.advancedPanchang != null) {
      data['advancedPanchang'] = this.advancedPanchang!.toJson();
    }
    if (this.chaughadiyaMuhurta != null) {
      data['chaughadiyaMuhurta'] = this.chaughadiyaMuhurta!.toJson();
    }
    if (this.dailyNakshatraPrediction != null) {
      data['dailyNakshatraPrediction'] = this.dailyNakshatraPrediction!
          .toJson();
    }
    if (this.numeroDailyPrediction != null) {
      data['numeroDailyPrediction'] = this.numeroDailyPrediction!.toJson();
    }
    data['lastCalculated'] = this.lastCalculated;
    data['calculationSource'] = this.calculationSource;
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class BasicPanchang {
  String? day;
  String? tithi;
  String? nakshatra;
  String? yog;
  String? karan;
  String? sunrise;
  String? sunset;
  String? vedicSunrise;
  String? vedicSunset;
  String? moonrise;
  String? moonset;
  String? ayana;
  String? paksha;
  String? ritu;
  String? sunSign;
  String? moonSign;
  String? panchangYog;
  int? vikramSamvat;
  int? shakaSamvat;
  String? vkramSamvatName;
  String? shakaSamvatName;
  String? dishaShool;
  String? dishaShoolRemedies;
  String? moonNivas;

  BasicPanchang({
    this.day,
    this.tithi,
    this.nakshatra,
    this.yog,
    this.karan,
    this.sunrise,
    this.sunset,
    this.vedicSunrise,
    this.vedicSunset,
    this.moonrise,
    this.moonset,
    this.ayana,
    this.paksha,
    this.ritu,
    this.sunSign,
    this.moonSign,
    this.panchangYog,
    this.vikramSamvat,
    this.shakaSamvat,
    this.vkramSamvatName,
    this.shakaSamvatName,
    this.dishaShool,
    this.dishaShoolRemedies,
    this.moonNivas,
  });

  BasicPanchang.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    tithi = json['tithi'];
    nakshatra = json['nakshatra'];
    yog = json['yog'];
    karan = json['karan'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
    vedicSunrise = json['vedicSunrise'];
    vedicSunset = json['vedicSunset'];
    moonrise = json['moonrise'];
    moonset = json['moonset'];
    ayana = json['ayana'];
    paksha = json['paksha'];
    ritu = json['ritu'];
    sunSign = json['sunSign'];
    moonSign = json['moonSign'];
    panchangYog = json['panchangYog'];
    vikramSamvat = json['vikramSamvat'];
    shakaSamvat = json['shakaSamvat'];
    vkramSamvatName = json['vkramSamvatName'];
    shakaSamvatName = json['shakaSamvatName'];
    dishaShool = json['dishaShool'];
    dishaShoolRemedies = json['dishaShoolRemedies'];
    moonNivas = json['moonNivas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['tithi'] = this.tithi;
    data['nakshatra'] = this.nakshatra;
    data['yog'] = this.yog;
    data['karan'] = this.karan;
    data['sunrise'] = this.sunrise;
    data['sunset'] = this.sunset;
    data['vedicSunrise'] = this.vedicSunrise;
    data['vedicSunset'] = this.vedicSunset;
    data['moonrise'] = this.moonrise;
    data['moonset'] = this.moonset;
    data['ayana'] = this.ayana;
    data['paksha'] = this.paksha;
    data['ritu'] = this.ritu;
    data['sunSign'] = this.sunSign;
    data['moonSign'] = this.moonSign;
    data['panchangYog'] = this.panchangYog;
    data['vikramSamvat'] = this.vikramSamvat;
    data['shakaSamvat'] = this.shakaSamvat;
    data['vkramSamvatName'] = this.vkramSamvatName;
    data['shakaSamvatName'] = this.shakaSamvatName;
    data['dishaShool'] = this.dishaShool;
    data['dishaShoolRemedies'] = this.dishaShoolRemedies;
    data['moonNivas'] = this.moonNivas;
    return data;
  }
}

class AdvancedPanchang {
  NakShool? nakShool;
  HinduMaah? hinduMaah;
  TimeRange? abhijitMuhurta;
  TimeRange? rahukaal;
  TimeRange? guliKaal;
  TimeRange? yamghantKaal;
  Panchang? panchang;
  String? day;
  String? sunrise;
  String? sunset;
  String? moonrise;
  String? moonset;
  String? vedicSunrise;
  String? vedicSunset;
  String? ayana;
  String? paksha;
  String? ritu;
  String? sunSign;
  String? moonSign;
  String? panchangYog;
  int? vikramSamvat;
  int? shakaSamvat;
  String? vkramSamvatName;
  String? shakaSamvatName;
  String? dishaShool;
  String? dishaShoolRemedies;
  String? moonNivas;

  AdvancedPanchang({
    this.nakShool,
    this.hinduMaah,
    this.abhijitMuhurta,
    this.rahukaal,
    this.guliKaal,
    this.yamghantKaal,
    this.panchang,
    this.day,
    this.sunrise,
    this.sunset,
    this.moonrise,
    this.moonset,
    this.vedicSunrise,
    this.vedicSunset,
    this.ayana,
    this.paksha,
    this.ritu,
    this.sunSign,
    this.moonSign,
    this.panchangYog,
    this.vikramSamvat,
    this.shakaSamvat,
    this.vkramSamvatName,
    this.shakaSamvatName,
    this.dishaShool,
    this.dishaShoolRemedies,
    this.moonNivas,
  });

  AdvancedPanchang.fromJson(Map<String, dynamic> json) {
    nakShool = json['nakShool'] != null
        ? new NakShool.fromJson(json['nakShool'])
        : null;
    hinduMaah = json['hinduMaah'] != null
        ? new HinduMaah.fromJson(json['hinduMaah'])
        : null;
    abhijitMuhurta = json['abhijitMuhurta'] != null
        ? new TimeRange.fromJson(json['abhijitMuhurta'])
        : null;
    rahukaal = json['rahukaal'] != null
        ? new TimeRange.fromJson(json['rahukaal'])
        : null;
    guliKaal = json['guliKaal'] != null
        ? new TimeRange.fromJson(json['guliKaal'])
        : null;
    yamghantKaal = json['yamghantKaal'] != null
        ? new TimeRange.fromJson(json['yamghantKaal'])
        : null;
    panchang = json['panchang'] != null
        ? new Panchang.fromJson(json['panchang'])
        : null;
    day = json['day'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
    moonrise = json['moonrise'];
    moonset = json['moonset'];
    vedicSunrise = json['vedicSunrise'];
    vedicSunset = json['vedicSunset'];
    ayana = json['ayana'];
    paksha = json['paksha'];
    ritu = json['ritu'];
    sunSign = json['sunSign'];
    moonSign = json['moonSign'];
    panchangYog = json['panchangYog'];
    vikramSamvat = json['vikramSamvat'];
    shakaSamvat = json['shakaSamvat'];
    vkramSamvatName = json['vkramSamvatName'];
    shakaSamvatName = json['shakaSamvatName'];
    dishaShool = json['dishaShool'];
    dishaShoolRemedies = json['dishaShoolRemedies'];
    moonNivas = json['moonNivas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.nakShool != null) {
      data['nakShool'] = this.nakShool!.toJson();
    }
    if (this.hinduMaah != null) {
      data['hinduMaah'] = this.hinduMaah!.toJson();
    }
    if (this.abhijitMuhurta != null) {
      data['abhijitMuhurta'] = this.abhijitMuhurta!.toJson();
    }
    if (this.rahukaal != null) {
      data['rahukaal'] = this.rahukaal!.toJson();
    }
    if (this.guliKaal != null) {
      data['guliKaal'] = this.guliKaal!.toJson();
    }
    if (this.yamghantKaal != null) {
      data['yamghantKaal'] = this.yamghantKaal!.toJson();
    }
    if (this.panchang != null) {
      data['panchang'] = this.panchang!.toJson();
    }
    data['day'] = this.day;
    data['sunrise'] = this.sunrise;
    data['sunset'] = this.sunset;
    data['moonrise'] = this.moonrise;
    data['moonset'] = this.moonset;
    data['vedicSunrise'] = this.vedicSunrise;
    data['vedicSunset'] = this.vedicSunset;
    data['ayana'] = this.ayana;
    data['paksha'] = this.paksha;
    data['ritu'] = this.ritu;
    data['sunSign'] = this.sunSign;
    data['moonSign'] = this.moonSign;
    data['panchangYog'] = this.panchangYog;
    data['vikramSamvat'] = this.vikramSamvat;
    data['shakaSamvat'] = this.shakaSamvat;
    data['vkramSamvatName'] = this.vkramSamvatName;
    data['shakaSamvatName'] = this.shakaSamvatName;
    data['dishaShool'] = this.dishaShool;
    data['dishaShoolRemedies'] = this.dishaShoolRemedies;
    data['moonNivas'] = this.moonNivas;
    return data;
  }
}

class NakShool {
  String? direction;
  String? remedies;

  NakShool({this.direction, this.remedies});

  NakShool.fromJson(Map<String, dynamic> json) {
    direction = json['direction'];
    remedies = json['remedies'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['direction'] = this.direction;
    data['remedies'] = this.remedies;
    return data;
  }
}

class HinduMaah {
  bool? adhikStatus;
  String? purnimanta;
  String? amanta;
  int? amantaId;
  int? purnimantaId;

  HinduMaah({
    this.adhikStatus,
    this.purnimanta,
    this.amanta,
    this.amantaId,
    this.purnimantaId,
  });

  HinduMaah.fromJson(Map<String, dynamic> json) {
    adhikStatus = json['adhikStatus'];
    purnimanta = json['purnimanta'];
    amanta = json['amanta'];
    amantaId = json['amantaId'];
    purnimantaId = json['purnimantaId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adhikStatus'] = this.adhikStatus;
    data['purnimanta'] = this.purnimanta;
    data['amanta'] = this.amanta;
    data['amantaId'] = this.amantaId;
    data['purnimantaId'] = this.purnimantaId;
    return data;
  }
}

class TimeRange {
  String? start;
  String? end;

  TimeRange({this.start, this.end});

  TimeRange.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start'] = this.start;
    data['end'] = this.end;
    return data;
  }
}

class Panchang {
  PanchangItem? tithi;
  PanchangItem? nakshatra;
  PanchangItem? yog;
  PanchangItem? karan;

  Panchang({this.tithi, this.nakshatra, this.yog, this.karan});

  Panchang.fromJson(Map<String, dynamic> json) {
    tithi = json['tithi'] != null
        ? new PanchangItem.fromJson(json['tithi'])
        : null;
    nakshatra = json['nakshatra'] != null
        ? new PanchangItem.fromJson(json['nakshatra'])
        : null;
    yog = json['yog'] != null ? new PanchangItem.fromJson(json['yog']) : null;
    karan = json['karan'] != null
        ? new PanchangItem.fromJson(json['karan'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tithi != null) {
      data['tithi'] = this.tithi!.toJson();
    }
    if (this.nakshatra != null) {
      data['nakshatra'] = this.nakshatra!.toJson();
    }
    if (this.yog != null) {
      data['yog'] = this.yog!.toJson();
    }
    if (this.karan != null) {
      data['karan'] = this.karan!.toJson();
    }
    return data;
  }
}

class PanchangItem {
  dynamic details;
  EndTime? endTime;
  int? endTimeMs;

  PanchangItem({this.details, this.endTime, this.endTimeMs});

  PanchangItem.fromJson(Map<String, dynamic> json) {
    details = json['details'];
    endTime = json['end_time'] != null
        ? new EndTime.fromJson(json['end_time'])
        : null;
    endTimeMs = json['end_time_ms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['details'] = this.details;
    if (this.endTime != null) {
      data['end_time'] = this.endTime!.toJson();
    }
    data['end_time_ms'] = this.endTimeMs;
    return data;
  }
}

class EndTime {
  int? hour;
  int? minute;
  int? second;

  EndTime({this.hour, this.minute, this.second});

  EndTime.fromJson(Map<String, dynamic> json) {
    hour = json['hour'];
    minute = json['minute'];
    second = json['second'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hour'] = this.hour;
    data['minute'] = this.minute;
    data['second'] = this.second;
    return data;
  }
}

class ChaughadiyaMuhurta {
  List<MuhurtaItem>? day;
  List<MuhurtaItem>? night;

  ChaughadiyaMuhurta({this.day, this.night});

  ChaughadiyaMuhurta.fromJson(Map<String, dynamic> json) {
    if (json['day'] != null) {
      day = <MuhurtaItem>[];
      json['day'].forEach((v) {
        day!.add(new MuhurtaItem.fromJson(v));
      });
    }
    if (json['night'] != null) {
      night = <MuhurtaItem>[];
      json['night'].forEach((v) {
        night!.add(new MuhurtaItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.day != null) {
      data['day'] = this.day!.map((v) => v.toJson()).toList();
    }
    if (this.night != null) {
      data['night'] = this.night!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MuhurtaItem {
  String? time;
  String? muhurta;

  MuhurtaItem({this.time, this.muhurta});

  MuhurtaItem.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    muhurta = json['muhurta'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['muhurta'] = this.muhurta;
    return data;
  }
}

class DailyNakshatraPrediction {
  String? birthMoonSign;
  String? birthMoonNakshatra;
  String? predictionDate;
  String? nakshatra;
  Prediction? prediction;
  String? botResponse;
  String? mood;
  String? moodPercentage;
  String? luckyTime;
  List<String>? luckyColor;
  List<String>? luckyNumber;

  DailyNakshatraPrediction({
    this.birthMoonSign,
    this.birthMoonNakshatra,
    this.predictionDate,
    this.nakshatra,
    this.prediction,
    this.botResponse,
    this.mood,
    this.moodPercentage,
    this.luckyTime,
    this.luckyColor,
    this.luckyNumber,
  });

  DailyNakshatraPrediction.fromJson(Map<String, dynamic> json) {
    birthMoonSign = json['birthMoonSign'];
    birthMoonNakshatra = json['birthMoonNakshatra'];
    predictionDate = json['predictionDate'];
    nakshatra = json['nakshatra'];
    prediction = json['prediction'] != null
        ? new Prediction.fromJson(json['prediction'])
        : null;
    botResponse = json['bot_response'];
    mood = json['mood'];
    moodPercentage = json['mood_percentage'];
    luckyTime = json['lucky_time'];
    if (json['lucky_color'] != null) {
      luckyColor = json['lucky_color'].cast<String>();
    }
    if (json['lucky_number'] != null) {
      luckyNumber = json['lucky_number'].cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['birthMoonSign'] = this.birthMoonSign;
    data['birthMoonNakshatra'] = this.birthMoonNakshatra;
    data['predictionDate'] = this.predictionDate;
    data['nakshatra'] = this.nakshatra;
    if (this.prediction != null) {
      data['prediction'] = this.prediction!.toJson();
    }
    data['bot_response'] = this.botResponse;
    data['mood'] = this.mood;
    data['mood_percentage'] = this.moodPercentage;
    data['lucky_time'] = this.luckyTime;
    data['lucky_color'] = this.luckyColor;
    data['lucky_number'] = this.luckyNumber;
    return data;
  }
}

class NumeroDailyPrediction {
  String? prediction;
  String? luckyColor;
  String? luckyNumber;
  String? predictionDate;

  NumeroDailyPrediction({
    this.prediction,
    this.luckyColor,
    this.luckyNumber,
    this.predictionDate,
  });

  NumeroDailyPrediction.fromJson(Map<String, dynamic> json) {
    prediction = json['prediction'];
    luckyColor = json['lucky_color'];
    luckyNumber = json['lucky_number'];
    predictionDate = json['prediction_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prediction'] = this.prediction;
    data['lucky_color'] = this.luckyColor;
    data['lucky_number'] = this.luckyNumber;
    data['prediction_date'] = this.predictionDate;
    return data;
  }
}

class Prediction {
  String? health;
  String? emotions;
  String? profession;
  String? luck;
  String? personalLife;
  String? travel;

  Prediction({
    this.health,
    this.emotions,
    this.profession,
    this.luck,
    this.personalLife,
    this.travel,
  });

  Prediction.fromJson(Map<String, dynamic> json) {
    health = json['health'];
    emotions = json['emotions'];
    profession = json['profession'];
    luck = json['luck'];
    personalLife = json['personal_life'];
    travel = json['travel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['health'] = this.health;
    data['emotions'] = this.emotions;
    data['profession'] = this.profession;
    data['luck'] = this.luck;
    data['personal_life'] = this.personalLife;
    data['travel'] = this.travel;
    return data;
  }
}
