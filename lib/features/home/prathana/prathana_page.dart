import 'package:brahmakosh/core/common_imports.dart';

class PrarthanaView extends StatelessWidget {
  const PrarthanaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔝 APP BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Text(
                      "Prarthana",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Icon(Icons.favorite_border,
                        color: AppTheme.textSecondary),
                  ],
                ),
              ),

              /// 🔍 SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for Sharadha Stuti",
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 🌼 DAILY PRARTHANA HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "Daily Prarthana",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.notifications_none,
                            size: 18, color: AppTheme.primaryGold),
                        const SizedBox(width: 6),
                        Text(
                          "REMIND ME",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: AppTheme.primaryGold,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// ✨ SUBTEXT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Make prarthana a daily habit. Feel closer to the divine and bring calmness to your life.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 16),

              /// 📅 DAILY PRAYER LIST
              SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  children: const [
                    _DailyPrarthanaCard(
                      title: "Monday Prayer",
                      isToday: true,
                    ),
                    _DailyPrarthanaCard(title: "Tuesday Prayer"),
                    _DailyPrarthanaCard(title: "Wednesday Prayer"),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              /// 🎯 PURPOSE HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Prarthana by Purpose",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              const SizedBox(height: 16),

              /// 🧘 PURPOSE CARDS
              SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  children: const [
                    _PurposePrarthanaCard(title: "Before taking medicine"),
                    _PurposePrarthanaCard(title: "After eating"),
                    _PurposePrarthanaCard(title: "For success & victory"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _DailyPrarthanaCard extends StatelessWidget {
  final String title;
  final bool isToday;

  const _DailyPrarthanaCard({
    required this.title,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isToday)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "TODAY",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Row(
              children: const [
                Icon(Icons.volume_up, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  "Audio",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _PurposePrarthanaCard extends StatelessWidget {
  final String title;

  const _PurposePrarthanaCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.volume_up,
                    size: 16, color: AppTheme.primaryGold),
                SizedBox(width: 6),
                Text("Audio"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
