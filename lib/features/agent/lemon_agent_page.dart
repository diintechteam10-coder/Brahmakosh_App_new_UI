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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    checkPermissions();
    // Set up callback for auto-connecting to first agent
    controller.onFirstAgentLoaded = _autoConnectToFirstAgent;
      // Fetch avatars after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('AvatarAgentPage: Received initialAgentId: ${widget.initialAgentId}');
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
      if (webViewController != null) {
        _loadWidget(webViewController!);
      }
    }
  }

  void _autoConnectToFirstAgent() {
    // Auto-connect to the first agent when avatars are loaded
    if (webViewController != null && controller.selectedAgent != null && !_widgetLoaded) {
      setState(() {
        loading = true;
        errorMessage = null;
        _widgetLoaded = true;
      });
      _loadWidget(webViewController!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Brahmakosh',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Obx(
              () => Text(
                controller.selectedAgent?.description ?? 'AI Spiritual Guide',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
        actions: widget.initialAgentId != null 
          ? null 
          : [
            Obx(() {
              if (controller.isLoading) {
                return const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              return DropdownButton<dynamic>(
                value: controller.selectedAgent,
                dropdownColor: Colors.white,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                items: controller.avatars.map((dynamic agent) {
                  return DropdownMenuItem<dynamic>(
                    value: agent,
                    child: Text(
                      agent.name ?? 'Unknown Agent',
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: _onAgentChanged,
              );
            }),
            const SizedBox(width: 8),
          ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: permissionsGranted
            ? Stack(
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
                      // Auto-connect if agent is already selected and widget not loaded yet
                      if (controller.selectedAgent != null && !_widgetLoaded) {
                        _autoConnectToFirstAgent();
                      }
                    },
                    onLoadStop: (controller, url) async {
                      if (url.toString() == "about:blank" && this.controller.selectedAgent != null && !_widgetLoaded) {
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
                  if (errorMessage != null)
                    Container(
                      color: Colors.black.withOpacity(0.8),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wallet,
                            size: 64,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                errorMessage = null;
                                loading = true;
                                _widgetLoaded = false; // Reset flag to allow reload
                              });
                              webViewController?.reload();
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Camera & Microphone permissions required',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: checkPermissions,
                      child: const Text('Grant Permissions'),
                    ),
                  ],
                ),
              ),
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
          /* Attempt to target shadow parts if they exist */
          lemon-slice-widget::part(video),
          lemon-slice-widget::part(container),
          lemon-slice-widget::part(wrapper) {
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

          // Initial size
          updateWidgetSize();

          // Update on resize
          window.addEventListener('resize', updateWidgetSize);

          // Force audio context start if needed
          document.addEventListener('touchstart', function() {
            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            if (audioCtx.state === 'suspended') {
              audioCtx.resume();
            }
          }, { once: true });

          // Aggressive script to remove border-radius from all elements, including shadow DOM
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

          // Run multiple times to ensure it catches late-loading elements
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
