import 'package:brahmakosh/common_imports.dart';

class AppInputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;

  const AppInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 44, // 🔽 FIXED COMPACT HEIGHT
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black38,
              ),
              prefixIcon: Icon(icon, size: 18),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }
}

