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
          return const Center(child: CircularProgressIndicator());
        } else if (state is SwapnaError) {
          return Center(child: Text("Error: ${state.message}"));
        } else if (state is SwapnaLoaded) {
          if (state.swapnas.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SwapnaBloc>().add(FetchSwapnaList());
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("No dream symbols found.")),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SwapnaBloc>().add(FetchSwapnaList());
            },
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ), // Added bottom padding
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: swapna.thumbnailUrl ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey, // Fallback icon
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                swapna.symbolName,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff5D4037),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                swapna.category,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
