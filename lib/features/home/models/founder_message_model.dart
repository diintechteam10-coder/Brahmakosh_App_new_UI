class FounderMessageModel {
  bool success;
  List<FounderMessage> data;
  int count;

  FounderMessageModel({
    required this.success,
    required this.data,
    required this.count,
  });

  factory FounderMessageModel.fromJson(Map<String, dynamic> json) => FounderMessageModel(
        success: json["success"] ?? false,
        data: json["data"] != null
            ? List<FounderMessage>.from(json["data"].map((x) => FounderMessage.fromJson(x)))
            : [],
        count: json["count"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "count": count,
      };
}

class FounderMessage {
  String id;
  String founderName;
  String position;
  String content;
  String? founderImage;
  String? founderImageKey;
  String status;
  int views;
  String clientId;
  bool isActive;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  FounderMessage({
    required this.id,
    required this.founderName,
    required this.position,
    required this.content,
    this.founderImage,
    this.founderImageKey,
    required this.status,
    required this.views,
    required this.clientId,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory FounderMessage.fromJson(Map<String, dynamic> json) => FounderMessage(
        id: json["_id"] ?? "",
        founderName: json["founderName"] ?? "",
        position: json["position"] ?? "",
        content: json["content"] ?? "",
        founderImage: json["founderImage"],
        founderImageKey: json["founderImageKey"],
        status: json["status"] ?? "",
        views: json["views"] ?? 0,
        clientId: json["clientId"] ?? "",
        isActive: json["isActive"] ?? true,
        isDeleted: json["isDeleted"] ?? false,
        createdAt: json["createdAt"] != null 
            ? DateTime.parse(json["createdAt"]) 
            : DateTime.now(),
        updatedAt: json["updatedAt"] != null 
            ? DateTime.parse(json["updatedAt"]) 
            : DateTime.now(),
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "founderName": founderName,
        "position": position,
        "content": content,
        "founderImage": founderImage,
        "founderImageKey": founderImageKey,
        "status": status,
        "views": views,
        "clientId": clientId,
        "isActive": isActive,
        "isDeleted": isDeleted,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
