import 'package:flutter/material.dart';

class BottomChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool hasMessages;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onFaqTap;

  const BottomChatInput({
    super.key,
    required this.controller,
    required this.isSending,
    required this.hasMessages,
    required this.hintText,
    required this.onSend,
    this.onFaqTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Input
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.0,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black54),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => isSending ? null : onSend(),
            ),

            if (!hasMessages) const SizedBox(height: 24),

            /// Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!hasMessages)
                  Expanded(
                    child: GestureDetector(
                      onTap: onFaqTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "FAQ's",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                GestureDetector(
                  onTap: isSending ? null : onSend,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
