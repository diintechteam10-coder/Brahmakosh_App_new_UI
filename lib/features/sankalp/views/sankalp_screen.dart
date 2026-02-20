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
            style: GoogleFonts.lora(
              fontSize: 22,
              color: const Color(0xff4E342E),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037), size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xff5D4037), size: 20),
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
            const SizedBox(height: 15),
            // Custom Tab Bar Container
            Container(
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [Color(0xffFEDA87), Color(0xffFFD54F)],
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
                labelColor: const Color(0xff5D4037),
                unselectedLabelColor: const Color(0xff8D6E63),
                labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
                children: [
                  const MySankalpTab(),
                  const CompletedSankalpTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
