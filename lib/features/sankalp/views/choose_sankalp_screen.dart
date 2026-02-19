import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/colors.dart';
import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import 'sankalp_detail_screen.dart';

class ChooseSankalpScreen extends StatefulWidget {
  const ChooseSankalpScreen({super.key});

  @override
  State<ChooseSankalpScreen> createState() => _ChooseSankalpScreenState();
}

class _ChooseSankalpScreenState extends State<ChooseSankalpScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SankalpBloc>().add(FetchAvailableSankalps());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightPinkColor,
      appBar: AppBar(
        title: Text(
          "Choose Sankalp",
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
      ),
      body: BlocBuilder<SankalpBloc, SankalpState>(
        builder: (context, state) {
          if (state is SankalpLoading && (state is! SankalpLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SankalpError) {
            return Center(child: Text(state.message));
          }

          List<SankalpModel> sankalps = [];
          if (state is SankalpLoaded) {
            sankalps = state.availableSankalps;
          }

          if (sankalps.isEmpty) {
            if (state is SankalpLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text("No Sankalps Available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sankalps.length,
            itemBuilder: (context, index) {
              final sankalp = sankalps[index];
              return _buildSankalpItem(context, sankalp);
            },
          );
        },
      ),
    );
  }

  Widget _buildSankalpItem(BuildContext context, SankalpModel sankalp) {
    return GestureDetector(
      onTap: () {
        if (sankalp.id.isEmpty) {
          Get.snackbar("Error", "Invalid Sankalp ID");
          return;
        }

        try {
          debugPrint("Navigating to detail for sankalp: ${sankalp.id}");
          final bloc = context.read<SankalpBloc>();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: bloc,
                child: SankalpDetailScreen(sankalp: sankalp),
              ),
            ),
          );
        } catch (e) {
          debugPrint("Navigation error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Full details not available")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Area
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    sankalp.bannerImage.isNotEmpty
                        ? sankalp.bannerImage
                        : "https://images.unsplash.com/photo-1604881991720-f91add269bed?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${sankalp.totalDays} Days",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5D4037),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sankalp.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff4E342E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sankalp.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xff8D6E63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: Color(0xffD4AF37),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "+${sankalp.karmaPointsPerDay} Karma / Day",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff5D4037),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
