# Voice Chat Latency Optimization Report

I have applied optimizations to the Flutter side of the voice chat to reduce artificial delays before audio is sent and processed.

## Changes Made:
- **Audio Chunking Interval:** Reduced from **150ms** to **100ms**. As you speak, the app now streams your voice to the server in smaller, faster increments, allowing the server's Speech-to-Text engine to process it with less artificial delay.
- **Stop Recording Delay:** Reduced from **300ms** to **100ms**. Previously, when you stopped speaking, the app intentionally waited nearly a third of a second before telling the server you were done. This has been cut down drastically.

## Impact:
- **Total Flutter-Side Latency Reduction:** You should notice that the AI begins responding approximately **250ms (a quarter of a second) faster** than before.
- **Server Side Note:** The remaining latency after these changes is due to the server processing the audio (Deepgram STT -> LLM Text Generation -> ElevenLabs TTS). To reduce this further, optimizations would need to be made on the backend (e.g., using streaming for the LLM and TTS instead of processing the entire block at once).

I have intentionally kept the file-based audio player for now as streaming bytes directly in Flutter can be unstable and might break the `audioplayers` package integration currently in use. The I/O latency from writing tiny MP3 chunks is typically only 5-15ms, which is negligible compared to the network and backend processing time.
