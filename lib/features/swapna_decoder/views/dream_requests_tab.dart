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
      backgroundColor: Colors.black,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFC5A028)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffFEDA87).withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DreamRequestFormScreen(),
              ),
            ).then((value) {
              if (value == true) {
                if (context.mounted) {
                  context.read<DreamRequestBloc>().add(FetchDreamRequests());
                }
              }
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
      body: BlocBuilder<DreamRequestBloc, DreamRequestState>(
        builder: (context, state) {
          if (state is DreamRequestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            );
          } else if (state is DreamRequestError) {
            return RefreshIndicator(
              color: const Color(0xFFD4AF37),
              onRefresh: () async {
                context.read<DreamRequestBloc>().add(FetchDreamRequests());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded,
                            size: 48, color: Colors.grey[600]),
                        const SizedBox(height: 12),
                        Text(
                          "Something went wrong",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.message,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (state is DreamRequestLoaded) {
            if (state.requests.isEmpty) {
              return RefreshIndicator(
                color: const Color(0xFFD4AF37),
                onRefresh: () async {
                  context.read<DreamRequestBloc>().add(FetchDreamRequests());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.1),
                            ),
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            size: 40,
                            color: const Color(0xFFD4AF37).withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No dream requests yet",
                          style: GoogleFonts.lora(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Submit your dream symbol and our experts will decode its spiritual meaning for you.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.grey[500],
                            ),
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
                context.read<DreamRequestBloc>().add(FetchDreamRequests());
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  final statusColor = _getStatusColor(request.status);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DreamRequestDetailScreen(request: request),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               // Status Indicator Bar
                              Container(
                                width: 3,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Dream icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.nights_stay_outlined,
                                  size: 18,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.dreamSymbol,
                                      style: GoogleFonts.lora(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      request.additionalDetails,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusChip(
                                  request.status ?? 'Unknown', statusColor),
                            ],
                          ),
                          if (request.completedDreamId != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: Color(0xFFD4AF37),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Decoded: ${request.completedDreamId?.symbolName}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Color(0xFFD4AF37),
                                  ),
                                ],
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Color(0xFFD4AF37);
      case 'in progress':
        return const Color(0xFFC5A028);
      case 'pending':
        return Colors.grey[600]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 9,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

