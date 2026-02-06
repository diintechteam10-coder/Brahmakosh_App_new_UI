import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/gita_repository.dart';
import '../data/models/verse_model.dart';
import '../bloc/detail/gita_detail_bloc.dart';
import '../bloc/detail/gita_detail_event.dart';
import '../bloc/detail/gita_detail_state.dart';

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
      // Context will trigger rebuild with new ID in BlocProvider key logic.
      // The BlocProvider with ValueKey will handle recreation and event addition.
      // context.read<GitaDetailBloc>().add(FetchGitaVerseDetail(_currentVerseId));
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(context, displayVerse),
                  const SizedBox(height: 24),
                  _buildNavigationButtons(),
                  const SizedBox(height: 24),
                  _buildContentCard(
                    'SANSKRIT VERSE (DEVANAGARI)',
                    displayVerse.sanskritShloka,
                    isSanskrit: true,
                  ),
                  _buildContentCard(
                    'SANSKRIT TRANSLITERATION',
                    displayVerse.sanskritTransliteration,
                  ),
                  _buildContentCard(
                    'HINDI TRANSLATION',
                    displayVerse.hindiMeaning,
                  ),
                  _buildContentCard(
                    'ENGLISH TRANSLATION',
                    displayVerse.englishMeaning,
                  ),
                  _buildContentCard('EXPLANATION', displayVerse.explanation),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VerseModel verse) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/header_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
        color: const Color(0xFFFFF0D6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            verse.chapterName ?? '',
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
            'Chapters ${verse.chapterNumber}',
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verse - ${verse.shlokaNumber}', // Should be 1.1 etc format if possible?
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              const Text('2 min read', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: hasPrev ? onPrev : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.orange.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Previous Verse'),
        ),
        ElevatedButton(
          onPressed: hasNext ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.orange.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Next Verse'),
        ),
      ],
    );
  }

  Widget _buildContentCard(
    String title,
    String? content, {
    bool isSanskrit = false,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSanskrit
            ? const Color(0xFFFBEBC8)
            : const Color(0xFFE8DCCA), // Different colors for cards
        borderRadius: BorderRadius.circular(
          20,
        ), // Asymmetric corners in design? Standard for now
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDAA520), // Golden/Dark Orange
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: Text(
              content,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.5,
                fontWeight: isSanskrit ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
