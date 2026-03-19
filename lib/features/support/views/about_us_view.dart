import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://brahmakosh.com/');
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch website');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "About Us",
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Welcome to Brahmakosh",
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Brahmakosh is your spiritual companion, bridging the gap between ancient wisdom and modern technology. Our mission is to guide you on your spiritual path through astrology, personalized guidance, and sacred practices.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Our Vision",
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "To make the esoteric knowledge of Vedic traditions accessible and practical for today's generation, fostering a deeper connection with the divine and one's true purpose.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGold.withOpacity(0.8),
                      const Color(0xffD48F37),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Want to know more?",
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Visit our website for in-depth details, blog posts, and more services.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _launchWebsite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xffD48F37),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        "Visit brahmakosh.com",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Version 1.0.0",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white38,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

