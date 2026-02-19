import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';

class AvatarAgentPage extends StatefulWidget {
  final String? initialAgentId;
  const AvatarAgentPage({super.key, this.initialAgentId});

  @override
  State<AvatarAgentPage> createState() => _AvatarAgentPageState();
}

class _AvatarAgentPageState extends State<AvatarAgentPage>
    with TickerProviderStateMixin {
  final AgentController controller = Get.put(AgentController());

  InAppWebViewController? webViewController;
  bool loading = false;
  bool permissionsGranted = false;
  bool _widgetLoaded = false;
  bool _isTalking = false;
  String? errorMessage;
  bool isDropdownOpen = false;


  @override
  void initState() {
    super.initState();
    checkPermissions();
    // Fetch avatars after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        'AvatarAgentPage: Received initialAgentId: ${widget.initialAgentId}',
      );
      controller.fetchAvatars(this, preferredAgentId: widget.initialAgentId);
    });
  }

  Future<void> checkPermissions() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    setState(() {
      permissionsGranted = camStatus.isGranted && micStatus.isGranted;
    });
  }

  void _onAgentChanged(dynamic agent) {
    if (agent != null && agent != controller.selectedAgent) {
      controller.selectAgent(agent);
      setState(() {
        loading = true;
        errorMessage = null;
        _widgetLoaded = false; // Reset flag for new agent
      });
      if (_isTalking && webViewController != null) {
        _loadWidget(webViewController!);
      }
    }
  }

  void _startTalking() {
    if (controller.selectedAgent != null &&
        controller.selectedAgent!.isActive == true) {
      setState(() {
        _isTalking = true;
        loading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedAgent = controller.selectedAgent;
      final activeAvatars = controller.activeAvatars;
      final hasActive = controller.hasActiveAgents;

      String backgroundAsset = 'assets/images/Chat_background.png';
      // String backgroundAsset = 'assets/images/Krishna_chat.png';
      // if (selectedAgent?.name?.toLowerCase().contains('rashmi') == true) {
      //   backgroundAsset = 'assets/images/Rashmi_chat.png';
      // }

      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundAsset),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Stack(
              children: [
                Positioned.fill(child: Image.network(selectedAgent!.imageUrl!)),
                Column(
                  children: [
                    // Custom Header
                    _buildHeader(activeAvatars, selectedAgent),
                    Expanded(
                      child: permissionsGranted
                          ? _buildMainContent(selectedAgent, hasActive)
                          : _buildPermissionDenied(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(List<dynamic> activeAvatars, dynamic selectedAgent) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          // Agent Selector (Top Center)
          if (selectedAgent != null)
            _buildAgentSelector(activeAvatars, selectedAgent),
        ],
      ),
    );
  }

  Widget _buildAgentSelector(
      List<dynamic> activeAvatars,
      dynamic selectedAgent,
      ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E4D4),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage:
                  NetworkImage(selectedAgent.imageUrl ?? ''),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedAgent.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB06A2B),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFFB06A2B),
                ),
              ],
            ),
          ),
        ),

        /// 👇 DROPDOWN BELOW SELECTOR
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isDropdownOpen
              ? Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9D2B8),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: activeAvatars.map((agent) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isDropdownOpen = false;
                    });
                    _onAgentChanged(agent);
                  },
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          agent.imageUrl ?? '',
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),

                        /// ✅ FIXED TEXT
                        Text(
                          " ${agent.name}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildMainContent(dynamic selectedAgent, bool hasActive) {
    if (_isTalking) {
      return Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri("about:blank")),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              domStorageEnabled: true,
              allowsInlineMediaPlayback: true,
              useHybridComposition: true,
              safeBrowsingEnabled: false,
            ),
            onWebViewCreated: (webViewCtrl) {
              webViewController = webViewCtrl;
            },
            onLoadStop: (controller, url) async {
              if (url.toString() == "about:blank" &&
                  selectedAgent != null &&
                  !_widgetLoaded) {
                setState(() => _widgetLoaded = true);
                _loadWidget(controller);
              }
              setState(() => loading = false);
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            onConsoleMessage: (controller, msg) {
              debugPrint("WebView console: ${msg.message}");
              if (msg.message.contains("Insufficient balance") ||
                  msg.message.contains("Error fetching agent data")) {
                setState(() {
                  errorMessage =
                      "Insufficient Balance: Please check your LemonSlice dashboard credits.";
                  loading = false;
                });
              }
            },
          ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          if (errorMessage != null) _buildErrorMessage(),
        ],
      );
    }

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedAgent != null)
                const Expanded(child: SizedBox.shrink()),
              if (!hasActive)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'there is not active agent right now',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              // Talk Button
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: ElevatedButton(
                  onPressed: hasActive ? _startTalking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withOpacity(0.5),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Talk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wallet, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                errorMessage = null;
                loading = true;
                _widgetLoaded = false;
              });
              webViewController?.reload();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Camera & Microphone permissions required',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: checkPermissions,
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadWidget(InAppWebViewController controller) async {
    final selectedAgentId = this.controller.selectedAgent?.agentId ?? '';
    final htmlContent =
        """
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <script src="https://unpkg.com/@lemonsliceai/lemon-slice-widget"></script>
        <style>
          * {
            border-radius: 0 !important;
          }
          html, body {
            margin: 0;
            padding: 0;
            background-color: white;
            overflow: hidden;
            width: 100vw;
            height: 100vh;
          }
          lemon-slice-widget {
            display: block;
            width: 100vw;
            height: 100vh;
            border-radius: 0 !important;
          }
        </style>
      </head>
      <body>
        <lemon-slice-widget
          id="main-widget"
          agent-id="$selectedAgentId"
          initial-state="active"
          inline="true"
          custom-active-border-radius="0"
          show-minimize-button="false">
        </lemon-slice-widget>
        <script>
          function updateWidgetSize() {
            const widget = document.getElementById('main-widget');
            if (widget) {
              widget.setAttribute('custom-active-width', window.innerWidth);
              widget.setAttribute('custom-active-height', window.innerHeight);
              widget.setAttribute('custom-active-border-radius', '0');
            }
          }
          async function initActivations() {
            const widget = document.getElementById('main-widget');
            if (widget) {
              try {
                // Wait for the custom element to be ready and methods to be available
                // We use a small delay or check for the methods
                const checkInterval = setInterval(async () => {
                  if (typeof widget.micOn === 'function' && typeof widget.unmute === 'function') {
                    clearInterval(checkInterval);
                    console.log('Activating mic and audio...');
                    await widget.unmute();
                    console.log('Mic and audio activated.');
                  }
                }, 500);
              } catch (e) {
                console.error('Error activating widget features:', e);
              }
            }
          }
          initActivations();
          updateWidgetSize();
          window.addEventListener('resize', updateWidgetSize);
          document.addEventListener('touchstart', function() {
            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            if (audioCtx.state === 'suspended') {
              audioCtx.resume();
            }
          }, { once: true });
          function flatAll() {
            const all = document.querySelectorAll('*');
            all.forEach(el => {
              el.style.setProperty('border-radius', '0px', 'important');
              if (el.shadowRoot) {
                const shadowAll = el.shadowRoot.querySelectorAll('*');
                shadowAll.forEach(sel => {
                  sel.style.setProperty('border-radius', '0px', 'important');
                });
              }
            });
          }
          setInterval(flatAll, 500);
          flatAll();
        </script>
      </body>
      </html>
    """;

    await controller.loadData(
      data: htmlContent,
      mimeType: "text/html",
      encoding: "utf8",
      baseUrl: WebUri("https://lemonslice.com"),
    );
  }
}
