import 'package:brahmakosh/core/common_imports.dart';
import 'dart:async';
import 'package:brahmakosh/features/check_in/blocs/spiritual_stats/spiritual_stats_bloc.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_stats_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:brahmakosh/common/widgets/custom_profile_avatar.dart';
import 'package:intl/intl.dart';

class SpiritualStatsScreen extends StatelessWidget {
  const SpiritualStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              SpiritualStatsBloc(repository: SpiritualRepository())
                ..add(LoadSpiritualStats()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel()..fetchProfile(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.black, // Dark Theme Background
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.black, // Dark Theme Background
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            'MY CHECK-IN',
            style: GoogleFonts.lora(
              color: const Color(0xFFD4AF37), // Primary Gold
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<SpiritualStatsBloc, SpiritualStatsState>(
            builder: (context, state) {
              if (state is SpiritualStatsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                );
              } else if (state is SpiritualStatsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.lora(color: Colors.red),
                  ),
                );
              } else if (state is SpiritualStatsLoaded) {
                return _buildContent(context, state.data);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }

  Widget _buildContent(BuildContext context, SpiritualStatsData data) {
    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        onRefresh: () async {
          final completer = Completer<void>();
          context.read<SpiritualStatsBloc>().add(
            RefreshSpiritualStats(completer),
          );
          return completer.future;
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(data.userDetails),
              const SizedBox(height: 24),
              if (data.totalStats != null)
                _buildTotalStatsGrid(data.totalStats!),
              const SizedBox(height: 32),
              if (data.categoryStats != null) ...[
                Text(
                  'ACTIVITY BREAKDOWN',
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoryChart(data.categoryStats!),
                const SizedBox(height: 32),
              ],
              if (data.recentActivities != null &&
                  data.recentActivities!.isNotEmpty) ...[
                Text(
                  'RECENT HISTORY',
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentActivityList(data.recentActivities!),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserDetails? user) {
    if (user == null) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Consumer<ProfileViewModel>(
            builder: (context, profileVM, child) {
              final profileImageUrl =
                  profileVM.profile?.profile?.profileImage ??
                  profileVM.profile?.profileImageUrl;

              return CustomProfileAvatar(
                imageUrl: profileImageUrl,
                radius: 30,
                backgroundColor: const Color(0xFF1C1C1E),
                borderColor: Colors.transparent,
                borderWidth: 0,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name ?? 'Seeker',
                style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (user.email != null)
                Text(
                  user.email!,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalStatsGrid(TotalStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sessions',
                '${stats.sessions ?? 0}',
                Icons.spa,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Karma Points',
                '${stats.karmaPoints ?? 0}',
                Icons.star,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Minutes Spent',
                '${stats.minutes ?? 0}',
                Icons.timer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Avg Completion',
                '${stats.averageCompletion ?? 0}%',
                Icons.pie_chart,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark grey background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2), // Subtle gold border
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? const Color(0xFFD4AF37), size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(CategoryStats stats) {
    // Prepare data for Pie Chart
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'Chanting',
        'value': stats.chanting?.sessions ?? 0,
        'color': const Color(0xffFFB74D),
      },
      {
        'name': 'Prayer',
        'value': stats.prayer?.sessions ?? 0,
        'color': const Color(0xff64B5F6),
      },
      {
        'name': 'Meditation',
        'value': stats.meditation?.sessions ?? 0,
        'color': const Color(0xff81C784),
      },
      {
        'name': 'Silence',
        'value': stats.silence?.sessions ?? 0,
        'color': const Color(0xffBA68C8),
      },
    ].where((e) => (e['value'] as int) > 0).toList();

    if (categories.isEmpty) {
      return Center(
        child: Text(
          "No category data available yet.",
          style: GoogleFonts.lora(color: Colors.white54),
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: categories.map((cat) {
                  return PieChartSectionData(
                    color: cat['color'],
                    value: (cat['value'] as int).toDouble(),
                    title: '${cat['value']}',
                    radius: 50,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cat['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(List<RecentActivity> activities) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              _getActivityIcon(activity.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title ?? 'Unknown Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(activity.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (activity.karmaPoints != null && activity.karmaPoints! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${activity.karmaPoints} Karma',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    activity.status == 'completed' ? 'Completed' : 'Incomplete',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: activity.status == 'completed'
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getActivityIcon(String? type) {
    IconData icon;
    Color color;
    switch (type?.toLowerCase()) {
      case 'chanting':
        icon = Icons.music_note;
        color = const Color(0xffFFB74D);
        break;
      case 'prayer':
        icon = Icons.volunteer_activism;
        color = const Color(0xff64B5F6);
        break;
      case 'meditation':
        icon = Icons.self_improvement;
        color = const Color(0xff81C784);
        break;
      case 'silence':
        icon = Icons.do_not_disturb_on;
        color = const Color(0xffBA68C8);
        break;
      default:
        icon = Icons.spa;
        color = const Color(0xff9E9E9E);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (e) {
      return "";
    }
  }
}
