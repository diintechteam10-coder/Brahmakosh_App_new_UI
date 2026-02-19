import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/controllers/home_controller.dart';
import '../blocs/pooja_bloc.dart';
import '../blocs/pooja_event.dart';
import '../blocs/pooja_state.dart';
import '../models/pooja_model.dart';
import '../repositories/pooja_repository.dart';
import 'pooja_detail_screen.dart';

class PoojaListScreen extends StatefulWidget {
  const PoojaListScreen({super.key});

  @override
  State<PoojaListScreen> createState() => _PoojaListScreenState();
}

class _PoojaListScreenState extends State<PoojaListScreen> {
  // Use Get.find to access the existing HomeController
  // Assuming HomeController is already initialized in the dashboard/home binding
  final HomeController _homeController = Get.find<HomeController>();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning!";
    } else if (hour < 17) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PoojaBloc(repository: PoojaRepository())..add(FetchPoojas()),
      child: Scaffold(
        backgroundColor: const Color(0xffFFF3E0),
        appBar: AppBar(
          backgroundColor: const Color(0xffFFF3E0),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              // const CircleAvatar(
              //   backgroundImage: AssetImage(
              //     'assets/images/avatar_placeholder.png',
              //   ), // Or network image if available
              //   radius: 18,
              // ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff8D6E63),
                    ),
                  ),
                  Obx(() {
                    final userName = _homeController
                        .userCompleteDetails
                        ?.data
                        ?.user
                        ?.profile
                        ?.name;
                    return Text(
                      userName ?? "Guest",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff4E342E),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xff5D4037)),
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for puja",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    icon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<PoojaBloc, PoojaState>(
                builder: (context, state) {
                  String selectedCategory = 'All';
                  if (state is PoojaLoaded) {
                    selectedCategory = state.selectedCategory;
                  }
                  return Row(
                    children: [
                      _buildFilterTab(
                        context,
                        "All",
                        0,
                        selectedCategory == 'All',
                      ),
                      const SizedBox(width: 12),
                      _buildFilterTab(
                        context,
                        "Festival",
                        1,
                        selectedCategory == 'Festival',
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // List
            Expanded(
              child: BlocBuilder<PoojaBloc, PoojaState>(
                builder: (context, state) {
                  if (state is PoojaLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PoojaLoaded) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.filteredPoojas.length,
                      itemBuilder: (context, index) {
                        return _buildPoojaCard(
                          context,
                          state.filteredPoojas[index],
                        );
                      },
                    );
                  } else if (state is PoojaError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context,
    String label,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<PoojaBloc>().add(FilterPoojas(label));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffff9800) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xff5D4037),
          ),
        ),
      ),
    );
  }

  Widget _buildPoojaCard(BuildContext context, PoojaModel pooja) {
    return GestureDetector(
      onTap: () {
        // Navigate to detail screen with ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoojaDetailScreen(poojaId: pooja.sId ?? ""),
          ),
        );
      },
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(pooja.thumbnailUrl ?? ""),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
            onError: (exception, stackTrace) {
              // Handle image error if needed
            },
          ),
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(), // Push content to bottom
                  Text(
                    pooja.pujaName ?? "Unknown Puja",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (pooja.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pooja.category!,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${pooja.duration ?? 0} Mins",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Date is not readily available in brief model unless I map it
                      // Assuming 'bestDay' uses string
                      if (pooja.bestDay != null) ...[
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            pooja.bestDay!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Rating and devotees count not in new API model, removing or hardcoding if needed.
                  // Removing for now as per "dont make unnecessary changes" but adapting to new model.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
