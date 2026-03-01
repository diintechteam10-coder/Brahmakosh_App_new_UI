import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../common/colors.dart';
import 'swapna_list_tab.dart';
import 'dream_requests_tab.dart';
import '../../notifications/views/notification_screen.dart';

class SwapnaDecoderScreen extends StatefulWidget {
  const SwapnaDecoderScreen({super.key});

  @override
  State<SwapnaDecoderScreen> createState() => _SwapnaDecoderScreenState();
}

class _SwapnaDecoderScreenState extends State<SwapnaDecoderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightPinkColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Swapna Decoder",
              style: GoogleFonts.lora(
                fontSize: 22,
                color: const Color(0xff4E342E),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Decode your dreams ✨",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xff8D6E63),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
            onPressed: () => Get.back(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xff5D4037),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xffFEDA87).withOpacity(0.3),
                  const Color(0xffF4E9E0).withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xffFEDA87).withOpacity(0.5),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xffFEDA87), Color(0xffF4C430)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffFEDA87).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xff4E342E),
              unselectedLabelColor: const Color(0xff8D6E63),
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: "SEARCH DREAMS"),
                Tab(text: "MY REQUESTS"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [const SwapnaListTab(), const DreamRequestsTab()],
            ),
          ),
        ],
      ),
    );
  }
}
