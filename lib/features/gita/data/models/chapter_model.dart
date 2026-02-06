import 'package:equatable/equatable.dart';

class ChapterModel extends Equatable {
  final String? id;
  final String? name;
  final int? chapterNumber;
  final String? description;
  final int? shlokaCount;
  final String? imageUrl;
  final String? nameHindi; // If it exists, otherwise relying on JSON provided

  const ChapterModel({
    this.id,
    this.name,
    this.chapterNumber,
    this.description,
    this.shlokaCount,
    this.imageUrl,
    this.nameHindi,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['_id'],
      name: json['name'],
      chapterNumber: json['chapterNumber'],
      description: json['description'],
      shlokaCount: json['shlokaCount'],
      imageUrl: json['imageUrl'],
      nameHindi: json['nameHindi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'chapterNumber': chapterNumber,
      'description': description,
      'shlokaCount': shlokaCount,
      'imageUrl': imageUrl,
      'nameHindi': nameHindi,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    chapterNumber,
    description,
    shlokaCount,
    imageUrl,
  ];
}
