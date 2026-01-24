  import 'package:brahmakosh/core/common_imports.dart';

  class AppTheme {
    // Golden/Spiritual Color Palette based on logo
    static const Color primaryGold = Color(0xFFD4AF37); // Rich Gold
    static const Color darkGold = Color(0xFFB8941F); // Dark Gold
    static const Color lightGold = Color(0xFFF4E4BC); // Light Gold
    static const Color deepGold = Color(0xFF8B6914); // Deep Gold
// Status Colors
static const Color errorRed = Color(0xFFD32F2F); // Auspicious Red (Alert / Rahu Kaal)
static const Color successGreen = Color(0xFF2E7D32); // Sacred Green (Shubh Muhurat)

    // Chakra Colors from logo
    static const Color chakraRed = Color(0xFFDC143C); // Muladhara
    static const Color chakraOrange = Color(0xFFFF8C00); // Svadhisthana
    static const Color chakraYellow = Color(0xFFFFD700); // Manipura
    static const Color chakraGreen = Color(0xFF32CD32); // Anahata
    static const Color chakraBlue = Color(0xFF4169E1); // Vishuddha
    static const Color chakraIndigo = Color(0xFF4B0082); // Ajna
    static const Color chakraPurple = Color(0xFF8208BF); // Sahasrara

    // Background Colors
    static const Color backgroundLight = Color(0xFFFFFEF7); // Cream White
    static const Color backgroundDark = Color(0xFF1A1A1A); // Dark Background
    static const Color cardBackground = Color(0xFFFFFBF0); // Light Cream

    // Text Colors
    static const Color textPrimary = Color(0xFF2C1810); // Dark Brown
    static const Color textSecondary = Color(0xFF6B5B4F); // Medium Brown
    static const Color textLight = Color(0xFF8B7355); // Light Brown

    // Gradient Colors
    static const LinearGradient goldGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF4E4BC), Color(0xFFD4AF37), Color(0xFFB8941F)],
    );

    static const LinearGradient darkGoldGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFB8941F), Color(0xFF8B6914), Color(0xFF6B5010)],
    );

    static ThemeData get lightTheme {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Color Scheme
        colorScheme: ColorScheme.light(
          primary: primaryGold,
          secondary: chakraPurple,
          surface: cardBackground,
          background: backgroundLight,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onBackground: textPrimary,
          onError: Colors.white,
        ),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 57,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.25,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: 0,
          ),
          displaySmall: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: 0,
          ),
          headlineLarge: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: 0,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: 0,
          ),
          headlineSmall: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0,
          ),
          titleLarge: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0.15,
          ),
          titleMedium: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.15,
          ),
          titleSmall: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1,
          ),
          bodyLarge: GoogleFonts.lora(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.lora(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textPrimary,
            letterSpacing: 0.25,
          ),
          bodySmall: GoogleFonts.lora(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textSecondary,
            letterSpacing: 0.4,
          ),
          labelLarge: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1,
          ),
          labelMedium: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.cinzel(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.5,
          ),
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGold,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryGold,
            side: const BorderSide(color: primaryGold, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryGold,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lightGold, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lightGold, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGold, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: GoogleFonts.lora(color: textSecondary, fontSize: 14),
          hintStyle: GoogleFonts.lora(color: textLight, fontSize: 14),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(8),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardBackground,
          selectedItemColor: primaryGold,
          unselectedItemColor: textSecondary,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: lightGold,
          thickness: 1,
          space: 1,
        ),
      );
    }
    static const LinearGradient lightGoldGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFFF7E0), // very soft cream
    Color(0xFFF4E4BC), // light gold
    Color(0xFFE8D18A), // subtle gold highlight
  ],
);

  }
