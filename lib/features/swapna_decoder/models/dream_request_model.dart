class DreamRequestModel {
  final String id;
  final String dreamSymbol;
  final String additionalDetails;
  final String? status;
  final bool? notificationSent;
  final DreamCompletedId? completedDreamId;
  final String? createdAt;
  final String? updatedAt;
  final DreamUserModel? userId;
  final String? userEmail;
  final String? userName;
  final String? clientId;

  DreamRequestModel({
    required this.id,
    required this.dreamSymbol,
    required this.additionalDetails,
    this.status,
    this.notificationSent,
    this.completedDreamId,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.userEmail,
    this.userName,
    this.clientId,
  });

  factory DreamRequestModel.fromJson(Map<String, dynamic> json) {
    return DreamRequestModel(
      id: json['_id'] ?? '',
      dreamSymbol: json['dreamSymbol'] ?? '',
      additionalDetails: json['additionalDetails'] ?? '',
      status: json['status'],
      notificationSent: json['notificationSent'],
      completedDreamId: json['completedDreamId'] != null
          ? DreamCompletedId.fromJson(json['completedDreamId'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userId: json['userId'] != null
          ? (json['userId'] is Map<String, dynamic>
                ? DreamUserModel.fromJson(json['userId'])
                : (json['userId'] is String
                      ? DreamUserModel(id: json['userId'], email: '')
                      : null))
          : null,
      userEmail: json['userEmail'],
      userName: json['userName'],
      clientId: json['clientId'],
    );
  }
}

class DreamCompletedId {
  final String id;
  final String symbolName;
  final String? symbolNameHindi;

  DreamCompletedId({
    required this.id,
    required this.symbolName,
    this.symbolNameHindi,
  });

  factory DreamCompletedId.fromJson(Map<String, dynamic> json) {
    return DreamCompletedId(
      id: json['_id'] ?? '',
      symbolName: json['symbolName'] ?? '',
      symbolNameHindi: json['symbolNameHindi'],
    );
  }
}

class DreamUserModel {
  final String id;
  final String email;
  final String? mobile;

  DreamUserModel({required this.id, required this.email, this.mobile});

  factory DreamUserModel.fromJson(Map<String, dynamic> json) {
    // Sometimes userId can be just a String ID, or an Object.
    // The response example shows it as an object.
    // If usage varies, we might need to handle String vs Map.
    return DreamUserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'],
    );
  }
}
