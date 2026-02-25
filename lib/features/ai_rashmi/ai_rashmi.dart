import 'package:brahmakosh/features/agent/lemon_agent_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../common/models/avtar_list.dart';
import 'ai_rashmi_service.dart';
import 'ai_rashmi_view_model.dart';
import 'ai_rashmi_voice.dart';
import '../dashboard/viewmodels/dashboard_viewmodel.dart';
import 'ai_rashmi_chat.dart';
import 'deity_selection_service.dart';
import 'aradhya_selection_view.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import '../../../../core/common_imports.dart';

class RashmiAi extends StatelessWidget {
  const RashmiAi({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller inject with GetX
    Get.put(AiRashmiController(service: AiRashmiService()));
    return const _RashmiAiView();
  }
}

class _RashmiAiView extends StatefulWidget {
  const _RashmiAiView();

  @override
  State<_RashmiAiView> createState() => _RashmiAiViewState();
}

class _RashmiAiViewState extends State<_RashmiAiView> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DeitySelectionService _deityService = DeitySelectionService();
  Data? _currentDeity;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AgentController>()) {
      Get.put(AgentController());
    }
    _ensureDeitySelected();
  }

  Future<void> _ensureDeitySelected() async {
    final agentController = Get.find<AgentController>();

    // Fetch avatars if empty
    if (agentController.avatars.isEmpty) {
      await agentController.fetchAvatars(null);
    }

    // If still no deity selected, pick the first one from API
    if (_deityService.selectedDeity == null &&
        agentController.avatars.isNotEmpty) {
      _deityService.setSelectedDeity(agentController.avatars.first);
    }

    if (mounted) {
      setState(() {
        _currentDeity = _deityService.selectedDeity;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if deity has changed since last time
    final selectedDeity = _deityService.selectedDeity;
    if (selectedDeity != _currentDeity) {
      if (mounted) {
        setState(() {
          _currentDeity = selectedDeity;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GetBuilder<AiRashmiController>(
        builder: (vm) {
          final imageUrl = _currentDeity?.imageUrl;

          return Scaffold(
            key: _scaffoldKey,
            drawer: _buildDrawer(vm),
            body: Stack(
              children: [
                // Image Background instead of Video
                Positioned.fill(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl, // Uses network image from API
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.black),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        )
                      : Container(color: Colors.black),
                ),

                // Dark overlay for readability
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.25)),
                ),

                // Custom Top Bar (Menu, Change Deity & Close Icons)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          // Change Deity Button
                          GestureDetector(
                            onTap: () async {
                              // Navigate to Aradhya Selection
                              await Get.to(
                                () => AradhyaSelectionView(
                                  onDeitySelected: () async {
                                    // Update state with new deity
                                    if (mounted) {
                                      setState(() {
                                        _currentDeity =
                                            _deityService.selectedDeity;
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryGold.withOpacity(0.9),
                                    AppTheme.darkGold.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGold.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.swap_horiz,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Select Aradhya',
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              // Navigate back to Home (index 0) in dashboard
                              final dashboardViewModel =
                                  Provider.of<DashboardViewModel>(
                                    context,
                                    listen: false,
                                  );
                              dashboardViewModel.changeTab(0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main UI Content - Bottom Positioned Buttons with Padding
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 50,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Center "Click to Talk" Button
                      GestureDetector(
                        onTap: () {
                          // Pass the selected agent's ID to the talk page
                          final agentId = _deityService.selectedDeity?.agentId;
                          debugPrint(
                            'AiRashmi: Navigating to AvatarAgentPage with agentId: $agentId, deity: ${_deityService.selectedDeity?.name}',
                          );
                          Get.to(
                            () => AvatarAgentPage(initialAgentId: agentId),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryGold.withOpacity(0.9),
                                AppTheme.darkGold.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGold.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.record_voice_over,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Click to Talk',
                                style: GoogleFonts.cinzel(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Bottom Row with Voice and Chat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Voice Button
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const RashmiVoicePage());
                            },
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blueAccent.withOpacity(0.8),
                                    Colors.blue.withOpacity(0.6),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Voice',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Chat Button
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const RashmiChat());
                            },
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.purpleAccent.withOpacity(0.8),
                                    Colors.purple.withOpacity(0.6),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Chat',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Drawer _buildDrawer(AiRashmiController vm) {
  return Drawer(
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New chat'),
            onTap: () async {
              Get.back();
              await vm.newChat();
            },
          ),
          const Divider(),
          if (vm.isLoadingHistory)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (vm.history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No chats yet'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: vm.history.length,
                itemBuilder: (context, index) {
                  final chat = vm.history[index];
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(chat.title),
                    subtitle: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      Get.back();
                      await vm.selectChat(chat);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
}

// Animated typing indicator widget
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Start animations with staggered delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: 0.3 + (_animations[index].value * 0.7),
              child: Text(
                '.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
