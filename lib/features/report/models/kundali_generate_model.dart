class KundaliGenerateResponse {
  bool? success;
  String? message;
  KundaliGenerateData? data;

  KundaliGenerateResponse({this.success, this.message, this.data});

  KundaliGenerateResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = KundaliGenerateData.fromJson(json['data']);
    } else if (success == true) {
      // If success is true but 'data' is missing, the root might contain the data
      data = KundaliGenerateData.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class KundaliGenerateData {
  String? s3Url;
  KundaliHistoryRecord? historyRecord;
  dynamic providerResponse;

  KundaliGenerateData({this.s3Url, this.historyRecord, this.providerResponse});

  KundaliGenerateData.fromJson(Map<String, dynamic> json) {
    // Check root level keys and nested keys
    s3Url = json['s3Url'] ??
        json['s3_url'] ??
        json['url'] ??
        (json['s3'] != null ? json['s3']['url'] : null);

    historyRecord = json['historyRecord'] != null
        ? KundaliHistoryRecord.fromJson(json['historyRecord'])
        : (json['history'] != null
            ? KundaliHistoryRecord.fromJson(json['history'])
            : null);

    providerResponse = json['providerResponse'] ?? json['provider_response'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['s3Url'] = s3Url;
    if (historyRecord != null) {
      data['historyRecord'] = historyRecord!.toJson();
    }
    data['providerResponse'] = providerResponse;
    return data;
  }
}

class KundaliHistoryRecord {
  String? sId;
  String? userId;
  String? reportType;
  String? s3Url;
  String? language;
  String? createdAt;
  String? updatedAt;
  int? iV;

  KundaliHistoryRecord({
    this.sId,
    this.userId,
    this.reportType,
    this.s3Url,
    this.language,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  KundaliHistoryRecord.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    reportType = json['reportType'] ?? json['report_type'];
    s3Url = json['s3Url'] ?? json['s3_url'] ?? json['url'];
    language = json['language'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['reportType'] = reportType;
    data['s3Url'] = s3Url;
    data['language'] = language;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
