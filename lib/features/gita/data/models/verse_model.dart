import 'package:equatable/equatable.dart';

class VerseModel extends Equatable {
  final String? id;
  final int? chapterNumber;
  final String? chapterName;
  final String? section;
  final String? shlokaNumber;
  final String? shlokaIndex;
  final String? sanskritShloka;
  final String? hindiMeaning;
  final String? englishMeaning;
  final String? sanskritTransliteration;
  final String? explanation;
  final String? tags;

  const VerseModel({
    this.id,
    this.chapterNumber,
    this.chapterName,
    this.section,
    this.shlokaNumber,
    this.shlokaIndex,
    this.sanskritShloka,
    this.hindiMeaning,
    this.englishMeaning,
    this.sanskritTransliteration,
    this.explanation,
    this.tags,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: json['_id'],
      chapterNumber: json['chapterNumber'],
      chapterName: json['chapterName'],
      section: json['section'],
      shlokaNumber: json['shlokaNumber'],
      shlokaIndex: json['shlokaIndex'],
      sanskritShloka: json['sanskritShloka'],
      hindiMeaning: json['hindiMeaning'],
      englishMeaning: json['englishMeaning'],
      sanskritTransliteration: json['sanskritTransliteration'],
      explanation: json['explanation'],
      tags: json['tags'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chapterNumber': chapterNumber,
      'chapterName': chapterName,
      'section': section,
      'shlokaNumber': shlokaNumber,
      'shlokaIndex': shlokaIndex,
      'sanskritShloka': sanskritShloka,
      'hindiMeaning': hindiMeaning,
      'englishMeaning': englishMeaning,
      'sanskritTransliteration': sanskritTransliteration,
      'explanation': explanation,
      'tags': tags,
    };
  }

  @override
  List<Object?> get props => [
    id,
    chapterNumber,
    shlokaNumber,
    sanskritShloka,
    hindiMeaning,
    englishMeaning,
  ];
}
