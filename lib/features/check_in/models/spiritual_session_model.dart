class SpiritualSessionRequest {
  String? type;
  String? title;
  num? targetDuration;
  num? actualDuration;
  String? chantingName;
  int? chantCount;
  int? karmaPoints;
  String? emotion;
  String? status;
  int? completionPercentage;
  String? videoUrl;
  String? audioUrl;
  String? configurationId;

  SpiritualSessionRequest({
    this.type,
    this.title,
    this.targetDuration,
    this.actualDuration,
    this.chantingName,
    this.chantCount,
    this.karmaPoints,
    this.emotion,
    this.status,
    this.completionPercentage,
    this.videoUrl,
    this.audioUrl,
    this.configurationId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['title'] = title;
    data['targetDuration'] = targetDuration;
    data['actualDuration'] = actualDuration;
    data['chantingName'] = chantingName;
    data['chantCount'] = chantCount;
    data['karmaPoints'] = karmaPoints;
    data['emotion'] = emotion;
    data['status'] = status;
    data['completionPercentage'] = completionPercentage;
    data['videoUrl'] = videoUrl;
    data['audioUrl'] = audioUrl;
    // configurationId might be needed if backend supports it for linking, keeping it optional or as per request structure
    if (configurationId != null) data['configurationId'] = configurationId;
    return data;
  }
}
