import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'ai_rashmi_service.dart';
import 'voice_websocket_service.dart';

class Message {
  final String role; // 'user' or 'assistant'
  final String content;

  Message({required this.role, required this.content});
}

class AiRashmiController extends GetxController {
  final AiRashmiService service;

  AiRashmiController({required this.service});

  String? chatId;
  String? currentTitle;
  bool isInitializing = false;
  bool isSending = false;
  bool isLoadingHistory = false;
  String? error;
  final List<Message> messages = [];
  final List<ChatSummary> history = [];

  // Voice recording state
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final VoiceWebSocketService _voiceWebSocket = VoiceWebSocketService();
  bool isRecording = false;
  bool isProcessingVoice = false;
  bool isPlayingAudio = false;
  String? currentRecordingPath;
  Timer? _audioChunkTimer;
  List<Uint8List> _receivedAudioChunks = [];

  @override
  void onInit() {
    super.onInit();
    loadHistory(); // sirf history, chat first message se banega
    _setupWebSocketCallbacks();
  }

  @override
  void onClose() {
    _audioChunkTimer?.cancel();
    _audioCompletionSubscription?.cancel();
    _voiceWebSocket.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();

    // Clean up temp audio files
    for (var file in _tempAudioFiles) {
      try {
        if (file.existsSync()) {
          file.delete();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    _tempAudioFiles.clear();

    super.onClose();
  }

  void _setupWebSocketCallbacks() {
    _voiceWebSocket.onStarted = (chatId) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] WebSocket onStarted callback triggered');
      print('📱 [ViewModel] Received chatId: $chatId');
      if (chatId.isNotEmpty) {
        this.chatId = chatId;
        currentTitle = 'Voice Chat';
        print('📱 [ViewModel] ChatId set to: ${this.chatId}');
        print(
          '📱 [ViewModel] Loading history (this will call REST API /api/mobile/chat)...',
        );
        loadHistory();
      } else {
        print('⚠️ [ViewModel] Empty chatId received');
      }
      print('📱 [ViewModel] ============================================');
    };

    _voiceWebSocket.onDeepgramConnected = (message) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] Deepgram connected callback');
      print('📱 [ViewModel] Message: $message');
      print('📱 [ViewModel] ============================================');
      // Optional: Show connection message
    };

    _voiceWebSocket.onTranscript = (text, isFinal) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] Transcript callback');
      print('📱 [ViewModel] Text: $text');
      print('📱 [ViewModel] IsFinal: $isFinal');
      print('📱 [ViewModel] ============================================');
      // Show real-time transcript if needed
      if (isFinal && text.isNotEmpty) {
        // Final transcript - will be added as user message
        print('📱 [ViewModel] Final transcript received: $text');
      }
    };

    _voiceWebSocket.onUserMessage = (text) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] User message callback');
      print('📱 [ViewModel] Text: $text');
      if (text.isNotEmpty) {
        print('📱 [ViewModel] Adding user message to messages list');
        messages.add(Message(role: 'user', content: text));
        update();
        print('✅ [ViewModel] User message added');
      } else {
        print('⚠️ [ViewModel] Empty user message, not adding');
      }
      print('📱 [ViewModel] ============================================');
    };

    _voiceWebSocket.onAiResponse = (text) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] AI response callback');
      print('📱 [ViewModel] Text: $text');
      if (text.isNotEmpty) {
        print('📱 [ViewModel] Adding AI response to messages list');
        messages.add(Message(role: 'assistant', content: text));
        print(
          '📱 [ViewModel] Reloading history (this will call REST API /api/mobile/chat)...',
        );
        loadHistory();
        update();
        print('✅ [ViewModel] AI response added');
      } else {
        print('⚠️ [ViewModel] Empty AI response, not adding');
      }
      print('📱 [ViewModel] ============================================');
    };

    _voiceWebSocket.onAudioChunk = (audioData, chunkIndex) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] Audio chunk callback');
      print('📱 [ViewModel] Chunk index: $chunkIndex');
      print('📱 [ViewModel] Audio data size: ${audioData.length} bytes');
      print(
        '📱 [ViewModel] Adding to received chunks (total: ${_receivedAudioChunks.length + 1})',
      );
      _receivedAudioChunks.add(audioData);
      print('📱 [ViewModel] Starting audio playback...');
      _playAudioChunksSequentially();
      print('📱 [ViewModel] ============================================');
    };

    _voiceWebSocket.onAudioComplete = (totalChunks) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] Audio complete callback');
      print('📱 [ViewModel] Total chunks: $totalChunks');
      print('📱 [ViewModel] Received chunks: ${_receivedAudioChunks.length}');
      // Wait a bit for all chunks to be received, then finalize
      print('📱 [ViewModel] Waiting 500ms before finalizing playback...');
      Future.delayed(const Duration(milliseconds: 500), () {
        _finalizeAudioPlayback();
        print('✅ [ViewModel] Audio playback finalized');
      });
      print('📱 [ViewModel] ============================================');
    };

    _voiceWebSocket.onStopped = (message) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] WebSocket stopped callback');
      print('📱 [ViewModel] Message: $message');
      isProcessingVoice = false;
      print('📱 [ViewModel] isProcessingVoice set to false');
      update();
      print('📱 [ViewModel] ============================================');
    };

    _voiceWebSocket.onError = (message, errorCode) {
      print('📱 [ViewModel] ============================================');
      print('📱 [ViewModel] WebSocket onError callback triggered');
      print('📱 [ViewModel] Error message: $message');
      print('📱 [ViewModel] Error code: $errorCode');

      // Handle specific error cases with user-friendly messages
      String userFriendlyError = message;

      if (message.contains('ElevenLabs API error') ||
          message.contains('detected_unusual_activity') ||
          message.contains('Free Tier usage disabled')) {
        userFriendlyError =
            'Voice service temporarily unavailable. Please try again later or use text chat.';
        print('📱 [ViewModel] Detected ElevenLabs API error');
      } else if (message.contains('401') || message.contains('Unauthorized')) {
        userFriendlyError =
            'Authentication failed. Please try logging in again.';
        print('📱 [ViewModel] Detected authentication error');
      } else if (message.contains('Failed to connect') ||
          message.contains('Connection')) {
        userFriendlyError =
            'Connection error. Please check your internet connection and try again.';
        print('📱 [ViewModel] Detected connection error');
      } else if (message.contains('speech') || message.contains('audio')) {
        userFriendlyError =
            'Unable to generate voice response. Please try using text chat instead.';
        print('📱 [ViewModel] Detected speech/audio error');
      }

      print('📱 [ViewModel] User-friendly error: $userFriendlyError');
      error = userFriendlyError;
      isProcessingVoice = false;
      isRecording = false;

      // Stop the timer if recording was in progress
      print('📱 [ViewModel] Cancelling audio chunk timer...');
      _audioChunkTimer?.cancel();
      _audioChunkTimer = null;

      // Stop WebSocket session on error
      print('📱 [ViewModel] Stopping WebSocket session due to error...');
      _voiceWebSocket.stopSession();

      update();
      print('📱 [ViewModel] ============================================');
    };
  }

  Future<void> loadHistory() async {
    print('📱 [ViewModel] ============================================');
    print('📱 [ViewModel] loadHistory() called');
    print('📱 [ViewModel] This will call REST API: /api/mobile/chat');
    print('📱 [ViewModel] ============================================');
    isLoadingHistory = true;
    update();
    try {
      final items = await service.fetchHistory();
      print('📱 [ViewModel] History loaded: ${items.length} chats');
      history
        ..clear()
        ..addAll(items);
    } catch (e) {
      print('🔴 [ViewModel] Error loading history: $e');
      // ignore for now, error already handled in service layer
    } finally {
      isLoadingHistory = false;
      update();
    }
  }

  Future<void> newChat() async {
    // clear current messages, next user message se naya chat banega
    messages.clear();
    chatId = null;
    currentTitle = null;
    update();
  }

  Future<void> selectChat(ChatSummary chat) async {
    chatId = chat.chatId;
    currentTitle = chat.title;
    messages.clear();
    isInitializing = true;
    update();

    try {
      final historyMessages = await service.fetchMessages(chat.chatId);
      messages
        ..clear()
        ..addAll(
          historyMessages.map((m) => Message(role: m.role, content: m.content)),
        );
    } catch (e) {
      error = 'Failed to load chat messages.';
    } finally {
      isInitializing = false;
      update();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isSending) return;

    isSending = true;
    error = null;
    messages.add(Message(role: 'user', content: text));
    update();

    try {
      // Agar chatId nahi hai to pehle dynamic title ke sath chat banao
      if (chatId == null) {
        final title = _titleFromMessage(text);
        currentTitle = title;
        chatId = await service.createChat(title: title);
        await loadHistory(); // naya chat history mein bhi aa jaye
      }

      final assistantReply = await service.sendMessage(
        chatId: chatId!,
        message: text,
      );
      messages.add(Message(role: 'assistant', content: assistantReply.trim()));
      await loadHistory(); // lastMessage / count refresh
    } catch (e) {
      error = 'Failed to send message.';
    } finally {
      isSending = false;
      update();
    }
  }

  String _titleFromMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'New chat';
    // first 30 characters
    const maxLen = 30;
    return trimmed.length <= maxLen
        ? trimmed
        : trimmed.substring(0, maxLen).trim();
  }

  void clearError() {
    error = null;
    update();
  }

  // Voice recording methods with WebSocket
  Future<void> startVoiceRecording() async {
    print('📱 [ViewModel] ============================================');
    print('📱 [ViewModel] startVoiceRecording() called');
    print(
      '📱 [ViewModel] Current state - isRecording: $isRecording, isProcessingVoice: $isProcessingVoice',
    );

    if (isRecording || isProcessingVoice) {
      print('⚠️ [ViewModel] Already recording or processing, returning');
      print('📱 [ViewModel] ============================================');
      return;
    }

    print('📱 [ViewModel] Requesting microphone permission...');
    // Request microphone permission
    final status = await Permission.microphone.request();
    print('📱 [ViewModel] Microphone permission status: $status');
    if (!status.isGranted) {
      print('🔴 [ViewModel] Microphone permission denied');
      error = 'Microphone permission is required for voice recording';
      update();
      print('📱 [ViewModel] ============================================');
      return;
    }

    try {
      print('📱 [ViewModel] Checking if recorder has permission...');
      // Check if recorder is available
      if (await _audioRecorder.hasPermission()) {
        print('✅ [ViewModel] Recorder permission granted');
        print('📱 [ViewModel] Starting WebSocket session with chatId: $chatId');
        // Start WebSocket session first and wait for confirmation
        await _voiceWebSocket.startSession(chatId: chatId);

        print('📱 [ViewModel] WebSocket startSession completed');
        print('📱 [ViewModel] Checking WebSocket connection status...');
        print('📱 [ViewModel] isConnected: ${_voiceWebSocket.isConnected}');

        if (!_voiceWebSocket.isConnected) {
          print('🔴 [ViewModel] WebSocket connection failed');
          error = 'Failed to connect to voice service';
          update();
          print('📱 [ViewModel] ============================================');
          return;
        }

        print('✅ [ViewModel] WebSocket connected successfully!');

        // Wait a bit for server to send "started" confirmation
        print(
          '📱 [ViewModel] Waiting 500ms for server "started" confirmation...',
        );
        await Future.delayed(const Duration(milliseconds: 500));
        print('📱 [ViewModel] Wait completed');

        // Try to record in PCM16 format first (direct PCM, no header)
        // If not supported, fall back to WAV and parse header
        print('📱 [ViewModel] Getting temporary directory...');
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        currentRecordingPath = '${directory.path}/voice_$timestamp.pcm';
        print('📱 [ViewModel] Recording path: $currentRecordingPath');

        try {
          print(
            '📱 [ViewModel] Attempting to start recording with PCM16 format...',
          );
          // Try PCM16 first (direct raw PCM, no header to parse)
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.pcm16bits, // Raw 16-bit PCM
              sampleRate: 16000, // 16kHz
              numChannels: 1, // Mono
            ),
            path: currentRecordingPath!,
          );
          _wavHeaderSize = 0; // No header for raw PCM
          print('✅ [ViewModel] Recording started with PCM16 format');
        } catch (e) {
          // Fallback to WAV if PCM16 not supported
          print('⚠️ [ViewModel] PCM16 not supported, using WAV: $e');
          currentRecordingPath = '${directory.path}/voice_$timestamp.wav';
          print('📱 [ViewModel] New recording path: $currentRecordingPath');
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.wav, // WAV format (contains PCM data)
              sampleRate: 16000, // 16kHz
              numChannels: 1, // Mono
            ),
            path: currentRecordingPath!,
          );
          _wavHeaderSize =
              44; // Standard WAV header size (will be updated when parsed)
          print('✅ [ViewModel] Recording started with WAV format');
        }

        isRecording = true;
        isProcessingVoice = true;
        error = null;
        _receivedAudioChunks.clear(); // Clear previous chunks
        print(
          '📱 [ViewModel] Recording state set: isRecording=$isRecording, isProcessingVoice=$isProcessingVoice',
        );
        update();

        // Start sending audio chunks every 150ms (100-200ms range)
        // Note: This reads from file incrementally. For true streaming,
        // you'd need to use the record package's stream API or flutter_sound
        _lastSentPosition = 0;
        print('📱 [ViewModel] Starting audio chunk timer (every 150ms)...');
        _audioChunkTimer = Timer.periodic(const Duration(milliseconds: 150), (
          timer,
        ) async {
          if (!isRecording || !_voiceWebSocket.isConnected) {
            print(
              '⚠️ [ViewModel] Audio chunk timer: Stopping (isRecording: $isRecording, isConnected: ${_voiceWebSocket.isConnected})',
            );
            timer.cancel();
            return;
          }
          await _sendAudioChunkIncremental();
        });
        print('✅ [ViewModel] Audio chunk timer started');
        print('✅ [ViewModel] Voice recording started successfully!');
        print('📱 [ViewModel] ============================================');
      } else {
        print('🔴 [ViewModel] Recorder permission denied');
        error = 'Microphone permission denied';
        update();
        print('📱 [ViewModel] ============================================');
      }
    } catch (e, stackTrace) {
      print('🔴 [ViewModel] ============================================');
      print('🔴 [ViewModel] ERROR starting voice recording:');
      print('🔴 [ViewModel] Error: $e');
      print('🔴 [ViewModel] StackTrace: $stackTrace');
      print('🔴 [ViewModel] ============================================');
      error = 'Failed to start recording: $e';
      isRecording = false;
      isProcessingVoice = false;
      update();
    }
  }

  int _lastSentPosition = 0;
  int _wavHeaderSize = 0;
  bool _headerParsed = false;

  // Parse WAV header to find where PCM data starts
  int _parseWavHeader(Uint8List data) {
    if (data.length < 44) return 0;

    // Check for RIFF header
    if (String.fromCharCodes(data.sublist(0, 4)) != 'RIFF') {
      return 0; // Not a WAV file
    }

    // Find 'data' chunk (this is where PCM data starts)
    for (int i = 12; i < data.length - 8; i++) {
      if (String.fromCharCodes(data.sublist(i, i + 4)) == 'data') {
        // 'data' chunk found, PCM data starts 8 bytes after (after 'data' and size)
        return i + 8;
      }
    }

    // Fallback: assume standard 44-byte header
    return 44;
  }

  Future<void> _sendAudioChunkIncremental() async {
    if (currentRecordingPath == null ||
        !File(currentRecordingPath!).existsSync()) {
      return;
    }

    try {
      final audioFile = File(currentRecordingPath!);
      final fileSize = await audioFile.length();

      // If header not parsed yet and it's a WAV file, parse it first
      if (!_headerParsed &&
          currentRecordingPath!.endsWith('.wav') &&
          fileSize >= 44) {
        print('📱 [ViewModel] Parsing WAV header...');
        final headerFile = await audioFile.open();
        final headerData = await headerFile.read(min(200, fileSize));
        await headerFile.close();

        _wavHeaderSize = _parseWavHeader(Uint8List.fromList(headerData));
        _headerParsed = true;
        _lastSentPosition = _wavHeaderSize; // Set position after header
        print(
          '📱 [ViewModel] WAV header parsed: headerSize=$_wavHeaderSize, position=$_lastSentPosition',
        );

        if (fileSize <= _wavHeaderSize) {
          // Only header, no PCM data yet
          print('📱 [ViewModel] Only header present, no PCM data yet');
          return;
        }
      } else if (!_headerParsed && _wavHeaderSize == 0) {
        // Raw PCM, no header
        _headerParsed = true;
        print('📱 [ViewModel] Raw PCM format, no header to parse');
      }

      if (fileSize <= _lastSentPosition) {
        return; // No new data
      }

      // Read PCM data from current position
      final randomAccessFile = await audioFile.open();
      await randomAccessFile.setPosition(_lastSentPosition);
      final newData = await randomAccessFile.read(fileSize - _lastSentPosition);
      await randomAccessFile.close();

      if (newData.isEmpty) {
        return;
      }

      // Convert to base64 and send (data is already PCM at this point)
      final base64Audio = base64Encode(newData);
      print(
        '📱 [ViewModel] Sending audio chunk: ${newData.length} bytes -> ${base64Audio.length} base64 chars (position: $_lastSentPosition -> $fileSize)',
      );
      _voiceWebSocket.sendAudioChunk(base64Audio);
      _lastSentPosition = fileSize;
    } catch (e, stackTrace) {
      // Log error but don't stop recording
      print('🔴 [ViewModel] Error sending audio chunk: $e');
      print('🔴 [ViewModel] StackTrace: $stackTrace');
      // Set error but continue recording
      error = 'Error sending audio: $e';
      update();
    }
  }

  Future<void> stopVoiceRecording() async {
    print('📱 [ViewModel] ============================================');
    print('📱 [ViewModel] stopVoiceRecording() called');
    print('📱 [ViewModel] isRecording: $isRecording');

    if (!isRecording) {
      print('⚠️ [ViewModel] Not recording, returning');
      print('📱 [ViewModel] ============================================');
      return;
    }

    try {
      print('📱 [ViewModel] Cancelling audio chunk timer...');
      // Cancel timer
      _audioChunkTimer?.cancel();
      _audioChunkTimer = null;

      print('📱 [ViewModel] Stopping audio recorder...');
      // Stop recording
      await _audioRecorder.stop();
      isRecording = false;
      update();
      print('✅ [ViewModel] Recording stopped');

      // Send final audio chunk if any remaining data
      print('📱 [ViewModel] Sending final audio chunk...');
      await _sendAudioChunkIncremental();

      // Wait a bit for final chunk to be sent, then stop WebSocket session
      print('📱 [ViewModel] Waiting 300ms before stopping WebSocket...');
      await Future.delayed(const Duration(milliseconds: 300));
      print('📱 [ViewModel] Stopping WebSocket session...');
      await _voiceWebSocket.stopSession();
      print('✅ [ViewModel] WebSocket session stopped');

      // Reset for next recording
      print('📱 [ViewModel] Resetting recording state...');
      _lastSentPosition = 0;
      _wavHeaderSize = 0;
      _headerParsed = false;

      // Clean up recording file
      try {
        if (currentRecordingPath != null &&
            File(currentRecordingPath!).existsSync()) {
          print(
            '📱 [ViewModel] Cleaning up recording file: $currentRecordingPath',
          );
          await File(currentRecordingPath!).delete();
          print('✅ [ViewModel] Recording file deleted');
        }
      } catch (e) {
        print('⚠️ [ViewModel] Error cleaning up recording file: $e');
        // Ignore cleanup errors
      }
      currentRecordingPath = null;
      print('✅ [ViewModel] Voice recording stopped successfully');
      print('📱 [ViewModel] ============================================');
    } catch (e, stackTrace) {
      print('🔴 [ViewModel] ============================================');
      print('🔴 [ViewModel] ERROR stopping voice recording:');
      print('🔴 [ViewModel] Error: $e');
      print('🔴 [ViewModel] StackTrace: $stackTrace');
      print('🔴 [ViewModel] ============================================');
      isRecording = false;
      error = 'Failed to stop recording: $e';
      update();
    }
  }

  bool _isPlayingChunk = false;
  final List<File> _tempAudioFiles = [];

  // Play audio chunks sequentially
  Future<void> _playAudioChunksSequentially() async {
    if (_isPlayingChunk || _receivedAudioChunks.isEmpty) return;

    if (!isPlayingAudio) {
      isPlayingAudio = true;
      update();
    }

    await _playNextAudioChunk();
  }

  StreamSubscription? _audioCompletionSubscription;

  Future<void> _playNextAudioChunk() async {
    if (_receivedAudioChunks.isEmpty) {
      _isPlayingChunk = false;
      _audioCompletionSubscription?.cancel();
      _audioCompletionSubscription = null;
      // Wait a bit before setting isPlayingAudio to false in case more chunks arrive
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_receivedAudioChunks.isEmpty && !_isPlayingChunk) {
          isPlayingAudio = false;
          update();
        }
      });
      return;
    }

    if (_isPlayingChunk) return; // Already playing a chunk

    try {
      _isPlayingChunk = true;
      final audioData = _receivedAudioChunks.removeAt(0);

      // Save chunk to temp file as MP3
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final chunkPath =
          '${directory.path}/audio_chunk_${timestamp}_${_receivedAudioChunks.length}.mp3';
      final chunkFile = File(chunkPath);
      await chunkFile.writeAsBytes(audioData);
      _tempAudioFiles.add(chunkFile);

      // Cancel previous subscription if any
      await _audioCompletionSubscription?.cancel();

      // Setup completion listener
      final completer = Completer<void>();
      _audioCompletionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
        completer.complete();
      });

      // Play chunk
      await _audioPlayer.play(UrlSource('file://$chunkPath'));

      // Wait for completion
      await completer.future;

      // Clean up temp file
      try {
        if (chunkFile.existsSync()) {
          chunkFile.delete();
          _tempAudioFiles.remove(chunkFile);
        }
      } catch (e) {
        // Ignore cleanup errors
      }

      _isPlayingChunk = false;

      // Play next chunk if available
      if (_receivedAudioChunks.isNotEmpty) {
        await _playNextAudioChunk();
      } else {
        isPlayingAudio = false;
        update();
      }
    } catch (e) {
      _isPlayingChunk = false;
      print('Error playing audio chunk: $e');
      // On error, try next chunk if available
      if (_receivedAudioChunks.isNotEmpty) {
        await _playNextAudioChunk();
      } else {
        isPlayingAudio = false;
        update();
      }
    }
  }

  void _finalizeAudioPlayback() {
    // All chunks received, playback will complete naturally
    // Clean up temp files after a delay (they'll be cleaned up as chunks finish playing)
    // This is just a safety cleanup
    Future.delayed(const Duration(seconds: 5), () {
      for (var file in _tempAudioFiles) {
        try {
          if (file.existsSync()) {
            file.delete();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      }
      _tempAudioFiles.clear();
    });
  }
}
