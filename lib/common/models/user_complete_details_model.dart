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
  String? lastCalculated;
  String? calculationSource;

  Astrology({
    this.birthDetails,
    this.astroDetails,
    this.planets,
    this.planetsExtended,
    this.birthChart,
    this.birthExtendedChart,
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
  });

  AstroDetails.fromJson(Map<String, dynamic> json) {
    ascendant = json['ascendant'];
    ascendantLord = json['ascendantLord'];
    sign = json['sign'];
    signLord = json['signLord'];
    nakshatra = json['nakshatra'];
    nakshatraLord = json['nakshatraLord'];
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
    nameAlphabet = json['nameAlphabet'];
    paya = json['paya'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ascendant'] = ascendant;
    data['ascendantLord'] = ascendantLord;
    data['sign'] = sign;
    data['signLord'] = signLord;
    data['nakshatra'] = nakshatra;
    data['nakshatraLord'] = nakshatraLord;
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
    data['nameAlphabet'] = nameAlphabet;
    data['paya'] = paya;
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
