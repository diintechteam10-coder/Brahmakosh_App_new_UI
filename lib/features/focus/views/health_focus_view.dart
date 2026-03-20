import 'package:brahmakosh/core/common_imports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';

class HealthFocusView extends StatelessWidget {
  const HealthFocusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0), // Soft Red Tint
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuoteCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Daily Health Rituals'),
              const SizedBox(height: 12),
              _buildChecklist(),
              const SizedBox(height: 20),
              _buildSectionTitle('Wellness Tips'),
              const SizedBox(height: 12),
              _buildTipsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Health & Vitality',
        style: GoogleFonts.lora(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: Color(0xffFF6B6B), size: 40),
          const SizedBox(height: 12),
          Text(
            '"The body is your temple. Keep it pure and clean for the soul to reside in."',
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildChecklist() {
    final items = [
      'Drink 8 glasses of water',
      '30 mins of Yoga/Exercise',
      'Eat fresh fruits',
      '10 mins Meditation',
    ];
    return Column(
      children: items.map((item) => _ChecklistItem(label: item)).toList(),
    );
  }

  Widget _buildTipsGrid() {
    final tips = [
      {'icon': Icons.nights_stay, 'label': 'Sleep Well', 'bg': Colors.indigo.shade50},
      {'icon': Icons.restaurant, 'label': 'Eat Clean', 'bg': Colors.green.shade50},
      {'icon': Icons.self_improvement, 'label': 'Stress Less', 'bg': Colors.purple.shade50},
      {'icon': Icons.directions_run, 'label': 'Move More', 'bg': Colors.orange.shade50},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Container(
          decoration: BoxDecoration(
            color: tip['bg'] as Color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tip['icon'] as IconData, color: AppTheme.textPrimary.withOpacity(0.7)),
              const SizedBox(height: 8),
              Text(
                tip['label'] as String,
                style: GoogleFonts.lora(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String label;
  const _ChecklistItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.lora(fontSize: 14)),
        ],
      ),
    );
  }
}

