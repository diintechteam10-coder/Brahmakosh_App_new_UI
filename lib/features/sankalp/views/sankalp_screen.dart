import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/colors.dart';
import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../repositories/sankalp_repository.dart';
import 'my_sankalp_tab.dart';
import 'completed_sankalp_tab.dart';
import '../../notifications/views/notification_screen.dart';

class SankalpScreen extends StatefulWidget {
  const SankalpScreen({super.key});

  @override
  State<SankalpScreen> createState() => _SankalpScreenState();
}

class _SankalpScreenState extends State<SankalpScreen>
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
    return BlocProvider(
      create: (context) =>
          SankalpBloc(repository: SankalpRepository())
            ..add(FetchUserSankalps()),
      child: Scaffold(
        backgroundColor: CustomColors.lightPinkColor,
        appBar: AppBar(
          title: Text(
            "My Sankalp",
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
            // Custom Tab Bar Container
            Container(
              height: 40, // Reduced height
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.3,
                ), // Lighter background for tab container
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xffFEDA87),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent, // Remove underline
                labelColor: const Color(0xff5D4037),
                unselectedLabelColor: const Color(
                  0xff8D6E63,
                ), // Darker grey for visibility
                labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Reduced font size
                ),
                tabs: const [
                  Tab(text: "MY SANKALP"),
                  Tab(text: "COMPLETED"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [const MySankalpTab(), const CompletedSankalpTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
