import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/swapna_bloc.dart';
import '../blocs/swapna_event.dart';
import '../blocs/swapna_state.dart';
import '../repositories/swapna_repository.dart';
import 'swapna_detail_screen.dart';

class SwapnaListTab extends StatelessWidget {
  const SwapnaListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SwapnaBloc(repository: SwapnaRepository())..add(FetchSwapnaList()),
      child: const SwapnaListView(),
    );
  }
}

class SwapnaListView extends StatelessWidget {
  const SwapnaListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapnaBloc, SwapnaState>(
      builder: (context, state) {
        if (state is SwapnaLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xffFF7438),
            ),
          );
        } else if (state is SwapnaError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  "Something went wrong",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5D4037),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (state is SwapnaLoaded) {
          if (state.swapnas.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xffFF7438),
              onRefresh: () async {
                context.read<SwapnaBloc>().add(FetchSwapnaList());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Column(
                    children: [
                      Icon(
                        Icons.nights_stay_outlined,
                        size: 56,
                        color: const Color(0xffFEDA87).withOpacity(0.8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No dream symbols found",
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5D4037),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Pull down to refresh",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xff8D6E63),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: const Color(0xffFF7438),
            onRefresh: () async {
              context.read<SwapnaBloc>().add(FetchSwapnaList());
            },
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: state.swapnas.length,
              itemBuilder: (context, index) {
                final swapna = state.swapnas[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SwapnaDetailScreen(id: swapna.id, swapna: swapna),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image part
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CachedNetworkImage(
                              imageUrl: swapna.thumbnailUrl ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(
                                    Icons.nights_stay_outlined,
                                    color: Color(0xFFD4AF37),
                                    size: 24,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(
                                    Icons.nights_stay_outlined,
                                    color: Color(0xFFD4AF37),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          swapna.symbolName,
                          style: GoogleFonts.lora(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Short description
                        Expanded(
                          child: Text(
                            swapna.shortDescription ?? swapna.category,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Button
                        Container(
                          width: double.infinity,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "REVEAL MEANING",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
