class PoojaModel {
  String? sId;
  String? pujaName;
  String? category;
  String? subcategory;
  String? purpose;
  String? description;
  String? bestDay;
  int? duration;
  String? language;
  String? thumbnailUrl;
  String? thumbnailKey;
  List<PujaVidhi>? pujaVidhi;
  List<SamagriList>? samagriList;
  List<Mantras>? mantras;
  String? specialInstructions;
  String? muhurat;
  String? audioUrl;
  String? videoUrl;
  String? clientId;
  String? status;
  int? sortOrder;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? audioKey;
  String? videoKey;

  PoojaModel({
    this.sId,
    this.pujaName,
    this.category,
    this.subcategory,
    this.purpose,
    this.description,
    this.bestDay,
    this.duration,
    this.language,
    this.thumbnailUrl,
    this.thumbnailKey,
    this.pujaVidhi,
    this.samagriList,
    this.mantras,
    this.specialInstructions,
    this.muhurat,
    this.audioUrl,
    this.videoUrl,
    this.clientId,
    this.status,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.audioKey,
    this.videoKey,
  });

  PoojaModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    pujaName = json['pujaName'];
    category = json['category'];
    subcategory = json['subcategory'];
    purpose = json['purpose'];
    description = json['description'];
    bestDay = json['bestDay'];
    duration = json['duration'];
    language = json['language'];
    thumbnailUrl = json['thumbnailUrl'];
    thumbnailKey = json['thumbnailKey'];
    if (json['pujaVidhi'] != null) {
      pujaVidhi = <PujaVidhi>[];
      json['pujaVidhi'].forEach((v) {
        pujaVidhi!.add(new PujaVidhi.fromJson(v));
      });
    }
    if (json['samagriList'] != null) {
      samagriList = <SamagriList>[];
      json['samagriList'].forEach((v) {
        samagriList!.add(new SamagriList.fromJson(v));
      });
    }
    if (json['mantras'] != null) {
      mantras = <Mantras>[];
      json['mantras'].forEach((v) {
        mantras!.add(new Mantras.fromJson(v));
      });
    }
    specialInstructions = json['specialInstructions'];
    muhurat = json['muhurat'];
    audioUrl = json['audioUrl'];
    videoUrl = json['videoUrl'];
    clientId = json['clientId'];
    status = json['status'];
    sortOrder = json['sortOrder'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    audioKey = json['audioKey'];
    videoKey = json['videoKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['pujaName'] = this.pujaName;
    data['category'] = this.category;
    data['subcategory'] = this.subcategory;
    data['purpose'] = this.purpose;
    data['description'] = this.description;
    data['bestDay'] = this.bestDay;
    data['duration'] = this.duration;
    data['language'] = this.language;
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['thumbnailKey'] = this.thumbnailKey;
    if (this.pujaVidhi != null) {
      data['pujaVidhi'] = this.pujaVidhi!.map((v) => v.toJson()).toList();
    }
    if (this.samagriList != null) {
      data['samagriList'] = this.samagriList!.map((v) => v.toJson()).toList();
    }
    if (this.mantras != null) {
      data['mantras'] = this.mantras!.map((v) => v.toJson()).toList();
    }
    data['specialInstructions'] = this.specialInstructions;
    data['muhurat'] = this.muhurat;
    data['audioUrl'] = this.audioUrl;
    data['videoUrl'] = this.videoUrl;
    data['clientId'] = this.clientId;
    data['status'] = this.status;
    data['sortOrder'] = this.sortOrder;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['audioKey'] = this.audioKey;
    data['videoKey'] = this.videoKey;
    return data;
  }
}

class PujaVidhi {
  int? stepNumber;
  String? title;
  String? description;

  PujaVidhi({this.stepNumber, this.title, this.description});

  PujaVidhi.fromJson(Map<String, dynamic> json) {
    stepNumber = json['stepNumber'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stepNumber'] = this.stepNumber;
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}

class SamagriList {
  String? itemName;
  String? quantity;
  bool? isOptional;

  SamagriList({this.itemName, this.quantity, this.isOptional});

  SamagriList.fromJson(Map<String, dynamic> json) {
    itemName = json['itemName'];
    quantity = json['quantity'];
    isOptional = json['isOptional'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemName'] = this.itemName;
    data['quantity'] = this.quantity;
    data['isOptional'] = this.isOptional;
    return data;
  }
}

class Mantras {
  String? mantraText;
  String? meaning;

  Mantras({this.mantraText, this.meaning});

  Mantras.fromJson(Map<String, dynamic> json) {
    mantraText = json['mantraText'];
    meaning = json['meaning'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mantraText'] = this.mantraText;
    data['meaning'] = this.meaning;
    return data;
  }
}
