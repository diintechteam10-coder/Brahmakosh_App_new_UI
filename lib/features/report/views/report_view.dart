import '../../../../core/common_imports.dart';
import '../../dashboard/viewmodels/dashboard_viewmodel.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to Home tab (index 0)
            Provider.of<DashboardViewModel>(
              context,
              listen: false,
            ).changeTab(0);
          },
        ),
        title: Text(
          'My Kosh',
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const _MyKoshSection(),
          const SizedBox(height: 24),
          Text(
            'Available Reports',
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGold,
            ),
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Birth Chart Report',
            date: 'Generated on: 15 Jan 2024',
            icon: Icons.auto_stories,
            color: AppTheme.chakraBlue,
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Compatibility Report',
            date: 'Generated on: 10 Jan 2024',
            icon: Icons.favorite,
            color: AppTheme.chakraRed,
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Career Report',
            date: 'Generated on: 5 Jan 2024',
            icon: Icons.work,
            color: AppTheme.chakraOrange,
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Health Report',
            date: 'Generated on: 1 Jan 2024',
            icon: Icons.health_and_safety,
            color: AppTheme.chakraGreen,
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Financial Report',
            date: 'Generated on: 28 Dec 2023',
            icon: Icons.account_balance_wallet,
            color: AppTheme.chakraIndigo,
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _ActionButton(
                icon: Icons.download_rounded,
                color: AppTheme.textSecondary,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.arrow_forward_ios_rounded,
                color: AppTheme.primaryGold,
                onPressed: () {},
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPrimary ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isPrimary
                ? null
                : Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _MyKoshSection extends StatelessWidget {
  const _MyKoshSection();

  @override
  Widget build(BuildContext context) {
    // Simulate report availability
    const bool isReportAvailable = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Kundali Summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 16,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kundali Summary',
                          style: GoogleFonts.lora(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Based on your chart, you are currently in a phase of significant professional growth. The position of Jupiter suggests new opportunities.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(height: 1, thickness: 0.5, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 12),

              // 2. Download Report
              if (isReportAvailable)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      // Handle download
                    },
                    icon: Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: AppTheme.primaryGold,
                    ),
                    label: Text(
                      'Download Full Report',
                      style: GoogleFonts.lora(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      backgroundColor: AppTheme.primaryGold.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Report pending...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
