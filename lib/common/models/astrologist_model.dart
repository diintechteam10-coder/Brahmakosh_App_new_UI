import 'package:flutter/material.dart';

class Astrologist {
  final String id;
  final String name;
  final String image;
  final List<String> skills;
  final List<String> languages;
  final int experience;
  final double rating;
  final int totalConsultations;
  final double pricePerMinute;
  final bool isOnline;
  final String bio;
  final bool isFirstFree;
  final List<AstrologistReview> reviews;

  Astrologist({
    required this.id,
    required this.name,
    required this.image,
    required this.skills,
    required this.languages,
    required this.experience,
    required this.rating,
    required this.totalConsultations,
    required this.pricePerMinute,
    required this.isOnline,
    required this.bio,
    this.isFirstFree = false,
    this.reviews = const [],
  });
}

class AstrologistReview {
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime date;

  AstrologistReview({
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// API Models
class AstrologistModel {
  bool? success;
  List<AstrologistItem>? data;
  int? count;

  AstrologistModel({this.success, this.data, this.count});

  AstrologistModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <AstrologistItem>[];
      json['data'].forEach((v) {
        data!.add(AstrologistItem.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['success'] = success;
    if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }
    json['count'] = count;
    return json;
  }
}

class AstrologistItem {
  String? id;
  String? name;
  String? experience;
  String? expertise;
  String? profileSummary;
  String? profilePhoto;
  String? profilePhotoKey;
  String? backgroundBanner;
  String? backgroundBannerKey;
  int? chatCharge;
  int? voiceCharge;
  int? videoCharge;
  String? status;
  double? rating;
  int? reviews;
  String? clientId;
  String? categoryId;
  bool? isActive;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? version;
  List<String>? languages; // Added languages support

  AstrologistItem({
    this.id,
    this.name,
    this.experience,
    this.expertise,
    this.profileSummary,
    this.profilePhoto,
    this.profilePhotoKey,
    this.backgroundBanner,
    this.backgroundBannerKey,
    this.chatCharge,
    this.voiceCharge,
    this.videoCharge,
    this.status,
    this.rating,
    this.reviews,
    this.clientId,
    this.categoryId,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.languages,
  });

  AstrologistItem.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id']?.toString();
    name = json['name'];
    experience = json['experience'];
    expertise = json['expertise'];
    profileSummary = json['profileSummary'];
    profilePhoto = json['profilePhoto'];
    profilePhotoKey = json['profilePhotoKey'];
    backgroundBanner = json['backgroundBanner'];
    backgroundBannerKey = json['backgroundBannerKey'];
    chatCharge = json['chatCharge'];
    voiceCharge = json['voiceCharge'];
    videoCharge = json['videoCharge'];
    status = json['status'];
    rating = json['rating']?.toDouble() ?? 0.0;
    reviews = json['reviews'] ?? 0;
    clientId = json['clientId'];
    categoryId = json['categoryId'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    version = json['__v'];

    // Handle languages - can be a list or comma-separated string
    if (json['languages'] != null) {
      if (json['languages'] is List) {
        languages = List<String>.from(json['languages']);
      } else if (json['languages'] is String) {
        languages = (json['languages'] as String)
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
    } else {
      languages = ['Hindi', 'English']; // Default languages
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['_id'] = id;
    json['name'] = name;
    json['experience'] = experience;
    json['expertise'] = expertise;
    json['profileSummary'] = profileSummary;
    json['profilePhoto'] = profilePhoto;
    json['profilePhotoKey'] = profilePhotoKey;
    json['backgroundBanner'] = backgroundBanner;
    json['backgroundBannerKey'] = backgroundBannerKey;
    json['chatCharge'] = chatCharge;
    json['voiceCharge'] = voiceCharge;
    json['videoCharge'] = videoCharge;
    json['status'] = status;
    json['rating'] = rating;
    json['reviews'] = reviews;
    json['clientId'] = clientId;
    json['categoryId'] = categoryId;
    json['isActive'] = isActive;
    json['isDeleted'] = isDeleted;
    json['createdAt'] = createdAt;
    json['updatedAt'] = updatedAt;
    json['__v'] = version;
    json['languages'] = languages;
    return json;
  }

  // Convert to Astrologist model for UI
  Astrologist toAstrologist() {
    // Parse expertise to skills list
    List<String> skillsList = [];
    if (expertise != null && expertise!.isNotEmpty) {
      skillsList = expertise!.split(',').map((e) => e.trim()).toList();
    } else {
      skillsList = ['Vedic']; // Default skill
    }

    // Parse experience to int
    int expYears = 0;
    if (experience != null && experience!.isNotEmpty) {
      try {
        expYears = int.parse(experience!.replaceAll(RegExp(r'[^0-9]'), ''));
      } catch (e) {
        expYears = 0;
      }
    }

    return Astrologist(
      id: id ?? '',
      name: name ?? 'Astrologer',
      image: profilePhoto ?? '',
      skills: skillsList,
      languages: languages ?? ['Hindi', 'English'],
      experience: expYears,
      rating: rating ?? 4.5,
      totalConsultations: reviews ?? 0,
      pricePerMinute: (chatCharge ?? 0).toDouble(),
      isOnline:
          status?.toLowerCase() == 'online' ||
          status?.toLowerCase() == 'available',
      bio: profileSummary ?? 'Experienced astrologer',
      isFirstFree: false,
      reviews: [],
    );
  }
}
