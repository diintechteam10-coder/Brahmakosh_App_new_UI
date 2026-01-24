// Common imports for entire app
// Import this file instead of importing packages individually

// Dart Core - hide conflicting names with Flutter
export 'dart:ui' hide 
    Gradient,
    decodeImageFromList,
    ImageDecoderCallback,
    StrutStyle,
    TextStyle,
    TextDecoration,
    TextDecorationStyle,
    FontWeight,
    FontStyle,
    TextLeadingDistribution,
    TextHeightBehavior,
    TextBaseline,
    TextAlign,
    TextDirection,
    Locale,
    Image;

// Flutter Core
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// State Management
export 'package:provider/provider.dart';
export 'package:get/get.dart';

// UI & Styling
export 'package:google_fonts/google_fonts.dart';
export 'package:lottie/lottie.dart';

// Routing
export 'package:go_router/go_router.dart';

// Media
export 'package:video_player/video_player.dart';

// App Core
export 'package:brahmakosh/core/theme/app_theme.dart';
export 'package:brahmakosh/core/routes/app_router.dart';
export 'package:brahmakosh/core/constants/app_constants.dart';
export 'package:brahmakosh/core/services/storage_service.dart';

