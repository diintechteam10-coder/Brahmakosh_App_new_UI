import 'package:brahmakosh/features/gita/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../ai_rashmi/ai_rashmi_chat.dart';
import '../data/repositories/gita_repository.dart';
import '../data/models/verse_model.dart';
import '../bloc/detail/gita_detail_bloc.dart';
import '../bloc/detail/gita_detail_event.dart';
import '../bloc/detail/gita_detail_state.dart';
import '../widgets/decorative_divider.dart';
import 'package:brahmakosh/core/services/storage_service.dart';

class GitaShlokaDetailScreen extends StatefulWidget {
  final String verseId;
  final VerseModel? verse; // Preview data
  final List<VerseModel>? siblingVerses; // For Next/Prev navigation

  const GitaShlokaDetailScreen({
    super.key,
    required this.verseId,
    this.verse,
    this.siblingVerses,
  });

  @override
  State<GitaShlokaDetailScreen> createState() => _GitaShlokaDetailScreenState();
}

class _GitaShlokaDetailScreenState extends State<GitaShlokaDetailScreen> {
  late String _currentVerseId;
  VerseModel? _currentVerse;
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentVerseId = widget.verseId;
    _currentVerse = widget.verse;
    _updateIndex();
    _saveLastRead(_currentVerse);
  }

  /// Persist last-read chapter and verse to local storage
  void _saveLastRead(VerseModel? verse) {
    if (verse == null) return;
    if (verse.chapterNumber != null) {
      StorageService.setInt('gita_last_chapter_number', verse.chapterNumber!);
    }
    if (verse.chapterName != null) {
      StorageService.setString('gita_last_chapter_name', verse.chapterName!);
    }
    if (verse.shlokaNumber != null) {
      StorageService.setString('gita_last_verse_number', verse.shlokaNumber!);
      // Save per-chapter completed verse count
      if (verse.chapterNumber != null) {
        final verseNum = int.tryParse(verse.shlokaNumber!) ?? 0;
        final key = 'gita_chapter_${verse.chapterNumber}_completed';
        final current = StorageService.getInt(key) ?? 0;
        if (verseNum > current) {
          StorageService.setInt(key, verseNum);
        }
      }
    }
  }

  void _updateIndex() {
    if (widget.siblingVerses != null) {
      _currentIndex = widget.siblingVerses!.indexWhere(
        (v) => v.id == _currentVerseId,
      );
    }
  }

  void _navigateToVerse(int newIndex) {
    if (widget.siblingVerses != null &&
        newIndex >= 0 &&
        newIndex < widget.siblingVerses!.length) {
      final nextVerse = widget.siblingVerses![newIndex];
      setState(() {
        _currentVerseId = nextVerse.id ?? '';
        _currentIndex = newIndex;
        _currentVerse = nextVerse; // Optimistic update
      });
      _saveLastRead(nextVerse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(
        _currentVerseId,
      ), // Re-create bloc if ID changes completely? No, reuse bloc.
      create: (context) =>
          GitaDetailBloc(repository: GitaRepository())
            ..add(FetchGitaVerseDetail(_currentVerseId)),
      child: _GitaDetailView(
        verse: _currentVerse,
        onNext: () => _navigateToVerse(_currentIndex + 1),
        onPrev: () => _navigateToVerse(_currentIndex - 1),
        hasPrev: _currentIndex > 0,
        hasNext:
            widget.siblingVerses != null &&
            _currentIndex < widget.siblingVerses!.length - 1,
      ),
    );
  }
}

class _GitaDetailView extends StatelessWidget {
  final VerseModel? verse;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final bool hasNext;
  final bool hasPrev;

  const _GitaDetailView({
    required this.verse,
    required this.onNext,
    required this.onPrev,
    required this.hasNext,
    required this.hasPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black87),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton.extended(
        extendedPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        backgroundColor: const Color(0xFFFF9800),
        onPressed: () {
          final state = context.read<GitaDetailBloc>().state;
          VerseModel? currentVerse = verse;
          if (state is GitaDetailLoaded) {
            currentVerse = state.verse;
          }
          final prompt =
              "Can you please explain this Gita verse to me?\n\n'${currentVerse?.sanskritShloka}'\n\n(Chapter ${currentVerse?.chapterNumber}, Verse ${currentVerse?.shlokaNumber})";
          Get.to(
            () => RashmiChat(
              backgroundImage: 'assets/images/Krishna_chat.png',
              hideLearnGita: true,
              initialMessage: prompt,
              autoAsk: true,
            ),
          );
        },
        icon: Container(
          width: 35, // Size of the circular container
          height: 35,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // Background of the circle
            image: DecorationImage(
              image: AssetImage('assets/images/Krishna_chat.png'),
              fit: BoxFit.cover, // Keeps the whole figure visible
              alignment: Alignment.topCenter, // Forces centering
              scale: 1.5, // Adjust this number (0.5 to 1.5) to zoom in/out
            ),
          ),
        ),
        label: Text(
          "ASK KRISHNA",
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        top: true,
        child: BlocBuilder<GitaDetailBloc, GitaDetailState>(
          builder: (context, state) {
            VerseModel? displayVerse = verse;
            if (state is GitaDetailLoaded) {
              displayVerse = state.verse;
            }

            if (state is GitaDetailLoading && displayVerse == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            if (displayVerse == null) {
              if (state is GitaDetailError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, displayVerse),
                 const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: WavyDivider(),
        ),
        const SizedBox(height: 8),

                  // _buildNavigationButtons(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: DecorativeDivider(
                      centerText: 'Shloak',
                      centerTextStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _buildContentCard(
                    backgroundColor: const Color(0xFF133621), // Dark Teal-Green for Sanskrit
                    displayVerse.sanskritShloka,
                    isSanskrit: true,
                    textColor: Colors.white,
                  ),
                  _buildContentCard(
                    backgroundColor: const Color(0xFF2E2E2E), // Dark Grey for Transliteration
                    displayVerse.sanskritTransliteration,
                    textColor: Colors.white70,
                  ),
                  _buildContentCard(
                    backgroundColor: const Color(0xFF7A4A06), // Dark Brown/Gold for Hindi
                    displayVerse.hindiMeaning,
                    textColor: Colors.white,
                  ),
                  _buildContentCard(
                    backgroundColor: const Color(0xFF2E2E2E), // Dark Grey for English
                    displayVerse.englishMeaning,
                    textColor: Colors.white70,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: DecorativeDivider(
                      centerText: 'Explanation',
                      centerTextStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _buildContentCard(
                    backgroundColor: const Color(0xFF2D1B69), // Deep Indigo/Violet for Explanation
                    displayVerse.explanation,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VerseModel verse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back + Menu row — same style as GitaHeader
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _roundIcon(
                Icons.arrow_back_ios_new_outlined,
                () => Navigator.pop(context),
              ),
              _roundIcon(Icons.menu, () {}),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Title row with verse navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: chapter name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verse.chapterName ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF1C453), // Gold — same as GitaHeader
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chap ${verse.chapterNumber != null ? '0${verse.chapterNumber}' : ''} -',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right: Verse number + prev/next arrows
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Verse ${verse.chapterNumber}.${verse.shlokaNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF1C453), // Gold
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _roundIcon(
                        Icons.arrow_back_ios_new_outlined,
                        hasPrev ? onPrev : () {},
                        backgroundColor: Colors.orange.withOpacity(0.3),
                        size: 30,
                        iconSize: 16,
                        iconColor: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      _roundIcon(
                        Icons.arrow_forward_ios_outlined,
                        hasNext ? onNext : () {},
                        backgroundColor: Colors.orange,
                        size: 30,
                        iconSize: 16,
                        iconColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _roundIcon(
    IconData icon,
    VoidCallback onTap, {
    Color backgroundColor = const Color(0x14FFFFFF), // white.withOpacity(0.08)
    Color iconColor = Colors.white,
    double size = 36,
    double iconSize = 18,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }

  // Widget _buildHeader(BuildContext context, VerseModel verse) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       image: const DecorationImage(
  //         image: AssetImage('assets/images/header_bg.png'),
  //         fit: BoxFit.cover,
  //         opacity: 0.2,
  //       ),
  //       color: const Color(0xFFFFF0D6),
  //       borderRadius: BorderRadius.circular(24),
  //       border: Border.all(color: Colors.orange.withOpacity(0.2)),
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           verse.chapterName ?? '',
  //           style: const TextStyle(
  //             fontSize: 22,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xFF8B4513),
  //             fontFamily: 'Serif',
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Chapters ${verse.chapterNumber}',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Color(0xFF8B4513).withOpacity(0.8),
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         const Divider(thickness: 0.5, color: Colors.grey),
  //         const SizedBox(height: 12),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               'Verse - ${verse.shlokaNumber}', // Should be 1.1 etc format if possible?
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             const Text('2 min read', style: TextStyle(color: Colors.black54)),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNavigationButtons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       ElevatedButton(
  //         onPressed: hasPrev ? onPrev : null,
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.orange,
  //           foregroundColor: Colors.white,
  //           disabledBackgroundColor: Colors.orange.withOpacity(0.3),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //         ),
  //         child: const Text('Previous Verse'),
  //       ),
  //       ElevatedButton(
  //         onPressed: hasNext ? onNext : null,
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.orange,
  //           foregroundColor: Colors.white,
  //           disabledBackgroundColor: Colors.orange.withOpacity(0.3),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //         ),
  //         child: const Text('Next Verse'),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildContentCard(
    String? content, {
    bool isSanskrit = false,
    Color backgroundColor = const Color(0xFF2E2E2E),
    Color textColor = Colors.white70,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            height: 1.6,
            fontWeight: isSanskrit ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
