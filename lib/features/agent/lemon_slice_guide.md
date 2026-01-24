# LemonSlice Widget Flow Integration Guide

This guide provides a comprehensive walkthrough for integrating the LemonSlice **Widget Flow** into a Flutter mobile application, featuring multiple avatar support and backend chat history persistence.

---

## 1. Overview

### What is Widget Flow?
Widget Flow uses LemonSlice's embedded widget (`lemon-slice-widget`) that:
- ✅ Handles video/voice internally (no room creation needed)
- ✅ Provides built-in UI for avatar interaction
- ✅ Supports multiple agents/avatars
- ✅ Works seamlessly in WebView
- ✅ No backend room management required

---

## 2. Architecture

### System Architecture
The mobile app hosts a WebView that renders a simple HTML page containing the `lemon-slice-widget`. All real-time media (WebRTC) is encapsulated within this widget.

---

## 3. Flutter Project Setup

Ensure you have the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_inappwebview: ^6.0.0
  permission_handler: ^11.0.0
  http: ^1.1.0
  provider: ^6.1.1
```

### Permissions
**Android (`AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

**iOS (`Info.plist`):**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access for the avatar agent.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for the avatar agent.</string>
```

---

## 4. Widget Integration

The core integration happens via an `InAppWebView`.

```dart
// Example HTML structure for the Widget Flow
final String htmlContent = """
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://unpkg.com/@lemonsliceai/lemon-slice-widget"></script>
</head>
<body style="margin: 0; background: black;">
  <lemon-slice-widget 
    agent-id="$agentId" 
    initial-state="active">
  </lemon-slice-widget>
</body>
</html>
""";
```

---

## 5. Multiple Avatars Support

To support multiple avatars, maintain a list of agent IDs and reload the WebView when the selection changes.

```dart
class AgentInfo {
  final String id;
  final String name;
  AgentInfo(this.id, this.name);
}

final List<AgentInfo> agents = [
  AgentInfo("agent_03d1be48f6b952dc", "Rashmi"),
  AgentInfo("agent_astrologer_id", "Astrologer"),
];
```

---

## 6. Backend Integration

The backend is primarily used for persisting chat history. While the widget handles the "live" interaction, we can sink message events to our backend.

### Sample Node.js Endpoint
```javascript
app.post('/api/chat/persist', async (req, res) => {
  const { userId, agentId, message, sender } = req.body;
  await ChatMessage.create({ userId, agentId, message, sender, timestamp: new Date() });
  res.status(200).send({ success: true });
});
```

---

## 7. Chat History Management

Load history from your backend and display it in a separate UI component or a "History" tab.

```dart
Future<void> fetchHistory(String agentId) async {
  final response = await http.get(Uri.parse("$baseUrl/history/$agentId"));
  // Update state with history
}
```

---

## 8. Event Handling

Use `JavaScriptHandler` in `InAppWebView` to bridge widget events to Flutter.

```dart
onWebViewCreated: (controller) {
  controller.addJavaScriptHandler(handlerName: 'onMessage', callback: (args) {
    // Handle message from widget
    persistMessageToBackend(args[0]);
  });
}
```

---

## 9. UI Implementation

Use a `Stack` to overlay agent selection or custom controls over the WebView.

---

## 10. State Management

Use `Provider` or `Riverpod` to manage the currently active agent and the loading state of the WebView.

---

## 11. Deployment

- Ensure your domain is allow-listed in the LemonSlice dashboard.
- Always use `https` for WebView to enable WebRTC permissions.

---

## 12. Troubleshooting

- **No Video/Audio**: Check if permissions were granted and if `mediaPlaybackRequiresUserGesture` is set to `false`.
- **Widget not loading**: Verify the `agent-id` and ensure `widget.js` is correctly included.
