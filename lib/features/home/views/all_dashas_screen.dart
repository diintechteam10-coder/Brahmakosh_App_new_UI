import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class AllDashasScreen extends StatefulWidget {
  final Dashas dashas;

  const AllDashasScreen({super.key, required this.dashas});

  @override
  State<AllDashasScreen> createState() => _AllDashasScreenState();
}

class _AllDashasScreenState extends State<AllDashasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _sectionLine = Color(0xFF1E1E4D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text(
          "All Dashas",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        backgroundColor: _bgDark,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: _cardDark,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _accentGold,
          unselectedLabelColor: _textSecondary,
          indicatorColor: _accentGold,
          dividerColor: _sectionLine,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: "VIMSHOTTARI"),
            Tab(text: "YOGINI"),
            Tab(text: "CHARDASHA"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVimshottariTab(),
          _buildYoginiTab(),
          _buildChardashaTab(),
        ],
      ),
    );
  }

  Widget _buildVimshottariTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.dashas.currentVdashaAll != null) ...[
            _buildSectionHeader("CURRENT VIMSHOTTARI HIERARCHY"),
            const SizedBox(height: 12),
            _buildCurrentVdashaAllCard(widget.dashas.currentVdashaAll!),
            const SizedBox(height: 24),
          ],
          if (widget.dashas.vimshottariDasha != null &&
              widget.dashas.vimshottariDasha!.isNotEmpty) ...[
            _buildSectionHeader("MAJOR VIMSHOTTARI DASHA"),
            const SizedBox(height: 12),
            _buildDashaTimelineList(
              items: widget.dashas.vimshottariDasha!.map((e) {
                return _TimelineItemData(
                  title: e.planet ?? "",
                  dateRange: "${e.start} - ${e.end}",
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildYoginiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.dashas.currentYogini != null) ...[
            _buildSectionHeader("CURRENT YOGINI HIERARCHY"),
            const SizedBox(height: 12),
            _buildCurrentHierarchyCard(
              majorTitle: "Major",
              majorName: widget.dashas.currentYogini!.majorDasha?.dashaName,
              majorDate:
                  "${widget.dashas.currentYogini!.majorDasha?.startDate} - ${widget.dashas.currentYogini!.majorDasha?.endDate}",
              subTitle: "Sub",
              subName: widget.dashas.currentYogini!.subDasha?.dashaName,
              subDate:
                  "${widget.dashas.currentYogini!.subDasha?.startDate} - ${widget.dashas.currentYogini!.subDasha?.endDate}",
              subSubTitle: "Sub-Sub",
              subSubName: widget.dashas.currentYogini!.subSubDasha?.dashaName,
              subSubDate:
                  "${widget.dashas.currentYogini!.subSubDasha?.startDate} - ${widget.dashas.currentYogini!.subSubDasha?.endDate}",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChardashaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.dashas.currentChardasha != null) ...[
            _buildSectionHeader("CURRENT CHARDASHA HIERARCHY"),
            if (widget.dashas.currentChardasha!.dashaDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "${widget.dashas.currentChardasha!.dashaDate}",
                  style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
                ),
              ),
            const SizedBox(height: 12),
            _buildCurrentHierarchyCard(
              majorTitle: "Major",
              majorName: widget.dashas.currentChardasha!.majorDasha?.signName,
              majorDate:
                  "${widget.dashas.currentChardasha!.majorDasha?.startDate} - ${widget.dashas.currentChardasha!.majorDasha?.endDate}",
              subTitle: "Sub",
              subName: widget.dashas.currentChardasha!.subDasha?.signName,
              subDate:
                  "${widget.dashas.currentChardasha!.subDasha?.startDate} - ${widget.dashas.currentChardasha!.subDasha?.endDate}",
              subSubTitle: "Sub-Sub",
              subSubName: widget.dashas.currentChardasha!.subSubDasha?.signName,
              subSubDate:
                  "${widget.dashas.currentChardasha!.subSubDasha?.startDate} - ${widget.dashas.currentChardasha!.subSubDasha?.endDate}",
            ),
            const SizedBox(height: 24),
          ],
          if (widget.dashas.majorChardasha != null &&
              widget.dashas.majorChardasha!.isNotEmpty) ...[
            _buildSectionHeader("MAJOR CHARDASHA"),
            const SizedBox(height: 12),
            _buildDashaTimelineList(
              items: widget.dashas.majorChardasha!.map((e) {
                return _TimelineItemData(
                  title: e.signName ?? "",
                  dateRange: "${e.startDate} - ${e.endDate}",
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentVdashaAllCard(CurrentVdashaAll data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          _buildVdashaLevelRow(0, "Major", data.major),
          _buildVdashaLevelRow(1, "Minor", data.minor),
          _buildVdashaLevelRow(2, "Sub-Minor", data.subMinor),
          _buildVdashaLevelRow(3, "Sub-Sub-Minor", data.subSubMinor),
          _buildVdashaLevelRow(
            4,
            "Sub-Sub-Sub-Minor",
            data.subSubSubMinor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVdashaLevelRow(
    int level,
    String label,
    VdashaLevel? levelData, {
    bool isLast = false,
  }) {
    if (levelData == null ||
        levelData.dashaPeriod == null ||
        levelData.dashaPeriod!.isEmpty)
      return const SizedBox.shrink();

    // Find the current active dasha for this level to highlight it
    VDashaPeriod? current;
    if (widget.dashas.currentVdasha != null) {
      if (level == 0)
        current = widget.dashas.currentVdasha!.major;
      else if (level == 1)
        current = widget.dashas.currentVdasha!.minor;
      else if (level == 2)
        current = widget.dashas.currentVdasha!.subMinor;
      else if (level == 3)
        current = widget.dashas.currentVdasha!.subSubMinor;
      else if (level == 4)
        current = widget.dashas.currentVdasha!.subSubSubMinor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _accentGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _accentGold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: levelData.dashaPeriod!.length,
          itemBuilder: (context, index) {
            final item = levelData.dashaPeriod![index];
            final bool isCurrent =
                current != null &&
                item.planet == current.planet &&
                item.start == current.start;

            return Container(
              margin: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: isCurrent ? _accentGold.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isCurrent
                    ? Border.all(
                        color: _accentGold.withOpacity(0.5),
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isCurrent)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.stars,
                            size: 16,
                            color: _accentGold,
                          ),
                        ),
                      Text(
                        "${item.planet}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                  _formatDateRange(
                        "${item.start} - ${item.end}",
                        compact: true,
                        isCurrent: isCurrent,
                      ) ??
                      const SizedBox(),
                ],
              ),
            );
          },
        ),
        if (!isLast)
          const Padding(
             padding: EdgeInsets.symmetric(vertical: 8.0),
             child: Divider(color: _sectionLine, thickness: 1),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: _sectionLine,
        ),
      ],
    );
  }

  Widget _buildCurrentHierarchyCard({
    String? majorTitle,
    String? majorName,
    String? majorDate,
    String? subTitle,
    String? subName,
    String? subDate,
    String? subSubTitle,
    String? subSubName,
    String? subSubDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          if (majorName != null)
            _buildHierarchyRow(
              level: 0,
              label: majorTitle ?? "Major",
              value: majorName,
              date: majorDate,
              isLast: subName == null,
            ),
          if (subName != null)
            _buildHierarchyRow(
              level: 1,
              label: subTitle ?? "Sub",
              value: subName,
              date: subDate,
              isLast: subSubName == null,
            ),
          if (subSubName != null)
            _buildHierarchyRow(
              level: 2,
              label: subSubTitle ?? "Sub-Sub",
              value: subSubName,
              date: subSubDate,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildHierarchyRow({
    required int level,
    required String label,
    required String value,
    String? date,
    required bool isLast,
  }) {
    final double indent = level * 24.0;
    final Color dotColor = level == 0
        ? _accentGold
        : (level == 1 ? _accentGold.withOpacity(0.8) : _accentGold.withOpacity(0.6));

    final formattedDate = _formatDateRange(date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: _cardDark, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _sectionLine,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: indent, bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _textSecondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (formattedDate != null) ...[
                    const SizedBox(height: 6),
                    formattedDate,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashaTimelineList({required List<_TimelineItemData> items}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFirst = index == 0;
        final isLast = index == items.length - 1;
        final formattedDate = _formatDateRange(item.dateRange, compact: true);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isFirst
                            ? Colors.transparent
                            : _sectionLine,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _accentGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bgDark, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _accentGold.withOpacity(0.3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isLast
                            ? Colors.transparent
                            : _sectionLine,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      if (formattedDate != null)
                        formattedDate
                      else
                        Text(
                          item.dateRange,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _formatDateRange(String? dateStr, {bool compact = false, bool isCurrent = false}) {
    if (dateStr == null || dateStr.isEmpty) return null;

    final Color textColor = isCurrent ? _accentGold : _textSecondary;

    try {
      final parts = dateStr.split(" - ");
      if (parts.length != 2) {
        return Text(
          dateStr,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: textColor,
          ),
        );
      }

      final startStr = parts[0].trim();
      final endStr = parts[1].trim();

      DateTime start;
      DateTime end;
      DateFormat outFormat;

      try {
        final formatWithTime = DateFormat("d-M-yyyy H:m");
        start = formatWithTime.parse(startStr);
        end = formatWithTime.parse(endStr);
        outFormat = DateFormat("d MMM yyyy, h:mm a");
      } catch (_) {
        final formatDateOnly = DateFormat("d-M-yyyy");
        start = formatDateOnly.parse(startStr);
        end = formatDateOnly.parse(endStr);
        outFormat = DateFormat("d MMM yyyy");
      }

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${outFormat.format(start)} -",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: textColor,
              ),
            ),
            Text(
              outFormat.format(end),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isCurrent ? _accentGold : _textPrimary,
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateChip("Start", outFormat.format(start)),
          const SizedBox(height: 4),
          _buildDateChip("End", outFormat.format(end)),
        ],
      );
    } catch (e) {
      return Text(
        dateStr,
        style: GoogleFonts.poppins(fontSize: 12, color: textColor),
      );
    }
  }

  Widget _buildDateChip(String label, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _bgDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
          Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItemData {
  final String title;
  final String dateRange;

  _TimelineItemData({required this.title, required this.dateRange});
}
