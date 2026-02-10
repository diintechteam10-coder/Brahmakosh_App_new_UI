import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';

class RedemptionHistoryModel {
  final String id;
  final String userId;
  final RedeemItemModel? reward; // Nested reward details
  final int karmaPointsSpent;
  final String status;
  final String redeemedAt;

  RedemptionHistoryModel({
    required this.id,
    required this.userId,
    this.reward,
    required this.karmaPointsSpent,
    required this.status,
    required this.redeemedAt,
  });

  factory RedemptionHistoryModel.fromJson(Map<String, dynamic> json) {
    return RedemptionHistoryModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      // The API response shows 'rewardId' containing the reward object
      reward: json['rewardId'] != null && json['rewardId'] is Map
          ? RedeemItemModel.fromJson(json['rewardId'])
          : null,
      karmaPointsSpent: json['karmaPointsSpent'] ?? 0,
      status: json['status'] ?? '',
      redeemedAt: json['redeemedAt'] ?? '',
    );
  }
}
