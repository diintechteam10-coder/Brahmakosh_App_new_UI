import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../ai_rashmi/ai_rashmi_chat.dart';
import '../data/repositories/gita_repository.dart';
import '../bloc/chapter/gita_chapter_bloc.dart';
import '../bloc/chapter/gita_chapter_event.dart';
import '../bloc/chapter/gita_chapter_state.dart';
import 'gita_verse_list_screen.dart';

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

class _GitaChapterView extends StatelessWidget {
  const _GitaChapterView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6), // Light orange/cream background
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
                      padding: const EdgeInsets.all(16),
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
                  bottomRight: Radius.circular(20)
                )
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _roundIcon(Icons.arrow_back_ios_new_outlined, () => Navigator.pop(context)),
            ),
            Positioned(
              top: 12,
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
                    style: TextStyle(fontSize: 14, color: Color(0xFF8B4513),fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // Continue Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F2D),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topLeft: Radius.circular(20)
                    )
                ),
                child: Row(
                  children: const [
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
                          'Last read: Ch.01 Verse 1.3',
                          style: TextStyle(
                              color: Color(0xFF8B4513),
                            fontSize: 11,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    // Icon(Icons.arrow_forward_ios,
                    //     color: Colors.white, size: 14),
                  ],
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
      onTap: () {
        Get.to(() => GitaVerseListScreen(chapter: chapter));
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
        Icon(Icons.arrow_forward_ios,
            color: Color(0xFF8B4513), size: 14),
          ],
        ),
      ),
    );
  }
}
