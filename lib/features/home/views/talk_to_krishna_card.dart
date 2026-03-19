import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import 'package:brahmakosh/features/ai_rashmi/ai_rashmi_chat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../ai_rashmi/aradhya_selection_view.dart';
import '../../dashboard/viewmodels/dashboard_viewmodel.dart';

class TalkToKrishnaCard extends StatelessWidget {
  const TalkToKrishnaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () async {
          // await Get.to(
          //   () => AradhyaSelectionView(
          //     onDeitySelected: () async {
          //       Provider.of<DashboardViewModel>(
          //         context,
          //         listen: false,
          //       ).changeTab(2);
          //     },
          //   ),
          // );
          if (!Get.isRegistered<AgentController>()) {
            Get.put(AgentController());
          }
          // Provider.of<DashboardViewModel>(context, listen: false).changeTab(2);
          Get.to(
            () => const RashmiChat(
              backgroundImage: 'assets/images/Krishna_chat.png',
            ),
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.20,
          width: double.infinity,
          clipBehavior:
              Clip.hardEdge, // Ensures child is clipped to the borderRadius
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            //border: Border.all(color: Colors.black, width: 1),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/TalkToKrishna.png', fit: BoxFit.cover),
              // Optional gradient overlay (enable if needed)
              /*
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              */
              LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: constraints.maxWidth - 32,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TALK TO KRISHNA",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lora(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Your Personal Spiritual Guide",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lora(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.95),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildBulletPoint("Life Question"),
                            _buildBulletPoint("Emotional Clarity"),
                            _buildBulletPoint("Daily Guidance"),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2E3BC),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "Connect now",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lora(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6D3A0C),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lora(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
