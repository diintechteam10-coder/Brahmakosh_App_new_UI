import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/dream_request_bloc.dart';
import '../blocs/dream_request_event.dart';
import '../blocs/dream_request_state.dart';
import '../repositories/swapna_repository.dart';
import 'dream_request_form.dart';
import 'dream_request_detail_screen.dart';

class DreamRequestsTab extends StatelessWidget {
  const DreamRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DreamRequestBloc(repository: SwapnaRepository())
            ..add(FetchDreamRequests()),
      child: const DreamRequestsView(),
    );
  }
}

class DreamRequestsView extends StatelessWidget {
  const DreamRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DreamRequestFormScreen(),
            ),
          ).then((value) {
            if (value == true) {
              // Refresh list
              context.read<DreamRequestBloc>().add(FetchDreamRequests());
            }
          });
        },
        backgroundColor: const Color(0xffFEDA87),
        child: const Icon(Icons.add, color: Color(0xff5D4037)),
      ),
      body: BlocBuilder<DreamRequestBloc, DreamRequestState>(
        builder: (context, state) {
          if (state is DreamRequestLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DreamRequestError) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DreamRequestBloc>().add(FetchDreamRequests());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(child: Text("Error: ${state.message}")),
                ),
              ),
            );
          } else if (state is DreamRequestLoaded) {
            if (state.requests.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DreamRequestBloc>().add(FetchDreamRequests());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Text(
                        "No dream requests found.\nSubmit a new one!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: const Color(0xff5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DreamRequestBloc>().add(FetchDreamRequests());
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  100,
                ), // Added bottom padding
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to detail
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DreamRequestDetailScreen(request: request),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  request.dreamSymbol,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff5D4037),
                                  ),
                                ),
                              ),
                              _buildStatusChip(request.status ?? 'Unknown'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            request.additionalDetails,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (request.completedDreamId != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Decoded as: ${request.completedDreamId?.symbolName}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
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
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'in progress':
        color = Colors.orange;
        break;
      case 'pending':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
