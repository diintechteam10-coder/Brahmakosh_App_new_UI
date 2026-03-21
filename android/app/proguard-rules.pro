# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# WebRTC rules
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep class org.webrtc.** { *; }
-keep interface org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Record plugin rules
-keep class com.llfbandit.record.** { *; }

# Audioplayers rules
-keep class xyz.luan.audioplayers.** { *; }

# WebSocket/OkHttp rules
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# JSON/Serialization rules
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Google Play Core / Split Install rules (fixes R8 missing class errors)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.**
-keep class com.google.android.play.core.** { *; }
