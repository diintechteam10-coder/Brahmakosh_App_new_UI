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
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: Text(
          "All Dashas",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6D3A0C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6D3A0C),
          labelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Vimshottari"),
            Tab(text: "Yogini"),
            Tab(text: "Chardasha"),
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
            _buildSectionHeader("Current Vimshottari Hierarchy"),
            const SizedBox(height: 12),
            _buildCurrentVdashaAllCard(widget.dashas.currentVdashaAll!),
            const SizedBox(height: 24),
          ],
          if (widget.dashas.vimshottariDasha != null &&
              widget.dashas.vimshottariDasha!.isNotEmpty) ...[
            _buildSectionHeader("Major Vimshottari Dasha"),
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
            _buildSectionHeader("Current Yogini Hierarchy"),
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
            _buildSectionHeader("Current Chardasha Hierarchy"),
            if (widget.dashas.currentChardasha!.dashaDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "${widget.dashas.currentChardasha!.dashaDate}",
                  style: GoogleFonts.lora(fontSize: 12, color: Colors.grey),
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
            _buildSectionHeader("Major Chardasha"),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEBE9)),
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
                  color: Color(0xFFD4A373),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: const Color(0xFF6D3A0C),
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
                color: isCurrent ? const Color(0xFFFFF3E0) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isCurrent
                    ? Border.all(
                        color: const Color(0xFFFFB74D).withOpacity(0.5),
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
                            color: Colors.orange,
                          ),
                        ),
                      Text(
                        "${item.planet}",
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isCurrent
                              ? const Color(0xFF6D3A0C)
                              : const Color(0xFF4E342E),
                        ),
                      ),
                    ],
                  ),
                  _formatDateRange(
                        "${item.start} - ${item.end}",
                        compact: true,
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
            child: Divider(color: Color(0xFFEFEBE9), thickness: 1),
          ),
      ],
    );
  }

  // --- Reused/Copied Widgets from AstrologyTabs (to avoid breaking changes there for now) ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5D4037),
        ),
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEBE9)),
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
        ? const Color(0xFF6D3A0C)
        : (level == 1 ? const Color(0xFF8D6E63) : const Color(0xFFA1887F));

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
                    border: Border.all(color: Colors.white, width: 2),
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
                      color: const Color(0xFFD7CCC8).withOpacity(0.5),
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
                            style: GoogleFonts.lora(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4E342E),
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
                            : const Color(0xFFD7CCC8),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8D6E63),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                            : const Color(0xFFD7CCC8),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEFEBE9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4E342E),
                        ),
                      ),
                      if (formattedDate != null)
                        formattedDate
                      else
                        Text(
                          item.dateRange,
                          style: GoogleFonts.lora(
                            fontSize: 12,
                            color: const Color(0xFF8D6E63),
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

  Widget? _formatDateRange(String? dateStr, {bool compact = false}) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      final parts = dateStr.split(" - ");
      if (parts.length != 2) {
        return Text(
          dateStr,
          style: GoogleFonts.lora(fontSize: 12, color: const Color(0xFF8D6E63)),
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
              style: GoogleFonts.lora(
                fontSize: 10,
                color: const Color(0xFFA1887F),
              ),
            ),
            Text(
              outFormat.format(end),
              style: GoogleFonts.lora(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6D3A0C),
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
        style: GoogleFonts.lora(fontSize: 12, color: const Color(0xFF8D6E63)),
      );
    }
  }

  Widget _buildDateChip(String label, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD7CCC8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.lora(
              fontSize: 10,
              color: const Color(0xFFA1887F),
            ),
          ),
          Text(
            date,
            style: GoogleFonts.lora(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6D3A0C),
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
