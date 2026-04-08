import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import 'package:brahmakosh/features/check_in/models/spiritual_session_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_clip_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brahmakosh/features/check_in/blocs/meditation_session/meditation_session_bloc.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

class MeditationStart extends StatelessWidget {
  const MeditationStart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MeditationSessionBloc(repository: SpiritualRepository()),
      child: const MeditationPlaybackView(),
    );
  }
}

class MeditationPlaybackView extends StatefulWidget {
  const MeditationPlaybackView({super.key});

  @override
  State<MeditationPlaybackView> createState() => _MeditationPlaybackViewState();
}

class _MeditationPlaybackViewState extends State<MeditationPlaybackView>
    with TickerProviderStateMixin {
  // 🔹 Entry animation
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 🔹 Breathing / Pulse
  late AnimationController _breathingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bgScaleAnimation;
  // 🔹 Halo & Rotation
  late AnimationController _haloController;

  // 🔹 Ripple
  late AnimationController _rippleController;

  bool showPlayImage = false;
  bool showPlayUI = false;
  bool _isStarted = false;
  bool _isPlaying = false;
  bool _audioStartedPlaying = false;
  bool _isManualExit = false;
  bool _isDisposed = false;

  late AnimationController _timerController;

  int _totalDuration = 60; // Default, will be updated from arguments
  bool _isFetchingDuration = false;
  bool _isDurationChoiceManual = false;
  SpiritualConfiguration? _config;

  // 🔹 Audio Player (Switched to just_audio for superior buffering/preloading)
  late AudioPlayer _audioPlayer;
  String? _currentAudioUrl;
  String? _currentVideoUrl; 
  bool _isAudioInitialized = false;
  bool _isAudioReady = false; // Flag for buffering completion

  // 🔹 Video Player
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  // 🔹 Media readiness: only audio gates interaction.
  // Video is decorative background — loads in parallel, never blocks.
  bool get _isMediaReady => _isAudioReady;


  /*
  bool _showSongSelection = false;
  int _selectedTrack = 0;
  final List<String> _tracks = [
    "Zen Garden",
    "Deep Space",
    "Healing Rain",
    "Morning Mist",
    "Cosmic Om",
    "Nature's Call",
  ];
  */

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null) {
      if (args['duration'] != null) {
        // duration passed in minutes, convert to seconds
        _totalDuration = (args['duration'] as num).toInt() * 60;
        _isDurationChoiceManual = true;
      }
      if (args['config'] != null) {
        _config = args['config'] as SpiritualConfiguration?;
      }
    }

    final isPrayer = (_config?.type == 'prayer') || (_config?.prayerType != null);
    if (isPrayer && !_isDurationChoiceManual) {
      _isFetchingDuration = true;
    }

    _parseMediaUrls(); // Parse URLs early

    /// 1️⃣ ENTRY
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const _SafeCurve(Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const _SafeCurve(Curves.elasticOut),
      ),
    );

    /// 2️⃣ BREATHING (Pulsating heart of the scene)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: const _SafeCurve(Curves.easeInOutSine),
      ),
    );
    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: const _SafeCurve(Curves.easeInOutSine),
      ),
    );

    /// 3️⃣ HALO ROTATION (Constant celestial rotation)
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    /// 4️⃣ RIPPLE
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    /// 5️⃣ TIMER
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalDuration),
    );

    // Listen for timer completion
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Stop audio when timer completes
        if (_isAudioInitialized) {
          try {
            _audioPlayer.stop();
          } catch (e) {
            print("Error stopping audio: $e");
          }
        }
        setState(() {
          _isPlaying = false;
          _isStarted = false;
        });

        // Save Session
        _triggerSaveSession();
      }
    });

    _initMedia(); // Unified preloading
  }

  Future<void> _initMedia() async {
    _audioPlayer = AudioPlayer();

    // 1. Audio Readiness Listener
    _audioPlayer.playerStateStream.listen((state) {
      if (_isDisposed || !mounted) return;
      if (state.processingState == ProcessingState.ready && !_isAudioReady) {
        debugPrint("✅ Audio Ready (Buffered)");
        setState(() => _isAudioReady = true);
        // 🔹 Start decorations as soon as audio is ready (don't wait for video)
        _startFlowDecorations();
        if (_config?.type == 'prayer' || _config?.prayerType != null) {
          _checkAndStartPrayer();
        }
      }
    });

    // 2. Sync with Real Audio Duration
    _audioPlayer.durationStream.listen((duration) {
      if (_isDisposed || !mounted) return;
      final isPrayer = (_config?.type == 'prayer') || (_config?.prayerType != null);
      if (duration != null && duration.inSeconds > 0 && (isPrayer || !_isDurationChoiceManual)) {
        debugPrint("⏱️ Real Audio Duration Received: ${duration.inSeconds}s");
        setState(() {
          _isFetchingDuration = false;
          _totalDuration = duration.inSeconds;
          _timerController.duration = duration;
        });
      }
    });

    // 3. Track when audio actually starts playing
    _audioPlayer.positionStream.listen((position) {
      if (_isDisposed || !mounted) return;
      if (position.inMilliseconds > 0 && !_audioStartedPlaying) {
        debugPrint("🎵 Audio Started Playing: ${position.inMilliseconds}ms");
        setState(() => _audioStartedPlaying = true);

        final isPrayer = (_config?.type == 'prayer') || (_config?.prayerType != null);
        if (isPrayer && _isStarted && _isPlaying && !_timerController.isAnimating) {
          _timerController.forward();
        }
      }
    });

    // 🔹 Run AudioSession config, video init, and audio init ALL in parallel
    // Previously AudioSession.configure() was awaited sequentially before init
    await Future.wait([
      _configureAudioSession(),
      Future.microtask(() => _initVideo()),
      _initAudio(),
    ], eagerError: false);
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint("⚠️ AudioSession config error (non-fatal): $e");
    }
  }

  void _checkAndStartPrayer() {
    if (_isMediaReady && _isStarted && _isPlaying) {
      // If user tapped Begin or it's auto-start prayer
      _audioPlayer.play();
    }
  }


  void _parseMediaUrls() {
    final args = Get.arguments;
    List? clips;
    if (args != null) {
      if (args['clips'] is List) {
        clips = args['clips'];
      } else if (args['audioUrl'] != null) {
        // Handle case where audioUrl is passed directly
        clips = [
          {'audioUrl': args['audioUrl'], 'videoUrl': args['videoUrl']},
        ];
      }
    }

    String sourceUrl = "";
    String? videoSourceUrl;

    if (clips != null && clips.isNotEmpty) {
      final clip = clips[0];
      // Handle SpiritualClip Object
      if (clip is SpiritualClip) {
        if (clip.audioUrl != null && clip.audioUrl!.isNotEmpty) {
          sourceUrl = clip.audioUrl!;
        } else if (clip.fileUrl != null && clip.fileUrl!.isNotEmpty) {
          sourceUrl = clip.fileUrl!;
        }
        // capture video url
        if (clip.videoUrl != null && clip.videoUrl!.isNotEmpty) {
          videoSourceUrl = clip.videoUrl;
        }
      }
      // Handle Map (JSON)
      else if (clip is Map) {
        final audio = clip['audioUrl'];
        final file = clip['url'] ?? clip['fileUrl'];
        final video = clip['videoUrl'];

        if (audio != null && audio.toString().isNotEmpty) {
          sourceUrl = audio.toString();
        } else if (file != null && file.toString().isNotEmpty) {
          sourceUrl = file.toString();
        }

        if (video != null && video.toString().isNotEmpty) {
          videoSourceUrl = video.toString();
        }
      }
      // Final fallback (Dynamic access)
      else {
        try {
          dynamic c = clip;
          if (c.audioUrl != null && c.audioUrl.isNotEmpty) {
            sourceUrl = c.audioUrl;
          } else if (c.fileUrl != null && c.fileUrl.isNotEmpty) {
            sourceUrl = c.fileUrl;
          }

          if (c.videoUrl != null && c.videoUrl.isNotEmpty) {
            videoSourceUrl = c.videoUrl;
          }
        } catch (e) {
          print("Error accessing clip properties: $e");
        }
      }
    }

    _currentVideoUrl = videoSourceUrl;

    if (sourceUrl.isEmpty || !sourceUrl.startsWith('http')) {
      // If no URL or it's not a network URL, prepare for asset fallback
      // (Unless it's already an explicit local asset path we recognize)
      if (!sourceUrl.startsWith('images/') &&
          !sourceUrl.startsWith('assets/')) {
        sourceUrl = 'images/Default_music.mpeg';
      }
    }
    _currentAudioUrl = sourceUrl;
  }



  void _initVideo() {
    // Use network video if provided by API, otherwise fallback to default asset
    if (_currentVideoUrl != null && _currentVideoUrl!.startsWith('http')) {
      debugPrint("📹 Using network video for background: $_currentVideoUrl");
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(_currentVideoUrl!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else {
      debugPrint("📹 Using default asset video for background");
      _videoController = VideoPlayerController.asset(
        'assets/images/Meditation_video.mp4',
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }

    _videoController.initialize().then((_) {
      if (_isDisposed || !mounted) return;
      _videoController.setLooping(true);
      _videoController.setVolume(0);
      setState(() {
        _isVideoInitialized = true;
      });
      _videoController.play();
      // Flow decorations may already be started by audio ready callback
      if (!showPlayImage) _startFlowDecorations();
    }).catchError((error) {
      debugPrint("❌ Error initializing main video: $error");
      if (_currentVideoUrl != null && _currentVideoUrl!.startsWith('http')) {
        _currentVideoUrl = null;
        _initVideo();
      }
    });
  }


  // ... _triggerSaveSession ...

  // ... _showCompletionDialog ...

  void _startFlowDecorations() {
    if (_isDisposed || !mounted) return;
    setState(() => showPlayImage = true);
    _entryController.forward();
    
    final isPrayer = _config?.type == 'prayer' || _config?.prayerType != null;
    if (isPrayer) {
      // For Prayer, we "Start" the session logical state but wait for buffering
      setState(() {
        _isStarted = true;
        _isPlaying = true;
      });
      _breathingController.repeat(reverse: true);
      _rippleController.repeat();
      
      if (_isMediaReady) {
        _audioPlayer.play();
      }
    }
  }


  Future<void> _initAudio() async {
    try {
      String sourceUrl = _currentAudioUrl ?? 'images/Default_music.mpeg';
      bool isNetwork = sourceUrl.toLowerCase().startsWith('http');
      
      debugPrint("🎵 Preloading Audio: $sourceUrl");

      if (isNetwork) {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.parse(sourceUrl)),
          preload: true,
        );
      } else {
        // Just_audio uses AssetSource differently, similar to audioplayers but needs full path usually
        String assetPath = sourceUrl;
        if (!assetPath.startsWith('assets/')) {
          assetPath = 'assets/$assetPath';
        }
        await _audioPlayer.setAudioSource(
          AudioSource.asset(assetPath),
          preload: true,
        );
      }

      _isAudioInitialized = true;
      debugPrint("✅ Audio Preloaded");
    } catch (e) {
      debugPrint("❌ Error preloading audio: $e");
    }
  }


  void _triggerSaveSession({
    String status = "completed",
    int karmaPoints = -1, // -1 sentinel to use config default
    int? actualDurationSeconds,
    int completionPercentage = 100,
  }) {
    int durationMins = _totalDuration ~/ 60;
    int actDuration = actualDurationSeconds != null
        ? (actualDurationSeconds ~/ 60)
        : durationMins;
    // ensure at least 0
    if (actDuration < 0) actDuration = 0;

    int finalKarma = karmaPoints != -1
        ? karmaPoints
        : (_config?.karmaPoints ?? 0);

    // Construct Request
    SpiritualSessionRequest request = SpiritualSessionRequest(
      type: _config?.type ?? "chanting",
      title: _config?.title ?? "Meditation Session",
      targetDuration: durationMins,
      actualDuration: actDuration,
      chantingName: _config?.title ?? "Meditation",
      chantCount: 108,
      karmaPoints: finalKarma,
      emotion: _config?.emotion ?? "neutral",
      status: status,
      completionPercentage: completionPercentage,
      videoUrl: _currentVideoUrl ?? "",
      audioUrl: _currentAudioUrl ?? "",
      configurationId: _config?.sId,
    );

    // Dispatch Event
    // We need context to access BLoC.
    // Since this is called from initState->Listener, context IS available (StatefulWidget).
    if (mounted) {
      context.read<MeditationSessionBloc>().add(SaveSession(request));
    }
  }

  void _showCompletionDialog(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    int earnedKarma = 0;
    if (response['data'] != null && response['data'] is Map) {
      earnedKarma =
          response['data']['karmaPoints'] ??
          response['data']['karma_points'] ??
          0;
    } else if (response['karmaPoints'] != null) {
      earnedKarma = response['karmaPoints'];
    }

    // Fallback: If 0 found in response, show the configured/requested points
    if (earnedKarma == 0) {
      earnedKarma = _config?.karmaPoints ?? 60;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: const Color(0xFF18151B), // Premium Dark
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 12.w,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "Session Completed!",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700), // Gold
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                "You have successfully completed a meditation session.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp, 
                  color: Colors.white.withOpacity(0.7)
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 1.5.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: const Color(0xFFFFD700),
                      size: 6.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "+$earnedKarma Karma Points",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Get.until(
                      (route) =>
                          route.settings.name == AppConstants.routeDashboard,
                    );
                  },
                  child: Text(
                    "GOT IT",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _entryController.dispose();
    _breathingController.dispose();
    _haloController.dispose();
    _rippleController.dispose();
    _timerController.dispose();
    if (_isVideoInitialized) {
      _videoController.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }


  void _toggleMeditation() {
    final isPrayer = (_config?.type == 'prayer') || (_config?.prayerType != null);
    
    // Near-instant interaction: No awaits here!
    if (!_isStarted) {
      setState(() {
        _isStarted = true;
        _isPlaying = true;
      });
      
      if (!isPrayer || _audioStartedPlaying) {
        _timerController.forward();
      }
      _breathingController.repeat(reverse: true);
      _rippleController.repeat();

      if (_isAudioReady) {
        _audioPlayer.play();
      } else {
        debugPrint("⏳ Still buffering audio, will play once ready...");
      }
      
      if (_isVideoInitialized && !_videoController.value.isPlaying) {
        _videoController.play();
      }
    } else if (_isPlaying) {
      setState(() => _isPlaying = false);
      _timerController.stop();
      _breathingController.stop();
      _rippleController.stop();
      _audioPlayer.pause();
      if (_isVideoInitialized) _videoController.pause();
    } else {
      setState(() => _isPlaying = true);
      if (!isPrayer || _audioStartedPlaying) {
        _timerController.forward();
      }
      _breathingController.repeat(reverse: true);
      _rippleController.repeat();
      _audioPlayer.play();
      if (_isVideoInitialized) _videoController.play();
    }
  }


  void _handleBackNavigation() {
    bool wasPlaying = _isPlaying;
    if (wasPlaying) {
      _toggleMeditation(); // Pause if currently playing
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF18151B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Exit Session?",
          style: GoogleFonts.lora(
            color: const Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        content: Text(
          "Are you sure you want to exit?\nYou will receive 0 Karma points.",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 11.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (wasPlaying) {
                _toggleMeditation(); // Resume only if it was playing
              }
            },
            child: Text(
              "CONTINUE",
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation dialog

              // Calculate partial stats
              double elapsedSeconds =
                  _timerController.value *
                  _timerController.duration!.inSeconds.toDouble();
              int actualSec = elapsedSeconds.toInt();
              int percent = ((elapsedSeconds / _totalDuration) * 100)
                  .toInt()
                  .clamp(0, 100);

              _isManualExit = true;

              // Save as incomplete with 0 karma
              _triggerSaveSession(
                status: "incomplete",
                karmaPoints: 0,
                actualDurationSeconds: actualSec,
                completionPercentage: percent,
              );

              // Show Incomplete Dialog instead of direct exit
              _showIncompleteDialog(context, percent);
            },
            child: Text(
              "EXIT",
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncompleteDialog(BuildContext context, int percentage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: const Color(0xFF18151B), // Premium Dark
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Icon
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                  size: 10.w,
                ),
              ),
              SizedBox(height: 2.5.h),

              Text(
                "Incomplete",
                style: GoogleFonts.lora(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700), // Gold
                ),
              ),
              SizedBox(height: 2.h),

              // Warning + Percent
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Text(
                      "Session partially completed\n($percentage%)",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              Text(
                "+0 Karma Points",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9B44), // Orange
                ),
              ),
              SizedBox(height: 4.h),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF423B36), // Muted brown/grey
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Pill shape
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Get.until(
                      (route) =>
                          route.settings.name == AppConstants.routeDashboard,
                    );
                  },
                  child: Text(
                    "DONE",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<MeditationSessionBloc, MeditationSessionState>(
      listener: (context, state) {
        if (state is SessionSaved) {
          // Only show completion dialog if NOT manually exited (i.e. timer finished)
          if (!_isManualExit) {
            _showCompletionDialog(context, state.response);
          }
        }
        if (state is SessionError) {
          Utils.showToast(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            /// 🌌 Parallax Breathing Background or Video
            Positioned.fill(
              child: _isVideoInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _bgScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _bgScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/medi_bg.png', // Fallback
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            /// 🌌 Celestial Aurora Glow (Animated Mesh Glow)
            const Positioned.fill(child: _AuroraGlow()),

            /// ✨ Magic Particles
            for (int i = 0; i < 25; i++) _MagicParticle(index: i),

            /// ✖️ Top Controls
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Song Selection (Hidden as per request)
                  /*
                  GestureDetector(
                    onTap: () => setState(
                      () => _showSongSelection = !_showSongSelection,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.music_note,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tracks[_selectedTrack],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  */
                  const SizedBox(), // Spacer placeholder if needed or just empty
                  _CloseButton(onPressed: _handleBackNavigation),
                ],
              ),
            ),

            /// 🌠 DIVINE CENTER (Halo + Image + Breathing)
            Align(
              alignment: const Alignment(0, -0.25),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// 1. The Divine Halo (Rotating)
                  RotationTransition(
                    turns: _haloController,
                    child: Container(
                      width: size.width * 0.9,
                      height: size.width * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.amber.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  /// 2. Zen Ripples (Only when playing)
                  if (_isPlaying)
                    for (int i = 0; i < 3; i++)
                      _ZenRipple(controller: _rippleController, index: i),

                  /// 3. The Main Avatar (Breathing & Switching)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 1600),
                          switchInCurve: const _SafeCurve(Curves.elasticInOut),
                          switchOutCurve: const _SafeCurve(Curves.easeIn),
                          transitionBuilder: (child, animation) {
                            if ((child.key as ValueKey).value == true) {
                              animation.addStatusListener((status) {
                                if (status == AnimationStatus.completed &&
                                    !showPlayUI) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted && !_isDisposed) {
                                      setState(() => showPlayUI = true);
                                    }
                                  });
                                }
                              });
                              return ScaleTransition(
                                scale: Tween<double>(begin: 0.5, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: const _SafeCurve(
                                          Curves.elasticOut,
                                        ),
                                      ),
                                    ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            }
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          // Replaced Image.asset with SizedBox as per request to hide images but keep logic
                          child: SizedBox.shrink(key: ValueKey(showPlayImage)),
                        ),
                      ),
                    ),
                  ),
 
                   /// 4. PRELOADING OVERLAY (Glassmorphism)
                   if (!_isMediaReady)
                     Positioned.fill(
                       child: Container(
                         color: Colors.black.withOpacity(0.4),
                         child: Center(
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               const CircularProgressIndicator(
                                 color: Color(0xFFFFD700),
                                 strokeWidth: 2,
                               ),
                               const SizedBox(height: 20),
                               Text(
                                 "PREPARING DIVINE SOUNDS...",
                                 style: GoogleFonts.poppins(
                                   color: Colors.white,
                                   fontSize: 10.sp,
                                   letterSpacing: 2,
                                   fontWeight: FontWeight.w300,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                 ],
               ),
             ),

            /// 🔘 ELEGANT CONTROLS
            _BottomControls(
              isVisible: showPlayUI,
              isStarted: _isStarted,
              isPlaying: _isPlaying,
              audioStartedPlaying: _audioStartedPlaying,
              onToggle: _toggleMeditation,
              timerController: _timerController,
              totalDuration: _totalDuration,
              isPrayer: (_config?.type == 'prayer') || (_config?.prayerType != null),
              isFetchingDuration: _isFetchingDuration,
              isMediaReady: _isMediaReady,
            ),

            /// 🎵 SONG SELECTION GRID
            /*
            if (_showSongSelection)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showSongSelection = false),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          color: Colors.black.withOpacity(0.6 * value),
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: 0.9 + (0.1 * value),
                            child: GestureDetector(
                              onTap: () {}, // Prevent tap through
                              child: Container(
                                width: size.width * 0.85,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900]?.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white12,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(width: 24),
                                        const Text(
                                          "SELECT MUSIC",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => setState(
                                            () => _showSongSelection = false,
                                          ),
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white54,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 1.8,
                                          ),
                                      itemCount: _tracks.length,
                                      itemBuilder: (context, index) {
                                        bool isSelected =
                                            _selectedTrack == index;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedTrack = index;
                                              _showSongSelection = false;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white10
                                                  : Colors.white.withOpacity(
                                                      0.04,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.amber.withOpacity(
                                                        0.5,
                                                      )
                                                    : Colors.white12,
                                                width: isSelected ? 2 : 1.2,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.amber
                                                            .withOpacity(0.15),
                                                        blurRadius: 15,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              _tracks[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.amber[200]
                                                    : Colors.white.withOpacity(
                                                        0.8,
                                                      ),
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            */
          ],
        ),
      ),
    );
  }
}

/// --- SUPPORTING WIDGETS ---

class _ZenRipple extends StatelessWidget {
  final AnimationController controller;
  final int index;
  const _ZenRipple({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double progress = (controller.value + (index * 0.33)) % 1.0;
        double opacity = (1.0 - progress).clamp(0.0, 1.0);
        double sizeFactor = 1.0 + (progress * 1.8);

        return Container(
          width: 220 * sizeFactor,
          height: 220 * sizeFactor,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(opacity * 0.3),
              width: 1.2,
            ),
          ),
        );
      },
    );
  }
}

class _AuroraGlow extends StatefulWidget {
  const _AuroraGlow();
  @override
  State<_AuroraGlow> createState() => _AuroraGlowState();
}

class _AuroraGlowState extends State<_AuroraGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.3 * math.sin(_controller.value * 2 * math.pi),
                -0.3 * math.cos(_controller.value * 2 * math.pi),
              ),
              colors: [
                const Color(0xFF6A1B9A).withOpacity(0.1),
                const Color(0xFF1A237E).withOpacity(0.0),
              ],
              radius: 1.5,
            ),
          ),
        );
      },
    );
  }
}

class _MagicParticle extends StatefulWidget {
  final int index;
  const _MagicParticle({required this.index});
  @override
  State<_MagicParticle> createState() => _MagicParticleState();
}

class _MagicParticleState extends State<_MagicParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double x, y, size;
  late Color color;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    x = r.nextDouble();
    y = r.nextDouble();
    size = r.nextDouble() * 4 + 1;
    color = r.nextBool() ? Colors.white : Colors.amber.withOpacity(0.5);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8 + r.nextInt(10)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              MediaQuery.of(context).size.height *
                  (0.1 * math.sin(_controller.value * math.pi)),
            ),
            child: Opacity(
              opacity: 0.1 + (0.4 * _controller.value),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CloseButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black38,
          border: Border.all(color: Colors.white12),
        ),
        child: const Icon(Icons.close, color: Colors.white70, size: 24),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final bool isVisible;
  final bool isStarted;
  final bool isPlaying;
  final bool audioStartedPlaying;
  final VoidCallback onToggle;
  final AnimationController timerController;
  final int totalDuration;
  final bool isPrayer;
  final bool isFetchingDuration;

  const _BottomControls({
    required this.isVisible,
    required this.isStarted,
    required this.isPlaying,
    required this.audioStartedPlaying,
    required this.onToggle,
    required this.timerController,
    required this.totalDuration,
    this.isPrayer = false,
    this.isFetchingDuration = false,
    required this.isMediaReady, // Added
  });

  final bool isMediaReady; // Added

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 1200),
      curve: const _SafeCurve(Curves.easeOutExpo),
      bottom: isVisible ? 80 : -300,
      left: 30,
      right: 30,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: isVisible ? 1.0 : 0.0,
        child: Column(
          children: [
            Text(
              !isMediaReady
                  ? "PREPARING ..."
                  : !isStarted
                      ? (isPrayer ? "READY FOR PRAYER" : "READY TO MEDITATE")
                      : isPlaying
                          ? (isPrayer
                              ? (!audioStartedPlaying
                                  ? "GET READY FOR PRAYER"
                                  : "PRAYER IN PROGRESS")
                              : "INHALE ... EXHALE")
                          : "PAUSED",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 35),
            GestureDetector(
              onTap: isMediaReady ? onToggle : null,
              child: _PlayButton(
                isPlaying: isPlaying,
                isStarted: isStarted,
                isReady: isMediaReady,
              ),
            ),
            const SizedBox(height: 45),
            _ZenTimer(
              timerController: timerController,
              totalDuration: totalDuration,
              isFetchingDuration: isFetchingDuration,
              audioStartedPlaying: audioStartedPlaying,
              isPrayer: isPrayer,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isStarted;
  final bool isReady;
  const _PlayButton({
    required this.isPlaying,
    required this.isStarted,
    required this.isReady,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: !isReady
          ? const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2,
                ),
              ),
            )
          : Icon(
              !isStarted || !isPlaying
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              color: Colors.white,
              size: 45,
            ),
    );
  }
}


class _ZenTimer extends StatelessWidget {
  final AnimationController timerController;
  final int totalDuration;
  final bool isFetchingDuration;
  final bool audioStartedPlaying;
  final bool isPrayer;

  const _ZenTimer({
    required this.timerController,
    required this.totalDuration,
    this.isFetchingDuration = false,
    this.audioStartedPlaying = true,
    this.isPrayer = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: timerController,
      builder: (context, child) {
        int rem =
            totalDuration - (timerController.value * totalDuration).round();
        String time =
            "${(rem ~/ 60).toString().padLeft(2, '0')}:${(rem % 60).toString().padLeft(2, '0')}";
        bool showLoading = isFetchingDuration || (isPrayer && !audioStartedPlaying);
        return Column(
          children: [
            Text(
              showLoading ? "Loading Divine Sounds..." : time,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: showLoading ? 16 : 24,
                fontWeight: showLoading ? FontWeight.w400 : FontWeight.w200,
                letterSpacing: showLoading ? 2 : 6,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timerController.value,
                minHeight: 2,
                backgroundColor: Colors.white10,
                color: Colors.white60,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SafeCurve extends Curve {
  final Curve curve;
  const _SafeCurve(this.curve);
  @override
  double transform(double t) => curve.transform(t.clamp(0.0, 1.0));
}
