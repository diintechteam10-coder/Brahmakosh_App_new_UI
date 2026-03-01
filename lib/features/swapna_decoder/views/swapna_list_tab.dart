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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff5D4037).withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Full card image
                          CachedNetworkImage(
                            imageUrl: swapna.thumbnailUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xffF4E9E0),
                              child: const Center(
                                child: Icon(
                                  Icons.nights_stay_outlined,
                                  color: Color(0xffFEDA87),
                                  size: 32,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xffF4E9E0),
                              child: const Center(
                                child: Icon(
                                  Icons.nights_stay_outlined,
                                  color: Color(0xffFEDA87),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          // Gradient overlay for text readability
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.15),
                                    Colors.black.withOpacity(0.65),
                                  ],
                                  stops: const [0.0, 0.4, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Category chip (top-right)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                swapna.category,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff5D4037),
                                ),
                              ),
                            ),
                          ),
                          // Symbol name (bottom)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                swapna.symbolName,
                                style: GoogleFonts.lora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
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
