import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class StartDhyanaView extends StatelessWidget {
  const StartDhyanaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Meditations",
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppTheme.textPrimary,
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Quote
              Text(
              "Your inner engineering starts here.",
              style: GoogleFonts.lora(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // FEATURED (Isha Kriya)
            _SectionHeader(title: "Featured"),
            const SizedBox(height: 12),
            _FeaturedCard(
              title: "Isha Kriya",
              subtitle: "Power to create your life",
              duration: "12 mins",
              imageColor: const Color(0xff5D4037), // Earthy tone
              onTap: () => _openPlayer(context, "Isha Kriya", 12),
            ),

            const SizedBox(height: 32),

            // CHIT SHAKTI (Meditations for Success, etc.)
            _SectionHeader(title: "Chit Shakti (Power of Mind)"),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _SquareCard(
                    title: "Success",
                    color: const Color(0xffE67E22),
                    icon: Icons.emoji_events_outlined,
                    onTap: () =>
                        _openPlayer(context, "Meditation for Success", 20),
                  ),
                  const SizedBox(width: 16),
                  _SquareCard(
                    title: "Health",
                    color: const Color(0xff2ECC71),
                    icon: Icons.favorite_border,
                    onTap: () =>
                        _openPlayer(context, "Meditation for Health", 20),
                  ),
                  const SizedBox(width: 16),
                  _SquareCard(
                    title: "Peace",
                    color: const Color(0xff3498DB),
                    icon: Icons.spa_outlined,
                    onTap: () =>
                        _openPlayer(context, "Meditation for Peace", 20),
                  ),
                  const SizedBox(width: 16),
                  _SquareCard(
                    title: "Love",
                    color: const Color(0xffE91E63),
                    icon: Icons.favorite,
                    onTap: () =>
                        _openPlayer(context, "Meditation for Love", 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // QUICK PRACTICES
            _SectionHeader(title: "Quick Practices"),
            const SizedBox(height: 12),
            _ListTileItem(
              title: "Rashmi Presence",
              subtitle: "7 mins guided chant",
              icon: Icons.record_voice_over_outlined,
              color: Colors.purple.shade300,
              onTap: () => _openPlayer(context, "Rashmi Presence", 7),
            ),
            const SizedBox(height: 12),
            _ListTileItem(
              title: "Infinity Meditation",
              subtitle: "Experience stability & balance",
              icon: Icons.all_inclusive,
              color: Colors.teal.shade300,
              onTap: () => _openPlayer(context, "Infinity Meditation", 15),
            ),
            const SizedBox(height: 12),
            _ListTileItem(
              title: "Unguided Dhyana",
              subtitle: "Silent meditation with bell",
              icon: Icons.self_improvement,
              color: Colors.blueGrey.shade300,
              onTap: () => _openPlayer(context, "Unguided Dhyana", 15),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    ),
  );
}

  void _openPlayer(BuildContext context, String title, int duration) {
    Get.to(() => MeditationPlayerView(title: title, durationMinutes: duration));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xff2C3E50),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final Color imageColor;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imageColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: imageColor,
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: NetworkImage(
              "https://images.unsplash.com/photo-1593811167562-9cef47bfc4d7?q=80&w=2072&auto=format&fit=crop",
            ), // Placeholder, can be asset
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: imageColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_filled,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.lora(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SquareCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xff2C3E50),
              ),
            ),

            Row(
              children: [
                Text(
                  "Start",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTileItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ListTileItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff2C3E50),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_fill_rounded,
              color: AppTheme.primaryGold,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Player Stub (To be refined) ---
class MeditationPlayerView extends StatelessWidget {
  final String title;
  final int durationMinutes;

  const MeditationPlayerView({
    super.key,
    required this.title,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a1a1a),
      body: Stack(
        children: [
          // Background Image (Darkened)
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?q=80&w=2525&auto=format&fit=crop",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      const Icon(Icons.more_horiz, color: Colors.white),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Content
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.self_improvement,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "$durationMinutes:00",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Text
                Text(
                  title,
                  style: GoogleFonts.lora(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Guided by Rashmi",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 48),

                // Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 32),
                      IconButton(
                        icon: const Icon(
                          Icons.forward_10,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
