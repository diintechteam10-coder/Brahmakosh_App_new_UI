import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/avtar_list.dart';

class AgentController extends GetxController {
  final _avatars = <Data>[].obs;
  final _isLoading = false.obs;
  final _selectedAgent = Rxn<Data>();

  List<Data> get avatars => _avatars;
  List<Data> get activeAvatars =>
      _avatars.where((a) => a.isActive == true).toList();
  bool get hasActiveAgents => activeAvatars.isNotEmpty;
  bool get isLoading => _isLoading.value;
  Data? get selectedAgent => _selectedAgent.value;

  Future<void> fetchAvatars(
    TickerProvider? tickerProvider, {
    String? preferredAgentId,
  }) async {
    _isLoading.value = true;
    try {
      // Only fetch if avatars are empty to avoid unnecessary API calls
      if (_avatars.isEmpty) {
        final response = await getLiveAvatars(tickerProvider);
        if (response != null && response.success == true) {
          _avatars.assignAll(response.data ?? []);
        }
      }

      // Handle selection logic - always do this even if avatars were already loaded
      if (_avatars.isNotEmpty) {
        if (preferredAgentId != null) {
          final found = _avatars.firstWhereOrNull(
            (a) => a.agentId == preferredAgentId,
          );
          if (found != null) {
            _selectedAgent.value = found;
          } else {
            _selectedAgent.value = activeAvatars.isNotEmpty
                ? activeAvatars.first
                : _avatars.first;
          }
        } else {
          _selectedAgent.value = activeAvatars.isNotEmpty
              ? activeAvatars.first
              : _avatars.first;
        }

        // Auto-connect removed from here, will be triggered by manual Talk button if needed
        // but we keep the callback for compatibility if other pages use it
        // _autoConnectToFirstAgent();
      }
    } catch (e) {
      debugPrint('Error in fetchAvatars: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void selectAgent(Data agent) {
    _selectedAgent.value = agent;
  }

  void refreshAvatars(TickerProvider? tickerProvider) {
    fetchAvatars(tickerProvider);
  }
}
