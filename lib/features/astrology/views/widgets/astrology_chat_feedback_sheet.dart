import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/astrology_chat_controller.dart';

class AstrologyChatFeedbackSheet extends StatefulWidget {
  final AstrologyChatController controller;

  const AstrologyChatFeedbackSheet({Key? key, required this.controller})
    : super(key: key);

  @override
  State<AstrologyChatFeedbackSheet> createState() =>
      _AstrologyChatFeedbackSheetState();
}

class _AstrologyChatFeedbackSheetState
    extends State<AstrologyChatFeedbackSheet> {
  double _rating = 0;
  String? _satisfaction;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              "Rate your Experience",
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "How was your conversation?",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 32),

            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 48,
                      color: index < _rating ? const Color(0xFFD4AF37) : Colors.white10,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Sentiment Chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildSentimentChip(
                  "very_unhappy",
                  "Very Unhappy",
                  Icons.sentiment_very_dissatisfied,
                ),
                _buildSentimentChip(
                  "unhappy",
                  "Unhappy",
                  Icons.sentiment_dissatisfied,
                ),
                _buildSentimentChip(
                  "neutral",
                  "Neutral",
                  Icons.sentiment_neutral,
                ),
                _buildSentimentChip(
                  "happy",
                  "Happy",
                  Icons.sentiment_satisfied,
                ),
                _buildSentimentChip(
                  "very_happy",
                  "Very Happy",
                  Icons.sentiment_very_satisfied,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Comment Field
            TextField(
              controller: _commentController,
              style: GoogleFonts.poppins(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add a comment (optional)",
                hintStyle: GoogleFonts.poppins(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_rating > 0 && _satisfaction != null)
                    ? () {
                        widget.controller.submitFeedback(
                          rating: _rating,
                          comment: _commentController.text.trim(),
                          satisfaction: _satisfaction!,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.white10,
                  disabledForegroundColor: Colors.white24,
                ),
                child: Text(
                  "Submit Review",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentChip(String apiKey, String label, IconData icon) {
    final isSelected = _satisfaction == apiKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _satisfaction = apiKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.1) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white10,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

