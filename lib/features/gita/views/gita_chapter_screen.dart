import 'package:brahmakosh/features/gita/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../ai_rashmi/ai_rashmi_chat.dart';

import '../data/repositories/gita_repository.dart';
import '../data/models/chapter_model.dart';
import '../bloc/chapter/gita_chapter_bloc.dart';
import '../bloc/chapter/gita_chapter_event.dart';
import '../bloc/chapter/gita_chapter_state.dart';
import 'gita_verse_list_screen.dart';
import 'package:brahmakosh/core/services/storage_service.dart';

class GitaChapterScreen extends StatelessWidget {
  const GitaChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GitaChapterBloc(repository: GitaRepository())
            ..add(FetchGitaChapters()),
      child: const _GitaChapterView(),
    );
  }
}

class _GitaChapterView extends StatefulWidget {
  const _GitaChapterView();

  @override
  State<_GitaChapterView> createState() => _GitaChapterViewState();
}

class _GitaChapterViewState extends State<_GitaChapterView> {
  int? _lastChapter;
  String? _lastVerse;

  @override
  void initState() {
    super.initState();
    _lastChapter = StorageService.getInt('gita_last_chapter_number');
    _lastVerse = StorageService.getString('gita_last_verse_number');
  }

  @override
  Widget build(BuildContext context) {
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
          "Ask Krishna",
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<GitaChapterBloc, GitaChapterState>(
                builder: (context, state) {
                  if (state is GitaChapterLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  } else if (state is GitaChapterError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is GitaChapterLoaded) {
                    return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 24,
                        ),
                        itemCount: state.chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = state.chapters[index];
                        return _buildChapterCard(context, chapter, index + 1);
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

  Widget _buildHeader(BuildContext context) {
    // Build dynamic "last read" label
    final String lastReadLabel;
    if (_lastChapter != null && _lastVerse != null) {
      final chLabel = _lastChapter.toString().padLeft(2, '0');
      lastReadLabel = 'Last read: Ch.$chLabel Verse $_lastVerse';
    } else {
      lastReadLabel = 'Start reading';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bhagavad Gita',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1C453), // Gold text
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '18 Chapters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              // Continue Card — navigates to last-read chapter
              GestureDetector(
                onTap: () async {
                  if (_lastChapter != null) {
                    // Find the matching chapter from the BLoC state
                    final state = context.read<GitaChapterBloc>().state;
                    if (state is GitaChapterLoaded) {
                      final match = state.chapters
                          .cast<ChapterModel?>()
                          .firstWhere(
                            (c) => c?.chapterNumber == _lastChapter,
                            orElse: () => null,
                          );
                      if (match != null) {
                        await Get.to(() => GitaVerseListScreen(chapter: match));
                        setState(() {
                          _lastChapter = StorageService.getInt(
                            'gita_last_chapter_number',
                          );
                          _lastVerse = StorageService.getString(
                            'gita_last_verse_number',
                          );
                        });
                      }
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1C453), // Gold button
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lastReadLabel,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: WavyDivider(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, dynamic chapter, int index) {
    final completedVerses = StorageService.getInt('gita_chapter_${chapter.chapterNumber}_completed') ?? 0;
    final total = chapter.shlokaCount ?? 1;

    // Simulate formatting last read details as shown in design if completed
    final bool hasProgress = completedVerses > 0;
    final String lastReadVerseStr = hasProgress ? "Last Read - Verse ${chapter.chapterNumber}.$completedVerses" : "";
    // Note: Currently no recorded timestamp for reading stored in StorageService by default logic. Leaving blank or simulated.
    final String lastReadTimestamp = hasProgress ? "Recent" : "";

    return GestureDetector(
      onTap: () async {
        await Get.to(() => GitaVerseListScreen(chapter: chapter));
        // Refresh state after returning
        setState(() {
          _lastChapter = StorageService.getInt('gita_last_chapter_number');
          _lastVerse = StorageService.getString('gita_last_verse_number');
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131313), // Dark item background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Index
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C), // Slightly lighter dark background
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFF1C453), // Gold text
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.name ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${chapter.shlokaCount ?? 0} Verses',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),

                      // Progress
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: completedVerses / total,
                                minHeight: 4,
                                backgroundColor: const Color(0xFF2C2C2C),
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFE0E0E0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$completedVerses/${chapter.shlokaCount ?? 0}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFFF1C453), size: 14),
              ],
            ),
            
            // "Last read" bottom info row
            if (hasProgress) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lastReadVerseStr,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    lastReadTimestamp,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}


