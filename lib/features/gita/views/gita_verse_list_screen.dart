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
      backgroundColor: const Color(0xFFFFF5E6),
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
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
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
                      padding: const EdgeInsets.only(left: 16, right: 16,top: 16, bottom: 60),
                      itemCount: state.verses.length,
                      itemBuilder: (context, index) {
                        final verse = state.verses[index];
                        return _buildVerseCard(
                          context,
                          verse,
                          state.verses,
                          lastVerse,
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
  ) {
    return GestureDetector(
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Verses ${widget.chapter.chapterNumber}.${verse.shlokaNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  verse.sanskritShloka ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4037),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.left,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF8B4513),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 0.5),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (verse.shlokaNumber == lastVerseString &&
                    widget.chapter.chapterNumber ==
                        StorageService.getInt('gita_last_chapter_number'))
                  const Text(
                    'Last visited verse',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B4513),
                      fontStyle: FontStyle.italic,
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
