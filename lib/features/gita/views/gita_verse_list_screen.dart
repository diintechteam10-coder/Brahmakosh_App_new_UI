import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../data/repositories/gita_repository.dart';
import '../data/models/chapter_model.dart';
import '../data/models/verse_model.dart';
import '../bloc/verse/gita_verse_bloc.dart';
import '../bloc/verse/gita_verse_event.dart';
import '../bloc/verse/gita_verse_state.dart';
import 'gita_shloka_detail_screen.dart';

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

class _GitaVerseListView extends StatelessWidget {
  final ChapterModel chapter;

  const _GitaVerseListView({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildHeaderCard(context),
            ),
            const SizedBox(height: 20),
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
                      padding: const EdgeInsets.all(16),
                      itemCount: state.verses.length,
                      itemBuilder: (context, index) {
                        final verse = state.verses[index];
                        return _buildVerseCard(context, verse, state.verses);
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

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/header_bg.png'), // Reuse image
          fit: BoxFit.cover,
          opacity: 0.2, // Subtle bg
        ),
        color: const Color(0xFFFFF0D6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            chapter.name ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
              fontFamily: 'Serif',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Chapters ${chapter.chapterNumber}',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8B4513).withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 0.5, color: Colors.grey),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total - ${chapter.shlokaCount} Verses',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                '10 mins read', // Placeholder
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(
    BuildContext context,
    dynamic verse,
    List<dynamic> allVerses,
  ) {
    return GestureDetector(
      onTap: () {
        List<VerseModel> siblings = [];
        if (allVerses is List<VerseModel>) {
          siblings = allVerses;
        } else {
          siblings = allVerses.map((e) => e as VerseModel).toList();
        }

        Get.to(
          () => GitaShlokaDetailScreen(
            verseId: verse.id ?? '',
            verse: verse,
            siblingVerses: siblings,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
                'Verses ${chapter.chapterNumber}.${verse.shlokaNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              verse.sanskritShloka ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 0.5),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last visited verse',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B4513),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Color(0xFF8B4513),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
