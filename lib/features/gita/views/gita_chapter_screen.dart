import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFFFF5E6), // Light orange/cream background
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
      body: SafeArea(
        top: false,
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
                      padding: const EdgeInsets.only(left: 16,right: 16,top: 16, bottom: 50),
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
        // Top Image
        Stack(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/geeta_background.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 12,
              child: _roundIcon(
                Icons.arrow_back_ios_new_outlined,
                () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 30,
              right: 12,
              child: _roundIcon(Icons.menu, () {}),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16, top: 16),
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
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '18 Chapters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.bold,
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
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F2D),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            lastReadLabel,
                            style: TextStyle(
                              color: Color(0xFF8B4513),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, dynamic chapter, int index) {
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Index
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1DE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.name ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${chapter.shlokaCount ?? 0} Verses',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 3 / (chapter.shlokaCount ?? 1),
                            minHeight: 4,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFF9F2D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '3/${chapter.shlokaCount ?? 0}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Text(
                  //     '3/${chapter.shlokaCount ?? 0}',
                  //     style: const TextStyle(
                  //       fontSize: 10,
                  //       color: Colors.grey,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Icon(Icons.arrow_forward_ios, color: Color(0xFF8B4513), size: 14),
          ],
        ),
      ),
    );
  }
}
