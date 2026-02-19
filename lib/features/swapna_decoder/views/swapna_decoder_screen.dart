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
        title: Text(
          "Swapna Decoder",
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xff5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xff5D4037)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xffFEDA87),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xff5D4037),
              unselectedLabelColor: const Color(0xff8D6E63),
              labelStyle: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
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
