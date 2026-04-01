import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import 'package:brahmakosh/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../ai_rashmi_service.dart';
import '../deity_selection_service.dart';
import '../model/agents_response_model.dart';
import 'ai_guide_view.dart';

class AskBiView extends StatefulWidget {
  const AskBiView({super.key});

  @override
  State<AskBiView> createState() => _AskBiViewState();
}

class _AskBiViewState extends State<AskBiView> {
  final AiRashmiService _service = AiRashmiService();

  List<AgentResponseData> agents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAgents();
  }

  Future<void> loadAgents() async {
    try {
      final response = await _service.fetchAgents();

      if (mounted) {
        setState(() {
          agents = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// TOP BAR
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.h,
                  ),
                  child: Row(
                    children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        onPressed: () {
                          Provider.of<DashboardViewModel>(
                            context,
                            listen: false,
                          ).changeTab(0);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// TITLE
                Text(
                  "ASK YOUR BI",
                  style: GoogleFonts.lora(
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "BRAHMAKOSH ",
                        style: GoogleFonts.lora(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "INTELLIGENCE",
                        style: GoogleFonts.lora(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// SUBTITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.primaryGold,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      "CHOOSE YOUR SPIRITUAL GUIDE TO PROCEED",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// AGENTS FROM API
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: agents.map((agent) {
                      final name = agent.name ?? "";
                      final isKrishna = name.toLowerCase().contains("krishna");

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGuideCard(
                          context,
                          title: name,
                          subtitle: agent.description ?? "",
                          description: agent.firstMessage ?? "",
                          buttonText: "Explore",
                          buttonGradient: const LinearGradient(
                            colors: [
                              Color(0xFFFDB913),
                              Color(0xFF9E7B15),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          characterImagePath: isKrishna
                              ? 'assets/icons/Krishna_new_avatar.png'
                              : 'assets/icons/rashmi_new_avatar.png',
                          backgroundColor: const Color(0xFF1A1A1A),
                          textColor: Colors.white,
                          dividerColor: AppTheme.primaryGold.withOpacity(0.3),
                          // isLockIcon: isKrishna,
                          borderColor: isKrishna ? AppTheme.primaryGold : Colors.transparent,
                          buttonTextColor: Colors.white,
                          onTap: () async {
                            if (!Get.isRegistered<AgentController>()) {
                              Get.put(AgentController());
                            }
print("Selected Agent ID: ${agent.id}");
print("Saved Agent ID: ${StorageService.getString('ai_selected_agent_id')}");
                            final agentController = Get.find<AgentController>();

                            if (agentController.avatars.isEmpty) {
                              await agentController.fetchAvatars(null);
                            }

                            try {
                              final selectedAgent = agentController.avatars
                                  .firstWhere(
                                    (a) => (a.name ?? "")
                                        .toLowerCase()
                                        .contains(name.toLowerCase()),
                                  );

                              DeitySelectionService().setSelectedDeity(
                                selectedAgent,
                              );
                            } catch (e) {}
                            StorageService.setString(
                              'ai_selected_agent_id',
                              agent.id ?? '',
                            );
                            StorageService.setString(
                              'ai_selected_agent_name',
                              agent.name ?? '',
                            );
                            
                            // Print to terminal
                            print("=== SAVED AGENT INFO ===");
                            print("Saved Agent ID: ${StorageService.getString('ai_selected_agent_id')}");
                            print("Saved Agent Name: ${StorageService.getString('ai_selected_agent_name')}");
                            print("========================");

                            Get.to(
                              () => AiGuideView(
                                deityName: name,
                                subtitle: agent.description ?? "",
                                firstMessage: agent.firstMessage,
                                // subtitle: agent. "",
                                backgroundImage:
                                    'assets/icons/chat_bg_new.png',
                                characterImagePath: isKrishna
                                    ? 'assets/icons/krishna_neww.png'
                                    : 'assets/icons/Rashmi_new_chat.png',
                                chatBackgroundImage: isKrishna
                                    ? 'assets/icons/krishna_neww.png'
                                    : 'assets/images/Rashmi_chat.png',
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                /// MANTRA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "|| ॐ भूर्भुव: स्व: तत्सवितुर्वरेण्यं भर्गो देवस्य\nधीमहि धियो यो न: प्रचोदयात् ||",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rozhaOne(
                      fontSize: 15.sp,
                      color: AppTheme.primaryGold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required Gradient buttonGradient,
    required String characterImagePath,
    required Color backgroundColor,
    required VoidCallback onTap,
    required Color textColor,
    required Color dividerColor,
    // required bool isLockIcon,
    required Color borderColor,
    Color buttonTextColor = Colors.white,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.32;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(
                  width: imageWidth,
                  child: Image.asset(
                    characterImagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.lora(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          height: 1,
                          width: double.infinity,
                          color: dividerColor,
                        ),

                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 8.25.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 7.5.sp,
                            fontStyle: FontStyle.italic,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.5.w,
                            vertical: 0.75.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: buttonGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // if (isLockIcon) ...[
                              //   Icon(
                              //     Icons.lock,
                              //     size: 10,
                              //     color: buttonTextColor,
                              //   ),
                              //   const SizedBox(width: 4),
                              // ],

                              Text(
                                buttonText,
                                style: GoogleFonts.poppins(
                                  fontSize: 8.25.sp,
                                  fontWeight: FontWeight.bold,
                                  color: buttonTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }