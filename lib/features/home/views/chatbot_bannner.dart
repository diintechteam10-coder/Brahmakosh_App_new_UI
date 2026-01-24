import 'package:flutter/material.dart';

class PremiumChatCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String backgroundImage;
  final List<String> messages;
  final VoidCallback onTap;

  const PremiumChatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
    required this.messages,
    required this.onTap,
  });

  @override
  State<PremiumChatCard> createState() => _PremiumChatCardState();
}

class _PremiumChatCardState extends State<PremiumChatCard> {
  // Keeping the timer logic if we ever want to revert to a ticker,
  // but for the static reference UI, it's not strictly needed.
  // We'll clean it up to focus on the static UI request.

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black, // Dark background as per reference
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content Row
            Row(
              children: [
                /// LEFT CONTENT (Text & Button)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 0, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// TITLE: "Ask Rashmi"
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Ask ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Roboto', // Default sans
                                ),
                              ),
                              TextSpan(
                                text: 'BI Rashmi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Serif', // Fallback to serif for elegance
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// SUBTITLE
                        Text(
                          "Got burning questions\non your mind?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// BUTTON: "Ask a Question"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.auto_awesome_outlined, // Sparkle icon
                                size: 16,
                                color: Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Ask a Question",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// RIGHT IMAGE (Arch Shape with Gradient)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      height: 130,
                      width: 100, // Fixed width for the arch shape
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.redAccent, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(100), // Arch top
                          bottom: Radius.circular(100), // Rounded bottom
                        ).copyWith(bottomRight: const Radius.circular(0)),
                         // Tweaked shape to look like the reference (Arch-like)
                         // Reference is Arch Top, slightly Rounded Bottom. 
                         // Let's try a pure Vertical Stadium or Arch.
                         // Actually reference is: Top Left/Right Radius 100, Bottom Left/Right Radius ~40? 
                         // Let's stick to a clean Arch: Top 100, Bottom 20.
                      ),
                      padding: const EdgeInsets.all(2), // Border width
                      child: ClipRRect(
                         borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(100),
                          bottom: Radius.circular(100), // Inner match
                        ).copyWith(bottomRight: const Radius.circular(0)),
                        child: Image.asset(
                          widget.backgroundImage,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
