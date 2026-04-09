class KundaliHistoryResponse {
  bool? success;
  String? message;
  KundaliHistoryData? data;

  KundaliHistoryResponse({this.success, this.message, this.data});

  KundaliHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = KundaliHistoryData.fromJson(json['data']);
    } else if (success == true) {
      // If success is true but 'data' is missing, the root might contain the data
      data = KundaliHistoryData.fromJson(json);
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

class KundaliHistoryData {
  List<KundaliHistoryItem>? history;
  int? total;
  int? page;
  int? limit;
  bool? hasMore;

  KundaliHistoryData({
    this.history,
    this.total,
    this.page,
    this.limit,
    this.hasMore,
  });

  KundaliHistoryData.fromJson(Map<String, dynamic> json) {
    // API uses 'items' but model used 'history'
    var list = json['items'] ?? json['history'];
    if (list != null) {
      history = <KundaliHistoryItem>[];
      list.forEach((v) {
        history!.add(KundaliHistoryItem.fromJson(v));
      });
    }
    total = json['total'] ?? 0;
    page = json['page'] ?? 1;
    limit = json['limit'] ?? 20;
    
    // Calculate hasMore if not provided by API
    if (json['hasMore'] != null) {
      hasMore = json['hasMore'];
    } else {
      hasMore = (page! * limit!) < total!;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['hasMore'] = hasMore;
    return data;
  }
}

class KundaliHistoryItem {
  String? sId;
  String? userId;
  String? reportType; // mini, basic, pro
  String? s3Url;
  String? language;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  KundaliHistoryItem({
    this.sId,
    this.userId,
    this.reportType,
    this.s3Url,
    this.language,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  KundaliHistoryItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    reportType = json['reportType'] ?? json['report_type'];
    s3Url = json['s3Url'] ?? json['s3_url'] ?? json['url'];
    language = json['language'];
    status = json['status'];
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
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }

  /// Returns a display-friendly label for the report type
  String get reportTypeLabel {
    switch ((reportType ?? '').toLowerCase()) {
      case 'mini':
        return 'Mini';
      case 'basic':
        return 'Basic';
      case 'pro':
        return 'Pro';
      default:
        return reportType ?? 'Unknown';
    }
  }
}

class KundaliDownloadResponse {
  bool? success;
  String? message;
  KundaliDownloadData? data;

  KundaliDownloadResponse({this.success, this.message, this.data});

  KundaliDownloadResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = KundaliDownloadData.fromJson(json['data']);
    } else if (success == true) {
      // Fallback to root
      data = KundaliDownloadData.fromJson(json);
    }
  }
}

class KundaliDownloadData {
  String? presignedUrl;
  int? expiresIn;

  KundaliDownloadData({this.presignedUrl, this.expiresIn});

  KundaliDownloadData.fromJson(Map<String, dynamic> json) {
    presignedUrl = json['presignedUrl'] ?? json['url'] ?? json['downloadUrl'];
    expiresIn = json['expiresIn'] ?? json['expires_in'] ?? 600;
  }
}
