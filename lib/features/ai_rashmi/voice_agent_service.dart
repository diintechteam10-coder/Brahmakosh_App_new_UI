import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';

enum VoiceAgentState {
  IDLE,
  CONNECTING,
  LISTENING,
  PROCESSING,
  SPEAKING,
  ERROR,
}

class VoiceAgentService extends ChangeNotifier {
  WebSocketChannel? _channel;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  VoiceAgentState _state = VoiceAgentState.IDLE;
  VoiceAgentState get state => _state;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  String _interimText = "";
  String get interimText => _interimText;

  String _aiText = "";
  String get aiText => _aiText;

  final List<int> _audioBuffer = [];
  StreamSubscription? _recordSub;

  // History Sync Callbacks
  Function(String chatId)? onChatCreated;
  Function(String text)? onUserMessage;
  Function(String text)? onAiResponse;

  String? _currentUserId;
  String? _currentChatId;

  // Enhance VAD: Add 'hasVoiceActivity' flag
  bool _hasVoiceActivity = false;
  DateTime? _lastVoiceActivity;

  // Tuning silence threshold and timeout as requested
  final double silenceThreshold = 0.01;
  final Duration silenceTimeout = const Duration(milliseconds: 2000);

  // Timeouts for stuck states
  Timer? _processingTimeoutTimer;
  Timer? _emptyTurnTimer;

  bool _isIntentionalClose = false;

  void _setState(VoiceAgentState newState) {
    if (_state != newState) {
      _state = newState;
      debugPrint('[VoiceAgent] State changed: ${newState.name}');
      notifyListeners();
    }
  }

  Future<void> startSession(String userId, {String? chatId}) async {
    if (_state != VoiceAgentState.IDLE && _state != VoiceAgentState.ERROR) {
      debugPrint('[VoiceAgent] Already active');
      return;
    }

    _isIntentionalClose = false;
    _currentUserId = userId;
    _currentChatId = chatId;

    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      _errorMessage = "Microphone permission denied";
      _setState(VoiceAgentState.ERROR);
      return;
    }

    _setState(VoiceAgentState.CONNECTING);
    _errorMessage = "";
    _interimText = "";
    _aiText = "";
    _audioBuffer.clear();

    await _connectWebSocket();
  }

  Future<void> _connectWebSocket({bool isReconnect = false}) async {
    try {
      debugPrint(
        '[VoiceAgent] Connecting to wss://prod.brahmakosh.com/api/voice/agent ...',
      );
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://prod.brahmakosh.com/api/voice/agent'),
      );

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('[VoiceAgent] WebSocket Error: $error');
          _errorMessage = 'WebSocket Error: $error';
          _setState(VoiceAgentState.ERROR);
        },
        onDone: () {
          debugPrint(
            '[VoiceAgent] WebSocket stream onDone triggered. Intentional: $_isIntentionalClose',
          );

          // Add WebSocket auto-reconnect on onDone (unless intentional close).
          if (!_isIntentionalClose) {
            debugPrint('[VoiceAgent] Unexpected close. Reconnecting in 1s...');
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (!_isIntentionalClose) {
                _connectWebSocket(isReconnect: true);
              }
            });
          }
        },
      );

      // Send start message ONLY once per session or on reconnect
      if (_currentUserId != null) {
        final payload = {
          "type": "start",
          "userId": _currentUserId,
          "chatId": _currentChatId ?? "new",
        };
        _sendWSMessage(payload);
      }
    } catch (e) {
      debugPrint('[VoiceAgent] Connection Exception: $e');
      _errorMessage = 'Connection Exception: $e';
      _setState(VoiceAgentState.ERROR);
      _cleanup(closeWebSocket: true);
    }
  }

  void _sendWSMessage(Map<String, dynamic> payload) {
    if (_channel != null && _channel?.closeCode == null) {
      final jsonPayload = jsonEncode(payload);
      if (payload["type"] != "audio") {
        debugPrint('[VoiceAgent] Sending: ${payload["type"]}');
      }
      _channel!.sink.add(jsonPayload);
    } else {
      debugPrint(
        '[VoiceAgent] Cannot send, channel is null or closed. Payload type: ${payload["type"]}',
      );
    }
  }

  Future<void> _startMicrophone() async {
    try {
      if (await _recorder.isRecording()) {
        debugPrint('[VoiceAgent] Microphone is already recording.');
        return;
      }

      if (await _recorder.hasPermission()) {
        debugPrint('[VoiceAgent] Starting microphone recording...');

        _hasVoiceActivity = false;
        _lastVoiceActivity = DateTime.now();

        // Start empty turn timeout (10s reset if no voice)
        _startEmptyTurnTimer();

        final stream = await _recorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        // Align state transition: LISTENING on started/audio_complete
        _setState(VoiceAgentState.LISTENING);
        _recordSub = stream.listen((data) {
          _sendAudioChunk(data);
        });
      }
    } catch (e) {
      debugPrint('[VoiceAgent] Mic Error: $e');
      _errorMessage = 'Mic Error: $e';
      _setState(VoiceAgentState.ERROR);
    }
  }

  void _startEmptyTurnTimer() {
    _emptyTurnTimer?.cancel();
    _emptyTurnTimer = Timer(const Duration(seconds: 10), () {
      if (_state == VoiceAgentState.LISTENING && !_hasVoiceActivity) {
        debugPrint(
          '[VoiceAgent] Empty turn timeout reached. Resetting listening state...',
        );
        // Just reset the empty turn timer to keep listening continuously.
        _startEmptyTurnTimer();
      }
    });
  }

  double _calculateRMS(Uint8List bytes) {
    if (bytes.isEmpty) return 0.0;

    double sumOfSquares = 0.0;
    final int samples = bytes.length ~/ 2;

    for (int i = 0; i < bytes.length - 1; i += 2) {
      int sample = bytes[i] | (bytes[i + 1] << 8);
      if (sample >= 32768) {
        sample -= 65536;
      }
      double normalized = sample / 32768.0;
      sumOfSquares += normalized * normalized;
    }

    return sqrt(sumOfSquares / samples);
  }

  Future<void> _stopMicrophone() async {
    debugPrint('[VoiceAgent] Pausing Microphone...');
    await _recordSub?.cancel();
    _recordSub = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    _emptyTurnTimer?.cancel();
  }

  void _sendAudioChunk(Uint8List bytes) async {
    if (_state != VoiceAgentState.LISTENING) return;

    double rms = _calculateRMS(bytes);
    if (rms > silenceThreshold) {
      if (!_hasVoiceActivity) {
        debugPrint('[VoiceAgent] Voice activity started.');
      }
      _hasVoiceActivity = true;
      _lastVoiceActivity = DateTime.now();
    } else if (_hasVoiceActivity && _lastVoiceActivity != null) {
      // Only check silence timeout if voice was actually detected
      final silenceDuration = DateTime.now().difference(_lastVoiceActivity!);
      if (silenceDuration > silenceTimeout) {
        debugPrint(
          '[VoiceAgent] Local silence detected after voice activity. Waiting for server to send user_message...',
        );

        await _stopMicrophone(); // ONLY stops mic, does not send 'stop'

        // Setup a 10s timeout after local silence if no server response
        _processingTimeoutTimer?.cancel();
        _processingTimeoutTimer = Timer(const Duration(seconds: 10), () {
          if (_state == VoiceAgentState.LISTENING ||
              _state == VoiceAgentState.PROCESSING) {
            debugPrint(
              '[VoiceAgent] Stuck state timeout reached after local silence. No server response. Restarting mic...',
            );
            _setState(VoiceAgentState.LISTENING);
            _startMicrophone(); // Retry listening
          }
        });

        // Wait for 'user_message' message to officially change state to PROCESSING from server
        return;
      }
    }

    final base64Audio = base64Encode(bytes);
    final payload = {"type": "audio", "audio": base64Audio};
    _sendWSMessage(payload);
  }

  void stopSession() {
    debugPrint('[VoiceAgent] Stopping session (Screen Exit)...');
    _isIntentionalClose = true;
    _sendWSMessage({"type": "stop"});
    _cleanup(closeWebSocket: true);
    _setState(VoiceAgentState.IDLE);
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      if (type != 'audio_chunk') {
        debugPrint('[VoiceAgent] Received WS Message: $type');
      }

      switch (type) {
        case 'deepgram_connected':
          debugPrint(
            '[VoiceAgent] Deepgram connected. Waiting for started event.',
          );
          break;

        case 'started':
          debugPrint('[VoiceAgent] Agent started. Turning on mic.');

          // Capture new chatId if provided
          if (data['chatId'] != null) {
            _currentChatId = data['chatId'].toString();
            onChatCreated?.call(_currentChatId!);
          }

          // Align state transition: LISTENING on started
          _startMicrophone();
          break;

        case 'transcript':
          _onTranscript(data);
          break;

        case 'user_message':
          debugPrint('[VoiceAgent] User message: ${data['text']}');
          _processingTimeoutTimer?.cancel(); // Server responded!

          if (data['text'] != null && data['text'].toString().isNotEmpty) {
            onUserMessage?.call(data['text'].toString());
          }

          // Stop mic on user_message (if not already stopped by local silence)
          _stopMicrophone();

          // Align state transition: PROCESSING on user_message
          _setState(VoiceAgentState.PROCESSING);
          break;

        case 'ai_response':
          debugPrint('[VoiceAgent] Agent processing AI response...');
          if (data['text'] != null && data['text'].toString().isNotEmpty) {
            onAiResponse?.call(data['text'].toString());
          }
          // State stays PROCESSING until first audio chunk
          _onAiResponse(data);
          break;

        case 'audio_chunk':
          _onAudioChunk(data);
          break;

        case 'audio_complete':
          _onAudioComplete(data);
          break;

        case 'error':
          debugPrint('[VoiceAgent] Server Error Message: ${data['message']}');
          _errorMessage = data['message'] ?? 'Unknown Server Error';
          _setState(VoiceAgentState.ERROR);
          break;

        default:
          debugPrint('[VoiceAgent] Unhandled message type: $type');
      }
    } catch (e) {
      // Ignored for raw audio or non-json if any
    }
  }

  void _onTranscript(Map data) {
    final text = data['text'];
    final isFinal = data['isFinal'];
    debugPrint('[VoiceAgent] Transcript: $text (isFinal: $isFinal)');

    _interimText = text;
    notifyListeners();
  }

  void _onAiResponse(Map data) {
    final aiResponseText = data['text'];
    debugPrint('[VoiceAgent] AI Response Text: $aiResponseText');
    _aiText = aiResponseText;
    notifyListeners();
  }

  void _onAudioChunk(Map data) {
    // Stop mic during SPEAKING to prevent echo.
    if (_state != VoiceAgentState.SPEAKING) {
      // Align state transition: SPEAKING on first audio_chunk
      _setState(VoiceAgentState.SPEAKING);
      _stopMicrophone(); // ensure mic is off
    }
    final chunkBase64 = data['audio'];
    if (chunkBase64 != null) {
      final bytes = base64Decode(chunkBase64);
      _audioBuffer.addAll(bytes);
    }
  }

  Future<void> _onAudioComplete(Map data) async {
    debugPrint('[VoiceAgent] Audio complete received. Playback starting.');

    if (_audioBuffer.isNotEmpty) {
      try {
        final audioBytes = Uint8List.fromList(_audioBuffer);

        await _player.setAudioSource(AppAudioSource(audioBytes));
        _player.play(); // Start playing asynchronously

        // Wait until playback completes or stops
        await _player.playerStateStream.firstWhere(
          (state) =>
              state.processingState == ProcessingState.completed ||
              state.processingState == ProcessingState.idle,
        );

        _audioBuffer.clear();
        debugPrint('[VoiceAgent] Playback finished.');
      } catch (e) {
        debugPrint('[VoiceAgent] Audio playback error: $e');
      }
    }

    debugPrint('[VoiceAgent] Agent finished speaking. Resuming listening...');
    _interimText = "";
    _aiText = "";

    // Automatically restart microphone listening without dropping websocket
    await _startMicrophone();
  }

  Future<void> _cleanup({bool closeWebSocket = true}) async {
    debugPrint('[VoiceAgent] Cleanup resources. closeWS=$closeWebSocket');
    try {
      _emptyTurnTimer?.cancel();
      _processingTimeoutTimer?.cancel();
      await _recordSub?.cancel();
      _recordSub = null;
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
      if (closeWebSocket && _channel != null) {
        _channel!.sink.close();
        _channel = null;
      }
      _audioBuffer.clear();
      await _player.stop(); // Stop audio playback immediately
    } catch (e) {
      debugPrint('[VoiceAgent] Cleanup error: $e');
    }
  }

  @override
  void dispose() {
    _isIntentionalClose = true;
    _cleanup(closeWebSocket: true);
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }
}

class AppAudioSource extends StreamAudioSource {
  final Uint8List _bytes;

  AppAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
