class UserCompleteDetailsModel {
  bool? success;
  Data? data;

  UserCompleteDetailsModel({this.success, this.data});

  UserCompleteDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  User? user;
  Astrology? astrology;

  Data({this.user, this.astrology});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    astrology = json['astrology'] != null
        ? Astrology.fromJson(json['astrology'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (astrology != null) {
      data['astrology'] = astrology!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? email;
  String? authMethod;
  Profile? profile;
  bool? emailVerified;
  bool? mobileVerified;
  int? registrationStep;
  bool? loginApproved;
  bool? isActive;
  ClientId? clientId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  LiveLocation? liveLocation;

  User({
    this.sId,
    this.email,
    this.authMethod,
    this.profile,
    this.emailVerified,
    this.mobileVerified,
    this.registrationStep,
    this.loginApproved,
    this.isActive,
    this.clientId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.liveLocation,
  });

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    authMethod = json['authMethod'];
    profile = json['profile'] != null
        ? Profile.fromJson(json['profile'])
        : null;
    emailVerified = json['emailVerified'];
    mobileVerified = json['mobileVerified'];
    registrationStep = json['registrationStep'];
    loginApproved = json['loginApproved'];
    isActive = json['isActive'];
    clientId = json['clientId'] != null
        ? ClientId.fromJson(json['clientId'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    liveLocation = json['liveLocation'] != null
        ? LiveLocation.fromJson(json['liveLocation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['authMethod'] = authMethod;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    data['emailVerified'] = emailVerified;
    data['mobileVerified'] = mobileVerified;
    data['registrationStep'] = registrationStep;
    data['loginApproved'] = loginApproved;
    data['isActive'] = isActive;
    if (clientId != null) {
      data['clientId'] = clientId!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (liveLocation != null) {
      data['liveLocation'] = liveLocation!.toJson();
    }
    return data;
  }
}

class Profile {
  String? name;
  String? dob;
  String? timeOfBirth;
  String? placeOfBirth;
  double? latitude;
  double? longitude;
  String? gowthra;

  Profile({
    this.name,
    this.dob,
    this.timeOfBirth,
    this.placeOfBirth,
    this.latitude,
    this.longitude,
    this.gowthra,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dob = json['dob'];
    timeOfBirth = json['timeOfBirth'];
    placeOfBirth = json['placeOfBirth'];
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    gowthra = json['gowthra'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['dob'] = dob;
    data['timeOfBirth'] = timeOfBirth;
    data['placeOfBirth'] = placeOfBirth;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['gowthra'] = gowthra;
    return data;
  }
}

class ClientId {
  String? sId;
  String? email;
  String? businessName;
  String? clientId;

  ClientId({this.sId, this.email, this.businessName, this.clientId});

  ClientId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    businessName = json['businessName'];
    clientId = json['clientId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['businessName'] = businessName;
    data['clientId'] = clientId;
    return data;
  }
}

class LiveLocation {
  double? latitude;
  double? longitude;
  String? formattedAddress;
  String? city;
  String? state;
  String? country;
  String? lastUpdated;

  LiveLocation({
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.city,
    this.state,
    this.country,
    this.lastUpdated,
  });

  LiveLocation.fromJson(Map<String, dynamic> json) {
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    formattedAddress = json['formattedAddress'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    lastUpdated = json['lastUpdated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['formattedAddress'] = formattedAddress;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['lastUpdated'] = lastUpdated;
    return data;
  }
}

class Astrology {
  BirthDetails? birthDetails;
  AstroDetails? astroDetails;
  List<Planets>? planets;
  List<Planets>? planetsExtended;
  BirthChart? birthChart;
  BirthExtendedChart? birthExtendedChart;
  Doshas? doshas;
  Dashas? dashas;
  String? lastCalculated;
  String? calculationSource;

  Astrology({
    this.birthDetails,
    this.astroDetails,
    this.planets,
    this.planetsExtended,
    this.birthChart,
    this.birthExtendedChart,
    this.doshas,
    this.dashas,
    this.lastCalculated,
    this.calculationSource,
  });

  Astrology.fromJson(Map<String, dynamic> json) {
    birthDetails = json['birthDetails'] != null
        ? BirthDetails.fromJson(json['birthDetails'])
        : null;
    astroDetails = json['astroDetails'] != null
        ? AstroDetails.fromJson(json['astroDetails'])
        : null;
    if (json['planets'] != null) {
      planets = <Planets>[];
      json['planets'].forEach((v) {
        planets!.add(Planets.fromJson(v));
      });
    }
    if (json['planetsExtended'] != null) {
      planetsExtended = <Planets>[];
      json['planetsExtended'].forEach((v) {
        planetsExtended!.add(Planets.fromJson(v));
      });
    }
    birthChart = json['birthChart'] != null
        ? BirthChart.fromJson(json['birthChart'])
        : null;
    birthExtendedChart = json['birthExtendedChart'] != null
        ? BirthExtendedChart.fromJson(json['birthExtendedChart'])
        : null;
    doshas = json['doshas'] != null ? Doshas.fromJson(json['doshas']) : null;
    dashas = json['dashas'] != null ? Dashas.fromJson(json['dashas']) : null;
    lastCalculated = json['lastCalculated'];
    calculationSource = json['calculationSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (birthDetails != null) {
      data['birthDetails'] = birthDetails!.toJson();
    }
    if (astroDetails != null) {
      data['astroDetails'] = astroDetails!.toJson();
    }
    if (planets != null) {
      data['planets'] = planets!.map((v) => v.toJson()).toList();
    }
    if (planetsExtended != null) {
      data['planetsExtended'] = planetsExtended!
          .map((v) => v.toJson())
          .toList();
    }
    if (birthChart != null) {
      data['birthChart'] = birthChart!.toJson();
    }
    if (birthExtendedChart != null) {
      data['birthExtendedChart'] = birthExtendedChart!.toJson();
    }
    if (doshas != null) {
      data['doshas'] = doshas!.toJson();
    }
    if (dashas != null) {
      data['dashas'] = dashas!.toJson();
    }
    data['lastCalculated'] = lastCalculated;
    data['calculationSource'] = calculationSource;
    return data;
  }
}

class BirthDetails {
  int? day;
  int? month;
  int? year;
  int? hour;
  int? minute;
  double? latitude;
  double? longitude;
  double? ayanamsha;
  String? sunrise;
  String? sunset;

  BirthDetails({
    this.day,
    this.month,
    this.year,
    this.hour,
    this.minute,
    this.latitude,
    this.longitude,
    this.ayanamsha,
    this.sunrise,
    this.sunset,
  });

  BirthDetails.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    month = json['month'];
    year = json['year'];
    hour = json['hour'];
    minute = json['minute'];
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    ayanamsha = (json['ayanamsha'] as num?)?.toDouble();
    sunrise = json['sunrise'];
    sunset = json['sunset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['month'] = month;
    data['year'] = year;
    data['hour'] = hour;
    data['minute'] = minute;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['ayanamsha'] = ayanamsha;
    data['sunrise'] = sunrise;
    data['sunset'] = sunset;
    return data;
  }
}

class AstroDetails {
  String? ascendant;
  String? ascendantLord;
  String? sign;
  String? signLord;
  String? nakshatra;
  String? nakshatraLord;
  String? charan;
  String? varna;
  String? vashya;
  String? yoni;
  String? gan;
  String? nadi;
  String? tithi;
  String? yog;
  String? karan;
  String? yunja;
  String? tatva;
  String? nameAlphabet;
  String? paya;
  String? luckyColor;
  String? luckyNumber;

  AstroDetails({
    this.ascendant,
    this.ascendantLord,
    this.sign,
    this.signLord,
    this.nakshatra,
    this.nakshatraLord,
    this.charan,
    this.varna,
    this.vashya,
    this.yoni,
    this.gan,
    this.nadi,
    this.tithi,
    this.yog,
    this.karan,
    this.yunja,
    this.tatva,
    this.nameAlphabet,
    this.paya,
    this.luckyColor,
    this.luckyNumber,
  });

  AstroDetails.fromJson(Map<String, dynamic> json) {
    ascendant = json['ascendant'];
    ascendantLord = json['ascendantLord'] ?? json['ascendant_lord'];
    sign = json['sign'];
    signLord = json['signLord'] ?? json['sign_lord'];
    nakshatra = json['nakshatra'];
    nakshatraLord = json['nakshatraLord'] ?? json['nakshatra_lord'];
    charan = json['charan'];
    varna = json['varna'];
    vashya = json['vashya'];
    yoni = json['yoni'];
    gan = json['gan'];
    nadi = json['nadi'];
    tithi = json['tithi'];
    yog = json['yog'];
    karan = json['karan'];
    yunja = json['yunja'];
    tatva = json['tatva'];
    nameAlphabet = json['nameAlphabet'] ?? json['name_alphabet'];
    paya = json['paya'];
    luckyColor = json['luckyColor'] ?? json['lucky_color'];
    luckyNumber = json['luckyNumber'] != null
        ? json['luckyNumber'].toString()
        : json['lucky_number']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ascendant'] = ascendant;
    data['ascendant_lord'] = ascendantLord;
    data['sign'] = sign;
    data['sign_lord'] = signLord;
    data['nakshatra'] = nakshatra;
    data['nakshatra_lord'] = nakshatraLord;
    data['charan'] = charan;
    data['varna'] = varna;
    data['vashya'] = vashya;
    data['yoni'] = yoni;
    data['gan'] = gan;
    data['nadi'] = nadi;
    data['tithi'] = tithi;
    data['yog'] = yog;
    data['karan'] = karan;
    data['yunja'] = yunja;
    data['tatva'] = tatva;
    data['name_alphabet'] = nameAlphabet;
    data['paya'] = paya;
    data['lucky_color'] = luckyColor;
    data['lucky_number'] = luckyNumber;
    return data;
  }
}

class Planets {
  int? id;
  String? name;
  double? fullDegree;
  double? normDegree;
  double? speed;
  String? isRetro;
  String? sign;
  String? signLord;
  String? nakshatra;
  String? nakshatraLord;
  int? nakshatraPad;
  int? house;
  bool? isPlanetSet;
  String? planetAwastha;

  Planets({
    this.id,
    this.name,
    this.fullDegree,
    this.normDegree,
    this.speed,
    this.isRetro,
    this.sign,
    this.signLord,
    this.nakshatra,
    this.nakshatraLord,
    this.nakshatraPad,
    this.house,
    this.isPlanetSet,
    this.planetAwastha,
  });

  Planets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullDegree = (json['fullDegree'] as num?)?.toDouble();
    normDegree = (json['normDegree'] as num?)?.toDouble();
    speed = (json['speed'] as num?)?.toDouble();
    isRetro = json['isRetro'];
    sign = json['sign'];
    signLord = json['signLord'];
    nakshatra = json['nakshatra'];
    nakshatraLord = json['nakshatraLord'];
    nakshatraPad = json['nakshatra_pad'];
    house = json['house'];
    isPlanetSet = json['is_planet_set'];
    planetAwastha = json['planet_awastha'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['fullDegree'] = fullDegree;
    data['normDegree'] = normDegree;
    data['speed'] = speed;
    data['isRetro'] = isRetro;
    data['sign'] = sign;
    data['signLord'] = signLord;
    data['nakshatra'] = nakshatra;
    data['nakshatraLord'] = nakshatraLord;
    data['nakshatra_pad'] = nakshatraPad;
    data['house'] = house;
    data['is_planet_set'] = isPlanetSet;
    data['planet_awastha'] = planetAwastha;
    return data;
  }
}

class BirthChart {
  Houses? houses;

  BirthChart({this.houses});

  BirthChart.fromJson(Map<String, dynamic> json) {
    houses = json['houses'] != null ? Houses.fromJson(json['houses']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (houses != null) {
      data['houses'] = houses!.toJson();
    }
    return data;
  }
}

class Houses {
  List<String>? house1;
  List<String>? house2;
  List<String>? house3;
  List<String>? house4;
  List<String>? house5;
  List<String>? house6;
  List<String>? house7;
  List<String>? house8;
  List<String>? house9;
  List<String>? house10;
  List<String>? house11;
  List<String>? house12;

  Houses({
    this.house1,
    this.house2,
    this.house3,
    this.house4,
    this.house5,
    this.house6,
    this.house7,
    this.house8,
    this.house9,
    this.house10,
    this.house11,
    this.house12,
  });

  Houses.fromJson(Map<String, dynamic> json) {
    house1 = json['1']?.cast<String>();
    house2 = json['2']?.cast<String>();
    house3 = json['3']?.cast<String>();
    house4 = json['4']?.cast<String>();
    house5 = json['5']?.cast<String>();
    house6 = json['6']?.cast<String>();
    house7 = json['7']?.cast<String>();
    house8 = json['8']?.cast<String>();
    house9 = json['9']?.cast<String>();
    house10 = json['10']?.cast<String>();
    house11 = json['11']?.cast<String>();
    house12 = json['12']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['1'] = house1;
    data['2'] = house2;
    data['3'] = house3;
    data['4'] = house4;
    data['5'] = house5;
    data['6'] = house6;
    data['7'] = house7;
    data['8'] = house8;
    data['9'] = house9;
    data['10'] = house10;
    data['11'] = house11;
    data['12'] = house12;
    return data;
  }
}

class BirthExtendedChart {
  HousesExtended? houses;

  BirthExtendedChart({this.houses});

  BirthExtendedChart.fromJson(Map<String, dynamic> json) {
    houses = json['houses'] != null
        ? HousesExtended.fromJson(json['houses'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (houses != null) {
      data['houses'] = houses!.toJson();
    }
    return data;
  }
}

class HousesExtended {
  List<String>? house1;
  List<String>? house2;
  List<String>? house3;
  List<String>? house4;
  List<String>? house5;
  List<String>? house6;
  List<String>? house7;
  List<String>? house8;
  List<String>? house9;
  List<String>? house10;
  List<String>? house11;
  List<String>? house12;

  HousesExtended({
    this.house1,
    this.house2,
    this.house3,
    this.house4,
    this.house5,
    this.house6,
    this.house7,
    this.house8,
    this.house9,
    this.house10,
    this.house11,
    this.house12,
  });

  HousesExtended.fromJson(Map<String, dynamic> json) {
    house1 = json['1']?.cast<String>();
    house2 = json['2']?.cast<String>();
    house3 = json['3']?.cast<String>();
    house4 = json['4']?.cast<String>();
    house5 = json['5']?.cast<String>();
    house6 = json['6']?.cast<String>();
    house7 = json['7']?.cast<String>();
    house8 = json['8']?.cast<String>();
    house9 = json['9']?.cast<String>();
    house10 = json['10']?.cast<String>();
    house11 = json['11']?.cast<String>();
    house12 = json['12']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['1'] = house1;
    data['2'] = house2;
    data['3'] = house3;
    data['4'] = house4;
    data['5'] = house5;
    data['6'] = house6;
    data['7'] = house7;
    data['8'] = house8;
    data['9'] = house9;
    data['10'] = house10;
    data['11'] = house11;
    data['12'] = house12;
    return data;
  }
}

class Doshas {
  Manglik? manglik;
  Kalsarpa? kalsarpa;
  SadeSatiCurrent? sadeSatiCurrent;
  SadeSatiLife? sadeSatiLife;
  Pitra? pitra;

  Doshas({
    this.manglik,
    this.kalsarpa,
    this.sadeSatiCurrent,
    this.sadeSatiLife,
    this.pitra,
  });

  Doshas.fromJson(Map<String, dynamic> json) {
    manglik = json['manglik'] != null
        ? Manglik.fromJson(json['manglik'])
        : null;
    sadeSatiCurrent = json['sadeSatiCurrent'] != null
        ? SadeSatiCurrent.fromJson(json['sadeSatiCurrent'])
        : (json['sade_sati_current'] != null
              ? SadeSatiCurrent.fromJson(json['sade_sati_current'])
              : null);
    sadeSatiLife = json['sadeSatiLife'] != null
        ? SadeSatiLife.fromJson(json['sadeSatiLife'])
        : (json['sade_sati_life'] != null
              ? SadeSatiLife.fromJson(json['sade_sati_life'])
              : null);
    pitra = json['pitra'] != null ? Pitra.fromJson(json['pitra']) : null;
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
      data['sade_sati_current'] = sadeSatiCurrent!.toJson();
    }
    if (sadeSatiLife != null) {
      data['sade_sati_life'] = sadeSatiLife!.toJson();
    }
    if (pitra != null) {
      data['pitra'] = pitra!.toJson();
    }
    return data;
  }
}

class Manglik {
  bool? present;
  String? status;
  // ignore: prefer_void_to_null
  Null percentage;
  // ignore: prefer_void_to_null
  Null description;
  RawManglik? raw;

  Manglik({
    this.present,
    this.status,
    this.percentage,
    this.description,
    this.raw,
  });

  Manglik.fromJson(Map<String, dynamic> json) {
    present = json['present'];
    status = json['status'];
    percentage = json['percentage'];
    description = json['description'];
    raw = json['raw'] != null ? RawManglik.fromJson(json['raw']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['status'] = status;
    data['percentage'] = percentage;
    data['description'] = description;
    if (raw != null) {
      data['raw'] = raw!.toJson();
    }
    return data;
  }
}

class RawManglik {
  ManglikPresentRule? manglikPresentRule;
  List<String>? manglikCancelRule;
  bool? isMarsManglikCancelled;
  String? manglikStatus;
  double? percentageManglikPresent;
  double? percentageManglikAfterCancellation;
  String? manglikReport;
  bool? isPresent;

  RawManglik({
    this.manglikPresentRule,
    this.manglikCancelRule,
    this.isMarsManglikCancelled,
    this.manglikStatus,
    this.percentageManglikPresent,
    this.percentageManglikAfterCancellation,
    this.manglikReport,
    this.isPresent,
  });

  RawManglik.fromJson(Map<String, dynamic> json) {
    manglikPresentRule = json['manglik_present_rule'] != null
        ? ManglikPresentRule.fromJson(json['manglik_present_rule'])
        : null;
    if (json['manglik_cancel_rule'] != null) {
      manglikCancelRule = json['manglik_cancel_rule'].cast<String>();
    }
    isMarsManglikCancelled = json['is_mars_manglik_cancelled'];
    manglikStatus = json['manglik_status'];
    percentageManglikPresent = (json['percentage_manglik_present'] as num?)
        ?.toDouble();
    percentageManglikAfterCancellation =
        (json['percentage_manglik_after_cancellation'] as num?)?.toDouble();
    manglikReport = json['manglik_report'];
    isPresent = json['is_present'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (manglikPresentRule != null) {
      data['manglik_present_rule'] = manglikPresentRule!.toJson();
    }
    data['manglik_cancel_rule'] = manglikCancelRule;
    data['is_mars_manglik_cancelled'] = isMarsManglikCancelled;
    data['manglik_status'] = manglikStatus;
    data['percentage_manglik_present'] = percentageManglikPresent;
    data['percentage_manglik_after_cancellation'] =
        percentageManglikAfterCancellation;
    data['manglik_report'] = manglikReport;
    data['is_present'] = isPresent;
    return data;
  }
}

class ManglikPresentRule {
  List<String>? basedOnAspect;
  List<String>? basedOnHouse;

  ManglikPresentRule({this.basedOnAspect, this.basedOnHouse});

  ManglikPresentRule.fromJson(Map<String, dynamic> json) {
    basedOnAspect = json['based_on_aspect']?.cast<String>();
    basedOnHouse = json['based_on_house']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['based_on_aspect'] = basedOnAspect;
    data['based_on_house'] = basedOnHouse;
    return data;
  }
}

class Kalsarpa {
  bool? present;
  // ignore: prefer_void_to_null
  Null status;
  // ignore: prefer_void_to_null
  Null type;
  // ignore: prefer_void_to_null
  Null description;
  RawKalsarpa? raw;

  Kalsarpa({this.present, this.status, this.type, this.description, this.raw});

  Kalsarpa.fromJson(Map<String, dynamic> json) {
    present = json['present'];
    status = json['status'];
    type = json['type'];
    description = json['description'];
    raw = json['raw'] != null ? RawKalsarpa.fromJson(json['raw']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['status'] = status;
    data['type'] = type;
    data['description'] = description;
    if (raw != null) {
      data['raw'] = raw!.toJson();
    }
    return data;
  }
}

class RawKalsarpa {
  bool? present;
  String? oneLine;

  RawKalsarpa({this.present, this.oneLine});

  RawKalsarpa.fromJson(Map<String, dynamic> json) {
    present = json['present'];
    oneLine = json['one_line'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['one_line'] = oneLine;
    return data;
  }
}

class SadeSatiCurrent {
  bool? present;
  String? status;
  String? considerationDate;
  bool? isUndergoing;
  RawSadeSatiCurrent? raw;

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
    raw = json['raw'] != null ? RawSadeSatiCurrent.fromJson(json['raw']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['status'] = status;
    data['considerationDate'] = considerationDate;
    data['isUndergoing'] = isUndergoing;
    if (raw != null) {
      data['raw'] = raw!.toJson();
    }
    return data;
  }
}

class RawSadeSatiCurrent {
  String? considerationDate;
  bool? isSaturnRetrograde;
  String? moonSign;
  String? saturnSign;
  String? isUndergoingSadhesati;
  bool? sadhesatiStatus;
  String? whatIsSadhesati;

  RawSadeSatiCurrent({
    this.considerationDate,
    this.isSaturnRetrograde,
    this.moonSign,
    this.saturnSign,
    this.isUndergoingSadhesati,
    this.sadhesatiStatus,
    this.whatIsSadhesati,
  });

  RawSadeSatiCurrent.fromJson(Map<String, dynamic> json) {
    considerationDate = json['consideration_date'];
    isSaturnRetrograde = json['is_saturn_retrograde'];
    moonSign = json['moon_sign'];
    saturnSign = json['saturn_sign'];
    isUndergoingSadhesati = json['is_undergoing_sadhesati'];
    sadhesatiStatus = json['sadhesati_status'];
    whatIsSadhesati = json['what_is_sadhesati'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['consideration_date'] = considerationDate;
    data['is_saturn_retrograde'] = isSaturnRetrograde;
    data['moon_sign'] = moonSign;
    data['saturn_sign'] = saturnSign;
    data['is_undergoing_sadhesati'] = isUndergoingSadhesati;
    data['sadhesati_status'] = sadhesatiStatus;
    data['what_is_sadhesati'] = whatIsSadhesati;
    return data;
  }
}

class SadeSatiLife {
  bool? present;
  String? status;
  // ignore: prefer_void_to_null
  Null considerationDate;
  bool? isUndergoing;
  List<RawSadeSati>? raw;

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
      raw = <RawSadeSati>[];
      json['raw'].forEach((v) {
        raw!.add(RawSadeSati.fromJson(v));
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

class RawSadeSati {
  String? moonSign;
  String? saturnSign;
  bool? isSaturnRetrograde;
  String? type;
  String? millisecond;
  String? date;
  String? summary;

  RawSadeSati({
    this.moonSign,
    this.saturnSign,
    this.isSaturnRetrograde,
    this.type,
    this.millisecond,
    this.date,
    this.summary,
  });

  RawSadeSati.fromJson(Map<String, dynamic> json) {
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

class Pitra {
  bool? present;
  // ignore: prefer_void_to_null
  Null oneLine;
  // ignore: prefer_void_to_null
  Null description;
  RawPitra? raw;

  Pitra({this.present, this.oneLine, this.description, this.raw});

  Pitra.fromJson(Map<String, dynamic> json) {
    present = json['present'];
    oneLine = json['oneLine'];
    description = json['description'];
    raw = json['raw'] != null ? RawPitra.fromJson(json['raw']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['present'] = present;
    data['oneLine'] = oneLine;
    data['description'] = description;
    if (raw != null) {
      data['raw'] = raw!.toJson();
    }
    return data;
  }
}

class RawPitra {
  String? whatIsPitriDosha;
  bool? isPitriDoshaPresent;
  List<String>? rulesMatched;
  String? conclusion;
  List<String>? remedies;
  List<String>? effects;

  RawPitra({
    this.whatIsPitriDosha,
    this.isPitriDoshaPresent,
    this.rulesMatched,
    this.conclusion,
    this.remedies,
    this.effects,
  });

  RawPitra.fromJson(Map<String, dynamic> json) {
    whatIsPitriDosha = json['what_is_pitri_dosha'];
    isPitriDoshaPresent = json['is_pitri_dosha_present'];
    rulesMatched = json['rules_matched']?.cast<String>();
    conclusion = json['conclusion'];
    remedies = json['remedies']?.cast<String>();
    effects = json['effects']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['what_is_pitri_dosha'] = whatIsPitriDosha;
    data['is_pitri_dosha_present'] = isPitriDoshaPresent;
    data['rules_matched'] = rulesMatched;
    data['conclusion'] = conclusion;
    data['remedies'] = remedies;
    data['effects'] = effects;
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
        : (json['current_yogini_dasha'] != null
              ? CurrentYogini.fromJson(json['current_yogini_dasha'])
              : null);
    currentChardasha = json['currentChardasha'] != null
        ? CurrentChardasha.fromJson(json['currentChardasha'])
        : (json['current_chardasha'] != null
              ? CurrentChardasha.fromJson(json['current_chardasha'])
              : null);
    if (json['majorChardasha'] != null) {
      majorChardasha = <MajorChardasha>[];
      json['majorChardasha'].forEach((v) {
        majorChardasha!.add(MajorChardasha.fromJson(v));
      });
    } else if (json['major_chardasha'] != null) {
      majorChardasha = <MajorChardasha>[];
      json['major_chardasha'].forEach((v) {
        majorChardasha!.add(MajorChardasha.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentYogini != null) {
      data['current_yogini_dasha'] = currentYogini!.toJson();
    }
    if (currentChardasha != null) {
      data['current_chardasha'] = currentChardasha!.toJson();
    }
    if (majorChardasha != null) {
      data['major_chardasha'] = majorChardasha!.map((v) => v.toJson()).toList();
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

  SubDasha({this.dashaId, this.dashaName, this.startDate, this.endDate});

  SubDasha.fromJson(Map<String, dynamic> json) {
    dashaId = json['dasha_id'];
    dashaName = json['dasha_name'];
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

class SubSubDasha {
  int? dashaId;
  String? dashaName;
  String? startDate;
  String? endDate;

  SubSubDasha({this.dashaId, this.dashaName, this.startDate, this.endDate});

  SubSubDasha.fromJson(Map<String, dynamic> json) {
    dashaId = json['dasha_id'];
    dashaName = json['dasha_name'];
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
  MajorChardashaSign? majorDasha;
  SubChardashaSign? subDasha;
  SubSubChardashaSign? subSubDasha;

  CurrentChardasha({
    this.dashaDate,
    this.majorDasha,
    this.subDasha,
    this.subSubDasha,
  });

  CurrentChardasha.fromJson(Map<String, dynamic> json) {
    dashaDate = json['dasha_date'];
    majorDasha = json['major_dasha'] != null
        ? MajorChardashaSign.fromJson(json['major_dasha'])
        : null;
    subDasha = json['sub_dasha'] != null
        ? SubChardashaSign.fromJson(json['sub_dasha'])
        : null;
    subSubDasha = json['sub_sub_dasha'] != null
        ? SubSubChardashaSign.fromJson(json['sub_sub_dasha'])
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

class MajorChardashaSign {
  int? signId;
  String? signName;
  String? duration;
  String? startDate;
  String? endDate;

  MajorChardashaSign({
    this.signId,
    this.signName,
    this.duration,
    this.startDate,
    this.endDate,
  });

  MajorChardashaSign.fromJson(Map<String, dynamic> json) {
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

class SubChardashaSign {
  int? signId;
  String? signName;
  String? duration;
  String? startDate;
  String? endDate;

  SubChardashaSign({
    this.signId,
    this.signName,
    this.duration,
    this.startDate,
    this.endDate,
  });

  SubChardashaSign.fromJson(Map<String, dynamic> json) {
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

class SubSubChardashaSign {
  int? signId;
  String? signName;
  String? startDate;
  String? endDate;

  SubSubChardashaSign({
    this.signId,
    this.signName,
    this.startDate,
    this.endDate,
  });

  SubSubChardashaSign.fromJson(Map<String, dynamic> json) {
    signId = json['sign_id'];
    signName = json['sign_name'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sign_id'] = signId;
    data['sign_name'] = signName;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
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
