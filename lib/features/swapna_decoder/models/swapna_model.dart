class SwapnaModel {
  String id;
  String symbolName;
  String symbolNameHindi;
  String category;
  String subcategory;
  String? thumbnailUrl;
  String? shortDescription;
  String? detailedInterpretation;
  List<SwapnaPoint>? positiveAspects;
  List<SwapnaPoint>? negativeAspects;
  List<SwapnaContext>? contextVariations;
  String? astrologicalSignificance;
  String? vedicReferences;
  SwapnaRemedies? remedies;
  List<String>? relatedSymbols;
  String? frequencyImpact;
  SwapnaTimeSignificance? timeSignificance;
  SwapnaGenderSpecific? genderSpecific;
  List<String>? tags;
  int? sortOrder;
  int? viewCount;
  String? createdAt;

  SwapnaModel({
    required this.id,
    required this.symbolName,
    required this.symbolNameHindi,
    required this.category,
    required this.subcategory,
    this.thumbnailUrl,
    this.shortDescription,
    this.detailedInterpretation,
    this.positiveAspects,
    this.negativeAspects,
    this.contextVariations,
    this.astrologicalSignificance,
    this.vedicReferences,
    this.remedies,
    this.relatedSymbols,
    this.frequencyImpact,
    this.timeSignificance,
    this.genderSpecific,
    this.tags,
    this.sortOrder,
    this.viewCount,
    this.createdAt,
  });

  factory SwapnaModel.fromJson(Map<String, dynamic> json) {
    return SwapnaModel(
      id: json['_id'] ?? '',
      symbolName: json['symbolName'] ?? '',
      symbolNameHindi: json['symbolNameHindi'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      shortDescription: json['shortDescription'],
      detailedInterpretation: json['detailedInterpretation'],
      positiveAspects: (json['positiveAspects'] as List<dynamic>?)
          ?.map((e) => SwapnaPoint.fromJson(e))
          .toList(),
      negativeAspects: (json['negativeAspects'] as List<dynamic>?)
          ?.map((e) => SwapnaPoint.fromJson(e))
          .toList(),
      contextVariations: (json['contextVariations'] as List<dynamic>?)
          ?.map((e) => SwapnaContext.fromJson(e))
          .toList(),
      astrologicalSignificance: json['astrologicalSignificance'],
      vedicReferences: json['vedicReferences'],
      remedies: json['remedies'] != null
          ? SwapnaRemedies.fromJson(json['remedies'])
          : null,
      relatedSymbols: (json['relatedSymbols'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      frequencyImpact: json['frequencyImpact'],
      timeSignificance: json['timeSignificance'] != null
          ? SwapnaTimeSignificance.fromJson(json['timeSignificance'])
          : null,
      genderSpecific: json['genderSpecific'] != null
          ? SwapnaGenderSpecific.fromJson(json['genderSpecific'])
          : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      sortOrder: json['sortOrder'],
      viewCount: json['viewCount'],
      createdAt: json['createdAt'],
    );
  }
}

class SwapnaPoint {
  String point;
  String description;

  SwapnaPoint({required this.point, required this.description});

  factory SwapnaPoint.fromJson(Map<String, dynamic> json) {
    return SwapnaPoint(
      point: json['point'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SwapnaContext {
  String context;
  String meaning;

  SwapnaContext({required this.context, required this.meaning});

  factory SwapnaContext.fromJson(Map<String, dynamic> json) {
    return SwapnaContext(
      context: json['context'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }
}

class SwapnaRemedies {
  List<String>? mantras;
  List<String>? pujas;
  List<String>? donations;
  List<String>? precautions;

  SwapnaRemedies({this.mantras, this.pujas, this.donations, this.precautions});

  factory SwapnaRemedies.fromJson(Map<String, dynamic> json) {
    return SwapnaRemedies(
      mantras: (json['mantras'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      pujas: (json['pujas'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      donations: (json['donations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      precautions: (json['precautions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class SwapnaTimeSignificance {
  String? morning;
  String? night;
  String? brahmaMuhurat;

  SwapnaTimeSignificance({this.morning, this.night, this.brahmaMuhurat});

  factory SwapnaTimeSignificance.fromJson(Map<String, dynamic> json) {
    return SwapnaTimeSignificance(
      morning: json['morning'],
      night: json['night'],
      brahmaMuhurat: json['brahmaMuhurat'],
    );
  }
}

class SwapnaGenderSpecific {
  String? male;
  String? female;
  String? common;

  SwapnaGenderSpecific({this.male, this.female, this.common});

  factory SwapnaGenderSpecific.fromJson(Map<String, dynamic> json) {
    return SwapnaGenderSpecific(
      male: json['male'],
      female: json['female'],
      common: json['common'],
    );
  }
}
