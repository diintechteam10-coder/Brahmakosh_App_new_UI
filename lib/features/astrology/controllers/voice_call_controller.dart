import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import '../../../common/api_urls.dart';
import '../../../common/models/astrologist_model.dart';
import '../../../common/utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/socket_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Hide navigator from get so flutter_webrtc can use it
import 'package:get/get.dart' hide navigator;

class VoiceCallController extends GetxController {
  final Astrologist expert;
  final SocketService _socketService = SocketService();
  final AudioRecorder _audioRecorder = AudioRecorder();

  VoiceCallController({required this.expert});

  final isConnecting = true.obs;
  final isRinging = false.obs;
  final isConnected = false.obs;
  final isMuted = false.obs;
  final isSpeakerOn = false.obs;
  final isRecording = false.obs;
  final isEnded = false.obs;
  final duration = 0.obs;

  String? _conversationId;
  String? _recordingPath;
  Timer? _timer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  @override
  void onInit() {
    super.onInit();
    Utils.print(
      "[VOICE_CALL_LOG] 🚀 VoiceCallController initialized for expert: ${expert.name}",
    );
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    isConnecting.value = true;
    await _createConversation();
    if (_conversationId != null) {
      Utils.print(
        "[VOICE_CALL_LOG] ✅ Ready to connect socket. Conversation ID: $_conversationId",
      );
      await _socketService.initSocket();
      _setupSocketListeners();
      _initiateCall();
    } else {
      _endCallLocal("Failed to create conversation");
    }
  }

  Future<void> _createConversation() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) return;

      final body = {"partnerId": expert.id};

      final response = await http.post(
        Uri.parse(ApiUrls.createConversation),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          _conversationId = data['data']['conversationId'];
          Utils.print(
            "[VOICE_CALL_LOG] ✅ Conversation Created: $_conversationId",
          );
        }
      } else {
        Utils.print(
          "[VOICE_CALL_LOG] ❌ Failed to create conversation: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      Utils.print("[VOICE_CALL_LOG] ❌ Exception creating conversation: $e");
    }
  }

  void _setupSocketListeners() {
    // Make sure we're joining the room for signs to pass through correctly if backend requires room joining.
    // However, the prompt says the event relies on conversationId payload.
    _socketService.on('voice:call:accepted', _onCallAccepted);
    _socketService.on('voice:signal', _onSignalReceived);
    _socketService.on('voice:call:ended', _onCallEndedEvent);
    // You might also want to listen for rejected or offline errors.
  }

  void _initiateCall() {
    if (_conversationId == null) return;

    isConnecting.value = false;
    isRinging.value = true;

    Utils.print(
      "[VOICE_CALL_LOG] 🔔 Emitting 'voice:call:initiate' for conversation: $_conversationId",
    );
    _socketService.emit('voice:call:initiate', {
      "conversationId": _conversationId,
    });

    // Auto-timeout if no answer after 30s
    Future.delayed(const Duration(seconds: 30), () {
      if (isRinging.value && !isConnected.value) {
        _endCallLocal("No answer");
      }
    });
  }

  Future<void> _onCallAccepted(dynamic data) async {
    Utils.print("[VOICE_CALL_LOG] 📞 Call Accepted by partner!");
    isRinging.value = false;

    // ONLY start WebRTC once accepted
    await _initializeWebRTC();
  }

  Future<void> _initializeWebRTC() async {
    try {
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      };

      _peerConnection = await createPeerConnection(configuration);

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _socketService.emit('voice:signal', {
          "conversationId": _conversationId,
          "signal": {"type": "candidate", "candidate": candidate.toMap()},
        });
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteStream = stream;
        Utils.print("[VOICE_CALL_LOG] ✅ Remote stream received from peer");
        // Trigger a fake update to get the stream to UI
        isConnected.refresh();
      };

      // Get microphone
      final mediaConstraints = {'audio': true, 'video': false};

      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // Start recording locally
      _startRecording();

      // Create Offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _socketService.emit('voice:signal', {
        "conversationId": _conversationId,
        "signal": {"type": "offer", "sdp": offer.sdp},
      });

      isConnected.value = true;
      _startTimer();
    } catch (e) {
      Utils.print("[VOICE_CALL_LOG] ❌ WebRTC Initialization Error: $e");
      _endCallLocal("Microphone access denied or WebRTC error");
    }
  }

  Future<void> _onSignalReceived(dynamic data) async {
    try {
      if (data['conversationId'] != _conversationId) return;

      final signal = data['signal'];
      if (signal == null) return;

      final type = signal['type'];
      Utils.print("[VOICE_CALL_LOG] 📡 Signal received from peer: $type");

      if (type == 'answer') {
        final sdp = signal['sdp'];
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(sdp, type),
        );
      } else if (type == 'candidate') {
        final candidateData = signal['candidate'];
        final candidate = RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(candidate);
      }
    } catch (e) {
      Utils.print("[VOICE_CALL_LOG] ❌ Error handling WebRTC signal: $e");
    }
  }

  MediaStream? getRemoteStream() {
    return _remoteStream;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      duration.value++;
    });
  }

  void toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final track = audioTracks[0];
        track.enabled = !track.enabled;
        isMuted.value = !track.enabled;
      }
    }
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    Helper.setSpeakerphoneOn(isSpeakerOn.value);
    Utils.print("[VOICE_CALL_LOG] 🔊 Speaker toggled: ${isSpeakerOn.value}");
  }

  void endCall() {
    if (_conversationId != null) {
      _socketService.emit('voice:call:end', {
        "conversationId": _conversationId,
      });
    }
    _endCallLocal("Call ended by user");
  }

  void _onCallEndedEvent(dynamic data) {
    if (data['conversationId'] == _conversationId) {
      _endCallLocal("Call ended by expert");
    }
  }

  Future<void> _endCallLocal(String reason) async {
    if (isEnded.value) return;

    Utils.print("[VOICE_CALL_LOG] 🛑 Ending call locally: $reason");
    isEnded.value = true;
    _timer?.cancel();

    // Close WebRTC
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.close();

    // Stop Recorder
    isRecording.value = false;
    await _stopRecordingAndUpload();

    // Clean up listeners
    _socketService.off('voice:call:accepted', _onCallAccepted);
    _socketService.off('voice:signal', _onSignalReceived);
    _socketService.off('voice:call:ended', _onCallEndedEvent);

    Get.back(
      result: true,
    ); // Return to previous screen (can pass a summary object later)
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordingPath =
            '${tempDir.path}/call_record_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _recordingPath!,
        );
        isRecording.value = true;
        Utils.print(
          "[VOICE_CALL_LOG] 🎙️ Recording started at $_recordingPath",
        );
      }
    } catch (e) {
      isRecording.value = false;
      Utils.print("[VOICE_CALL_LOG] ❌ Recording error: $e");
    }
  }

  Future<void> _stopRecordingAndUpload() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null && _conversationId != null) {
        Utils.print("[VOICE_CALL_LOG] ✅ Recording stopped: $path");
        _uploadRecording(path);
      }
    } catch (e) {
      Utils.print("[VOICE_CALL_LOG] ❌ Stop recording error: $e");
    }
  }

  Future<void> _uploadRecording(String filePath) async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) return;

      // 1. Get Upload URL
      final getUrlResponse = await http.post(
        Uri.parse(ApiUrls.voiceRecordingUploadUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"conversationId": _conversationId, "role": "user"}),
      );

      final getUrlData = jsonDecode(getUrlResponse.body);
      if (getUrlData['success'] == true) {
        final uploadUrl = getUrlData['data']['uploadUrl'];
        final audioKey = getUrlData['data']['key'];
        final audioUrl = getUrlData['data']['fileUrl'];

        // 2. Upload to S3
        final file = File(filePath);
        final fileBytes = await file.readAsBytes();

        final uploadResponse = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            'Content-Type': 'audio/m4a', // Using m4a since we specified aacLc
          },
          body: fileBytes,
        );

        if (uploadResponse.statusCode == 200) {
          Utils.print(
            "[VOICE_CALL_LOG] ✅ Recording uploaded to S3 successfully",
          );

          // 3. Attach recording to conversation
          await http.patch(
            Uri.parse(
              "${ApiUrls.voiceRecordingAttach}/$_conversationId/voice-recording",
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({"audioKey": audioKey, "audioUrl": audioUrl}),
          );
          Utils.print("[VOICE_CALL_LOG] ✅ Recording attached to conversation");
        }
      }
    } catch (e) {
      Utils.print("[VOICE_CALL_LOG] ❌ Upload recording error: $e");
    }
  }

  @override
  void onClose() {
    _endCallLocal("Controller closed");
    _audioRecorder.dispose();
    super.onClose();
  }
}
