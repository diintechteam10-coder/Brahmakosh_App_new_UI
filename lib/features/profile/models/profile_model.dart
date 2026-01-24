class ProfileModel {
  final String id;
  final String email;
  final String authMethod;
  final int registrationStep;
  final bool emailVerified;
  final bool mobileVerified;
  final bool isActive;
  final bool loginApproved;
  final String createdAt;
  final String updatedAt;
  final String? mobile;
  final String? profileImage;
  final String? profileImageUrl;
  final String role;

  /// 👇 ADD THIS
  final UserProfile? profile;

  ProfileModel({
    required this.id,
    required this.email,
    required this.authMethod,
    required this.registrationStep,
    required this.emailVerified,
    required this.mobileVerified,
    required this.isActive,
    required this.loginApproved,
    required this.createdAt,
    required this.updatedAt,
    this.mobile,
    this.profileImage,
    this.profileImageUrl,
    required this.role,
    this.profile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      authMethod: json['authMethod'] ?? '',
      registrationStep: json['registrationStep'] ?? 0,
      emailVerified: json['emailVerified'] ?? false,
      mobileVerified: json['mobileVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      loginApproved: json['loginApproved'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      mobile: json['mobile'],
      profileImage: json['profileImage'],
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] ?? 'user',

      /// 👇 MAP PROFILE SAFELY
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }
}
class UserProfile {
  final String? name;
  final String? dob;
  final String? gowthra;
  final String? placeOfBirth;
  final String? timeOfBirth;

  UserProfile({
    this.name,
    this.dob,
    this.gowthra,
    this.placeOfBirth,
    this.timeOfBirth,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      dob: json['dob'],
      gowthra: json['gowthra'],
      placeOfBirth: json['placeOfBirth'],
      timeOfBirth: json['timeOfBirth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dob': dob,
      'gowthra': gowthra,
      'placeOfBirth': placeOfBirth,
      'timeOfBirth': timeOfBirth,
    };
  }
}

