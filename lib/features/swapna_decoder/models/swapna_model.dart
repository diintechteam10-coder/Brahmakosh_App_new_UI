class SwapnaModel {
  final String id;
  final String symbolName;
  final String symbolNameHindi;
  final String category;
  final String subcategory;
  final String? thumbnailUrl;
  final String? shortDescription;
  final String? detailedInterpretation;
  final List<SwapnaPoint>? positiveAspects;
  final List<SwapnaPoint>? negativeAspects;
  final List<SwapnaContext>? contextVariations;
  final String? astrologicalSignificance;
  final String? vedicReferences;
  final SwapnaRemedies? remedies;
  final List<String>? relatedSymbols;
  final String? frequencyImpact;
  final SwapnaTimeSignificance? timeSignificance;
  final SwapnaGenderSpecific? genderSpecific;
  final List<String>? tags;
  final int? sortOrder;
  final int? viewCount;
  final String? createdAt;

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
  final String point;
  final String description;

  SwapnaPoint({required this.point, required this.description});

  factory SwapnaPoint.fromJson(Map<String, dynamic> json) {
    return SwapnaPoint(
      point: json['point'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SwapnaContext {
  final String context;
  final String meaning;

  SwapnaContext({required this.context, required this.meaning});

  factory SwapnaContext.fromJson(Map<String, dynamic> json) {
    return SwapnaContext(
      context: json['context'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }
}

class SwapnaRemedies {
  final List<String>? mantras;
  final List<String>? pujas;
  final List<String>? donations;
  final List<String>? precautions;

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
  final String? morning;
  final String? night;
  final String? brahmaMuhurat;

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
  final String? male;
  final String? female;
  final String? common;

  SwapnaGenderSpecific({this.male, this.female, this.common});

  factory SwapnaGenderSpecific.fromJson(Map<String, dynamic> json) {
    return SwapnaGenderSpecific(
      male: json['male'],
      female: json['female'],
      common: json['common'],
    );
  }
}
