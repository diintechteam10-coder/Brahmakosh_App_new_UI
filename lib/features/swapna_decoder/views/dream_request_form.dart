import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/colors.dart';
import '../blocs/dream_request_bloc.dart';
import '../blocs/dream_request_event.dart';
import '../blocs/dream_request_state.dart';
import '../repositories/swapna_repository.dart';

class DreamRequestFormScreen extends StatefulWidget {
  const DreamRequestFormScreen({super.key});

  @override
  State<DreamRequestFormScreen> createState() => _DreamRequestFormScreenState();
}

class _DreamRequestFormScreenState extends State<DreamRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DreamRequestBloc(repository: SwapnaRepository()),
      child: BlocConsumer<DreamRequestBloc, DreamRequestState>(
        listener: (context, state) {
          if (state is DreamRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xff2E7D32),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is DreamRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xffC62828),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: CustomColors.lightPinkColor,
            appBar: AppBar(
              title: Text(
                "Submit Dream Request",
                style: GoogleFonts.lora(
                  fontSize: 20,
                  color: const Color(0xff4E342E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header illustration
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xffFEDA87).withOpacity(0.4),
                              const Color(0xffFF7438).withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.nights_stay_outlined,
                          size: 36,
                          color: Color(0xffFF7438),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "Tell us about your dream",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xff8D6E63),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Symbol field
                    _buildFieldLabel("Dream Symbol", "🌙"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff5D4037).withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _symbolController,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xff4E342E),
                        ),
                        decoration: InputDecoration(
                          hintText: "e.g., Snake, Ocean, Flying",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xffBDAA94),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xffBDAA94),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: const Color(0xffFEDA87).withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xffFF7438),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Details field
                    _buildFieldLabel("Additional Details", "📝"),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff5D4037).withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _detailsController,
                        maxLines: 5,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xff4E342E),
                        ),
                        decoration: InputDecoration(
                          hintText:
                              "Describe the context, your feelings, surroundings...",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xffBDAA94),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: const Color(0xffFEDA87).withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xffFF7438),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Submit button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xffFF7438), Color(0xffFF9A5C)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffFF7438).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: state is DreamRequestLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<DreamRequestBloc>().add(
                                    SubmitDreamRequest(
                                      dreamSymbol: _symbolController.text,
                                      additionalDetails:
                                          _detailsController.text,
                                      clientId: "CLI-KBHUMT",
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state is DreamRequestLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Submit Request",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
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

  Widget _buildFieldLabel(String label, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xff4E342E),
          ),
        ),
      ],
    );
  }
}
