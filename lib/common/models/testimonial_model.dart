class TestimonialModel {
  bool success;
  List<Testimonial> data;
  int count;

  TestimonialModel({
    required this.success,
    required this.data,
    required this.count,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) => TestimonialModel(
        success: json["success"],
        data: List<Testimonial>.from(json["data"].map((x) => Testimonial.fromJson(x))),
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "count": count,
      };
}

class Testimonial {
  String id;
  String name;
  int rating;
  String message;
  String image;
  String clientId;
  bool isActive;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Testimonial({
    required this.id,
    required this.name,
    required this.rating,
    required this.message,
    required this.image,
    required this.clientId,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) => Testimonial(
        id: json["_id"],
        name: json["name"],
        rating: json["rating"],
        message: json["message"],
        image: json["image"],
        clientId: json["clientId"],
        isActive: json["isActive"],
        isDeleted: json["isDeleted"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "rating": rating,
        "message": message,
        "image": image,
        "clientId": clientId,
        "isActive": isActive,
        "isDeleted": isDeleted,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
      };
}
