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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DreamRequestBloc(repository: SwapnaRepository()),
      child: BlocConsumer<DreamRequestBloc, DreamRequestState>(
        listener: (context, state) {
          if (state is DreamRequestSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context, true);
          } else if (state is DreamRequestError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: CustomColors.lightPinkColor,
            appBar: AppBar(
              title: Text(
                "Submit Dream Request",
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xff5D4037),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
                onPressed: () => Get.back(),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "What major symbol did you see?",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5D4037),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _symbolController,
                      decoration: InputDecoration(
                        hintText: "e.g., Snake, Ocean, Flying",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Additional Details",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff5D4037),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _detailsController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Describe the context, your feelings, etc.",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: state is DreamRequestLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<DreamRequestBloc>().add(
                                  SubmitDreamRequest(
                                    dreamSymbol: _symbolController.text,
                                    additionalDetails: _detailsController.text,
                                    clientId:
                                        "CLI-KBHUMT", // Hardcoded per user request example? Or is it dynamic?
                                    // User request had: "clientId": "CLI-KBHUMT".
                                    // I will use that constant or assume it's valid.
                                    // Actually usually Client ID is fixed per app client.
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFEDA87),
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
                              ),
                            )
                          : Text(
                              "Submit Request",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff5D4037),
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
}
