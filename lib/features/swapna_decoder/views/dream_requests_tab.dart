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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xffFEDA87), Color(0xffF4C430)],
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
                context.read<DreamRequestBloc>().add(FetchDreamRequests());
              }
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Color(0xff5D4037), size: 28),
        ),
      ),
      body: BlocBuilder<DreamRequestBloc, DreamRequestState>(
        builder: (context, state) {
          if (state is DreamRequestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xffFF7438)),
            );
          } else if (state is DreamRequestError) {
            return RefreshIndicator(
              color: const Color(0xffFF7438),
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
                            size: 48, color: Colors.grey[400]),
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
                color: const Color(0xffFF7438),
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
                        Icon(
                          Icons.edit_note_rounded,
                          size: 56,
                          color: const Color(0xffFEDA87).withOpacity(0.8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No dream requests yet",
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff5D4037),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tap + to submit your first dream",
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border(
                          left: BorderSide(
                            color: statusColor,
                            width: 4,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff5D4037).withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dream icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
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
                                        color: const Color(0xff4E342E),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      request.additionalDetails,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: const Color(0xff8D6E63),
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
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Color(0xff2E7D32),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "Decoded as: ${request.completedDreamId?.symbolName}",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xff2E7D32),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: Color(0xff2E7D32),
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
        return const Color(0xff2E7D32);
      case 'in progress':
        return const Color(0xffFF7438);
      case 'pending':
        return const Color(0xffE53935);
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status, Color color) {
    IconData icon;
    switch (status.toLowerCase()) {
      case 'completed':
        icon = Icons.check_circle_outline;
        break;
      case 'in progress':
        icon = Icons.hourglass_bottom_rounded;
        break;
      case 'pending':
        icon = Icons.schedule;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
