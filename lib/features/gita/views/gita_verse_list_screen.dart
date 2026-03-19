import 'package:brahmakosh/common_imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../ai_rashmi/ai_rashmi_chat.dart';

import '../data/repositories/gita_repository.dart';
import '../data/models/chapter_model.dart';
import '../data/models/verse_model.dart';
import '../bloc/verse/gita_verse_bloc.dart';
import '../bloc/verse/gita_verse_event.dart';
import '../bloc/verse/gita_verse_state.dart';
import '../widgets/decorative_divider.dart';
import '../widgets/header.dart';
import 'gita_shloka_detail_screen.dart';
import 'package:brahmakosh/core/services/storage_service.dart';

class GitaVerseListScreen extends StatelessWidget {
  final ChapterModel chapter;

  const GitaVerseListScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GitaVerseBloc(repository: GitaRepository())
            ..add(FetchGitaVerses(chapter.chapterNumber ?? 1)),
      child: _GitaVerseListView(chapter: chapter),
    );
  }
}

class _GitaVerseListView extends StatefulWidget {
  final ChapterModel chapter;

  const _GitaVerseListView({required this.chapter});

  @override
  State<_GitaVerseListView> createState() => _GitaVerseListViewState();
}

class _GitaVerseListViewState extends State<_GitaVerseListView> {
  // We'll read from storage in build, but setState will trigger rebuild
  // so build checks storage again. No local state needed for variables
  // since build always re-reads.
  Offset _tapPosition = Offset.zero;

  void _showAskKrishnaPopup(
    BuildContext context,
    dynamic verse,
    Offset position,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      color: const Color(0xFF18151B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'ask',
          child: Row(
  children: [
    const Icon(
      Icons.auto_awesome, // Represents magic/divine guidance
      color: Color(0xFFF1C453),
      size: 20,
    ),
    const SizedBox(width: 12),
    Text(
      'Ask Krishna',
      style: GoogleFonts.poppins( // Matches your other updated sections
        color: Colors.white, 
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
)
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'ask') {
        final prompt =
            "Can you please explain this Gita verse to me?\n\n'${verse.sanskritShloka}'\n\n(Chapter ${widget.chapter.chapterNumber}, Verse ${verse.shlokaNumber})";
        Get.to(
          () => RashmiChat(
            backgroundImage: 'assets/images/Krishna_chat.png',
            initialMessage: prompt,
            autoAsk: true,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build "last read" subtitle from local storage
    final lastChapter = StorageService.getInt('gita_last_chapter_number');
    final lastVerse = StorageService.getString('gita_last_verse_number');
    String continueLabel = '';
    if (lastChapter == widget.chapter.chapterNumber && lastVerse != null) {
      continueLabel = 'Last read: Verse $lastVerse';
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      floatingActionButton: FloatingActionButton.extended(
        extendedPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        backgroundColor: const Color(0xFFFF9800),
        onPressed: () => Get.to(
          () => const RashmiChat(
            backgroundImage: 'assets/images/Krishna_chat.png',
            hideLearnGita: true,
          ),
        ),
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
        label: const Text(
          "ASK KRISHNA",
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            GitaHeader(
              title: widget.chapter.name ?? '',
              subtitle:
                  'Chapters ${widget.chapter.chapterNumber}  ${widget.chapter.shlokaCount} Verses',
              backgroundImage: '',

              onBack: () => Navigator.pop(context),
              onMenu: () {},
              continueSubtitle: continueLabel,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: DecorativeDivider(),
            ),
            Expanded(
              child: BlocBuilder<GitaVerseBloc, GitaVerseState>(
                builder: (context, state) {
                  if (state is GitaVerseLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  } else if (state is GitaVerseError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is GitaVerseLoaded) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 24, // Reduced bottom padding since no FAB
                      ),
                      itemCount: state.verses.length,
                      itemBuilder: (context, index) {
                        final verse = state.verses[index];
                        return _buildVerseCard(
                          context,
                          verse,
                          state.verses,
                          lastVerse,
                          index, // Passed index to apply specific gradient
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(
    BuildContext context,
    dynamic verse,
    List<dynamic> allVerses,
    String? lastVerseString,
    int index,
  ) {
    // Determine gradient based on index (cycling through 3 colors as shown in the design)
    final List<List<Color>> _cardGradients = [
      [const Color(0xFF133621), const Color(0xFF0C2415)], // Dark Green
      [const Color(0xFF4A4A4A), const Color(0xFF2A2A2A)], // Dark Grey
      [const Color(0xFF7A4A06), const Color(0xFF442800)], // Dark Brown/Gold
    ];
    final gradientColors = _cardGradients[index % _cardGradients.length];

    // Determine if this is the last read verse
    final bool isLastVisited = verse.shlokaNumber == lastVerseString &&
        widget.chapter.chapterNumber ==
            StorageService.getInt('gita_last_chapter_number');

    // Display "Last Read XX:XX PM Date" (using static placeholders like in the previous screen or generic text since timestamps are not stored properly)
    final String lastReadText = "Last Read • Recent";

    return GestureDetector(
      onTapDown: (details) => _tapPosition = details.globalPosition,
      onLongPress: () => _showAskKrishnaPopup(context, verse, _tapPosition),
      onTap: () async {
        List<VerseModel> siblings = [];
        if (allVerses is List<VerseModel>) {
          siblings = allVerses;
        } else {
          siblings = allVerses.map((e) => e as VerseModel).toList();
        }

        // Save last-read chapter when navigating to a verse
        if (widget.chapter.chapterNumber != null) {
          StorageService.setInt(
            'gita_last_chapter_number',
            widget.chapter.chapterNumber!,
          );
        }
        if (widget.chapter.name != null) {
          StorageService.setString(
            'gita_last_chapter_name',
            widget.chapter.name!,
          );
        }

        await Get.to(
          () => GitaShlokaDetailScreen(
            verseId: verse.id ?? '',
            verse: verse,
            siblingVerses: siblings,
          ),
        );
        // Refresh to show updated "Last visited" label and header
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White badge for verse number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Verses ${widget.chapter.chapterNumber}.${verse.shlokaNumber}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    verse.sanskritShloka ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFF1C453), // Gold arrow
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              thickness: 1,
              color: Colors.white.withOpacity(0.2), // Subtle divider line
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLastVisited)
                  Text(
                    lastReadText,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6), // Greyish text
                    ),
                  )
                else
                  const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
