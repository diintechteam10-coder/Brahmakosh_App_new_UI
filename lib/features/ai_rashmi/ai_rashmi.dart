import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ai_rashmi_service.dart';
import 'ai_rashmi_view_model.dart';
import 'views/ask_bi_view.dart';

class RashmiAi extends StatelessWidget {
  const RashmiAi({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller inject with GetX
    Get.put(AiRashmiController(service: AiRashmiService()));
    return const AskBiView();
  }
}
