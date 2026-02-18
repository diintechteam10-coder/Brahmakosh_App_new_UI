class DoshaDashaModel {
  bool? success;
  DoshaDashaData? data;

  DoshaDashaModel({this.success, this.data});

  DoshaDashaModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? DoshaDashaData.fromJson(json['data']) : null;
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

class DoshaDashaData {
  BirthData? birthData;
  Doshas? doshas;
  Dashas? dashas;
  Summary? summary;

  DoshaDashaData({this.birthData, this.doshas, this.dashas, this.summary});

  DoshaDashaData.fromJson(Map<String, dynamic> json) {
    birthData = json['birthData'] != null
        ? BirthData.fromJson(json['birthData'])
        : null;
    doshas = json['doshas'] != null ? Doshas.fromJson(json['doshas']) : null;
    dashas = json['dashas'] != null ? Dashas.fromJson(json['dashas']) : null;
    summary = json['summary'] != null
        ? Summary.fromJson(json['summary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (birthData != null) {
      data['birthData'] = birthData!.toJson();
    }
    if (doshas != null) {
      data['doshas'] = doshas!.toJson();
    }
    if (dashas != null) {
      data['dashas'] = dashas!.toJson();
    }
    if (summary != null) {
      data['summary'] = summary!.toJson();
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

class Doshas {
  DoshaDetail? manglik;
  DoshaDetail? kalsarpa;
  SadeSatiCurrent? sadeSatiCurrent;
  SadeSatiLife? sadeSatiLife;
  DoshaDetail? pitra;

  Doshas({
    this.manglik,
    this.kalsarpa,
    this.sadeSatiCurrent,
    this.sadeSatiLife,
    this.pitra,
  });

  Doshas.fromJson(Map<String, dynamic> json) {
    manglik = json['manglik'] != null
        ? DoshaDetail.fromJson(json['manglik'])
        : null;
    kalsarpa = json['kalsarpa'] != null
        ? DoshaDetail.fromJson(json['kalsarpa'])
        : null;
    sadeSatiCurrent = json['sadeSatiCurrent'] != null
        ? SadeSatiCurrent.fromJson(json['sadeSatiCurrent'])
        : null;
    sadeSatiLife = json['sadeSatiLife'] != null
        ? SadeSatiLife.fromJson(json['sadeSatiLife'])
        : null;
    pitra = json['pitra'] != null ? DoshaDetail.fromJson(json['pitra']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (manglik != null) {
      data['manglik'] = manglik!.toJson();
    }
    if (kalsarpa != null) {
      data['kalsarpa'] = kalsarpa!.toJson();
    }
    if (sadeSatiCurrent != null) {
      data['sadeSatiCurrent'] = sadeSatiCurrent!.toJson();
    }
    if (sadeSatiLife != null) {
      data['sadeSatiLife'] = sadeSatiLife!.toJson();
    }
    if (pitra != null) {
      data['pitra'] = pitra!.toJson();
    }
    return data;
  }
}

class DoshaDetail {
  bool? present;
  String? status;
  // ignore: prefer_typing_uninitialized_variables
  var percentage;
  String? description;
  dynamic raw;
  String? oneLine;
  String? manglikReport;
  String? conclusion;

  DoshaDetail({
    this.present,
    this.status,
    this.percentage,
    this.description,
    this.raw,
    this.oneLine,
    this.manglikReport,
    this.conclusion,
  });

  DoshaDetail.fromJson(Map<String, dynamic> json) {
    present = json['present'];
    status = json['status'];
    percentage = json['percentage'];
    description = json['description'];
    raw = json['raw'];

    // Try to get from root first
    oneLine = json['one_line'] ?? json['oneLine'];
    manglikReport = json['manglik_report'];
    conclusion = json['conclusion'];

    // Check if raw is a Map and extract fields if they weren't found at root
    if (raw != null && raw is Map) {
      final rawMap = raw as Map;
      if (oneLine == null) {
        oneLine = rawMap['one_line'] ?? rawMap['oneLine'];
      }
      if (manglikReport == null) {
        manglikReport = rawMap['manglik_report'];
      }
      if (conclusion == null) {
        conclusion = rawMap['conclusion'];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['status'] = status;
    data['percentage'] = percentage;
    data['description'] = description;
    data['raw'] = raw;
    data['one_line'] = oneLine; // Write back as snake_case standard
    data['manglik_report'] = manglikReport;
    data['conclusion'] = conclusion;
    return data;
  }
}

class SadeSatiCurrent {
  bool? present;
  String? status;
  String? considerationDate;
  bool? isUndergoing;
  dynamic raw;

  SadeSatiCurrent({
    this.present,
    this.status,
    this.considerationDate,
    this.isUndergoing,
    this.raw,
  });

  SadeSatiCurrent.fromJson(Map<String, dynamic> json) {
    present = json['present'];
    status = json['status'];
    considerationDate = json['considerationDate'];
    isUndergoing = json['isUndergoing'];
    raw = json['raw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['status'] = status;
    data['considerationDate'] = considerationDate;
    data['isUndergoing'] = isUndergoing;
    data['raw'] = raw;
    return data;
  }
}

class SadeSatiLife {
  bool? present;
  String? status;
  String? considerationDate;
  bool? isUndergoing;
  List<SadeSatiLifeRaw>? raw;

  SadeSatiLife({
    this.present,
    this.status,
    this.considerationDate,
    this.isUndergoing,
    this.raw,
  });

  SadeSatiLife.fromJson(Map<String, dynamic> json) {
    present = json['present'];
    status = json['status'];
    considerationDate = json['considerationDate'];
    isUndergoing = json['isUndergoing'];
    if (json['raw'] != null) {
      raw = <SadeSatiLifeRaw>[];
      json['raw'].forEach((v) {
        raw!.add(SadeSatiLifeRaw.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['status'] = status;
    data['considerationDate'] = considerationDate;
    data['isUndergoing'] = isUndergoing;
    if (raw != null) {
      data['raw'] = raw!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SadeSatiLifeRaw {
  String? moonSign;
  String? saturnSign;
  bool? isSaturnRetrograde;
  String? type;
  String? millisecond;
  String? date;
  String? summary;

  SadeSatiLifeRaw({
    this.moonSign,
    this.saturnSign,
    this.isSaturnRetrograde,
    this.type,
    this.millisecond,
    this.date,
    this.summary,
  });

  SadeSatiLifeRaw.fromJson(Map<String, dynamic> json) {
    moonSign = json['moon_sign'];
    saturnSign = json['saturn_sign'];
    isSaturnRetrograde = json['is_saturn_retrograde'];
    type = json['type'];
    millisecond = json['millisecond'];
    date = json['date'];
    summary = json['summary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['moon_sign'] = moonSign;
    data['saturn_sign'] = saturnSign;
    data['is_saturn_retrograde'] = isSaturnRetrograde;
    data['type'] = type;
    data['millisecond'] = millisecond;
    data['date'] = date;
    data['summary'] = summary;
    return data;
  }
}

class Dashas {
  CurrentYogini? currentYogini;
  CurrentChardasha? currentChardasha;
  List<MajorChardasha>? majorChardasha;

  Dashas({this.currentYogini, this.currentChardasha, this.majorChardasha});

  Dashas.fromJson(Map<String, dynamic> json) {
    currentYogini = json['currentYogini'] != null
        ? CurrentYogini.fromJson(json['currentYogini'])
        : null;
    currentChardasha = json['currentChardasha'] != null
        ? CurrentChardasha.fromJson(json['currentChardasha'])
        : null;
    if (json['majorChardasha'] != null) {
      majorChardasha = <MajorChardasha>[];
      json['majorChardasha'].forEach((v) {
        majorChardasha!.add(MajorChardasha.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentYogini != null) {
      data['currentYogini'] = currentYogini!.toJson();
    }
    if (currentChardasha != null) {
      data['currentChardasha'] = currentChardasha!.toJson();
    }
    if (majorChardasha != null) {
      data['majorChardasha'] = majorChardasha!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrentYogini {
  MajorDasha? majorDasha;
  SubDasha? subDasha;
  SubSubDasha? subSubDasha;

  CurrentYogini({this.majorDasha, this.subDasha, this.subSubDasha});

  CurrentYogini.fromJson(Map<String, dynamic> json) {
    majorDasha = json['major_dasha'] != null
        ? MajorDasha.fromJson(json['major_dasha'])
        : null;
    subDasha = json['sub_dasha'] != null
        ? SubDasha.fromJson(json['sub_dasha'])
        : null;
    subSubDasha = json['sub_sub_dasha'] != null
        ? SubSubDasha.fromJson(json['sub_sub_dasha'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (majorDasha != null) {
      data['major_dasha'] = majorDasha!.toJson();
    }
    if (subDasha != null) {
      data['sub_dasha'] = subDasha!.toJson();
    }
    if (subSubDasha != null) {
      data['sub_sub_dasha'] = subSubDasha!.toJson();
    }
    return data;
  }
}

class MajorDasha {
  int? dashaId;
  String? dashaName;
  String? duration;
  String? startDate;
  String? endDate;

  MajorDasha({
    this.dashaId,
    this.dashaName,
    this.duration,
    this.startDate,
    this.endDate,
  });

  MajorDasha.fromJson(Map<String, dynamic> json) {
    dashaId = json['dasha_id'];
    dashaName = json['dasha_name'];
    duration = json['duration'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dasha_id'] = dashaId;
    data['dasha_name'] = dashaName;
    data['duration'] = duration;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}

class SubDasha {
  int? dashaId;
  String? dashaName;
  String? startDate;
  String? endDate;
  String? duration; // Optional, present in Char Dasha sub dasha

  SubDasha({
    this.dashaId,
    this.dashaName,
    this.startDate,
    this.endDate,
    this.duration,
  });

  SubDasha.fromJson(Map<String, dynamic> json) {
    dashaId = json['dasha_id']; // or sign_id for char dasha
    if (dashaId == null && json['sign_id'] != null) {
      dashaId = json['sign_id'];
    }
    dashaName = json['dasha_name'];
    if (dashaName == null && json['sign_name'] != null) {
      dashaName = json['sign_name'];
    }
    startDate = json['start_date'];
    endDate = json['end_date'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dasha_id'] = dashaId;
    data['dasha_name'] = dashaName;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    if (duration != null) data['duration'] = duration;
    return data;
  }
}

class SubSubDasha {
  int? dashaId;
  String? dashaName;
  String? startDate;
  String? endDate;

  SubSubDasha({this.dashaId, this.dashaName, this.startDate, this.endDate});

  SubSubDasha.fromJson(Map<String, dynamic> json) {
    dashaId = json['dasha_id'];
    if (dashaId == null && json['sign_id'] != null) {
      dashaId = json['sign_id'];
    }
    dashaName = json['dasha_name'];
    if (dashaName == null && json['sign_name'] != null) {
      dashaName = json['sign_name'];
    }
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dasha_id'] = dashaId;
    data['dasha_name'] = dashaName;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}

class CurrentChardasha {
  String? dashaDate;
  MajorChardasha? majorDasha;
  SubDasha? subDasha;
  SubSubDasha? subSubDasha;

  CurrentChardasha({
    this.dashaDate,
    this.majorDasha,
    this.subDasha,
    this.subSubDasha,
  });

  CurrentChardasha.fromJson(Map<String, dynamic> json) {
    dashaDate = json['dasha_date'];
    majorDasha = json['major_dasha'] != null
        ? MajorChardasha.fromJson(json['major_dasha'])
        : null;
    subDasha = json['sub_dasha'] != null
        ? SubDasha.fromJson(json['sub_dasha'])
        : null;
    subSubDasha = json['sub_sub_dasha'] != null
        ? SubSubDasha.fromJson(json['sub_sub_dasha'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dasha_date'] = dashaDate;
    if (majorDasha != null) {
      data['major_dasha'] = majorDasha!.toJson();
    }
    if (subDasha != null) {
      data['sub_dasha'] = subDasha!.toJson();
    }
    if (subSubDasha != null) {
      data['sub_sub_dasha'] = subSubDasha!.toJson();
    }
    return data;
  }
}

class MajorChardasha {
  int? signId;
  String? signName;
  String? duration;
  String? startDate;
  String? endDate;

  MajorChardasha({
    this.signId,
    this.signName,
    this.duration,
    this.startDate,
    this.endDate,
  });

  MajorChardasha.fromJson(Map<String, dynamic> json) {
    signId = json['sign_id'];
    signName = json['sign_name'];
    duration = json['duration'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sign_id'] = signId;
    data['sign_name'] = signName;
    data['duration'] = duration;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}

class Summary {
  bool? manglik;
  bool? kalsarpa;
  bool? sadeSatiCurrent;
  bool? sadeSatiLife;
  bool? pitra;
  bool? anyPresent;

  Summary({
    this.manglik,
    this.kalsarpa,
    this.sadeSatiCurrent,
    this.sadeSatiLife,
    this.pitra,
    this.anyPresent,
  });

  Summary.fromJson(Map<String, dynamic> json) {
    manglik = json['manglik'];
    kalsarpa = json['kalsarpa'];
    sadeSatiCurrent = json['sadeSatiCurrent'];
    sadeSatiLife = json['sadeSatiLife'];
    pitra = json['pitra'];
    anyPresent = json['anyPresent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['manglik'] = manglik;
    data['kalsarpa'] = kalsarpa;
    data['sadeSatiCurrent'] = sadeSatiCurrent;
    data['sadeSatiLife'] = sadeSatiLife;
    data['pitra'] = pitra;
    data['anyPresent'] = anyPresent;
    return data;
  }
}
