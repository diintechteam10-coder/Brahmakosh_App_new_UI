import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/avtar_list.dart';

class AgentController extends GetxController {
  final _avatars = <Data>[].obs;
  final _isLoading = false.obs;
  final _selectedAgent = Rxn<Data>();

  List<Data> get avatars => _avatars;
  bool get isLoading => _isLoading.value;
  Data? get selectedAgent => _selectedAgent.value;

  Future<void> fetchAvatars(TickerProvider? tickerProvider, {String? preferredAgentId}) async {
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
          debugPrint('AgentController: Looking for agentId: $preferredAgentId');
          final found = _avatars.firstWhereOrNull((a) => a.agentId == preferredAgentId);
          if (found != null) {
            debugPrint('AgentController: Found agent: ${found.name}, agentId: ${found.agentId}');
            _selectedAgent.value = found;
          } else {
            debugPrint('AgentController: Agent not found, selecting first: ${_avatars.first.name}');
            _selectedAgent.value = _avatars.first;
          }
        } else {
          debugPrint('AgentController: No preferredAgentId, selecting first: ${_avatars.first.name}');
          _selectedAgent.value = _avatars.first;
        }

        // Auto-connect to selected agent immediately
        _autoConnectToFirstAgent();
      }
    } catch (e) {
      debugPrint('Error in fetchAvatars: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Callback to auto-connect when first agent is loaded
  VoidCallback? onFirstAgentLoaded;

  void _autoConnectToFirstAgent() {
    if (onFirstAgentLoaded != null) {
      onFirstAgentLoaded!();
    }
  }

  void selectAgent(Data agent) {
    _selectedAgent.value = agent;
  }

  void refreshAvatars(TickerProvider? tickerProvider) {
    fetchAvatars(tickerProvider);
  }
}
