import 'package:clarity/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:clarity/features/q_and_a/models/models.dart';
import 'package:clarity/features/q_and_a/widgets/answer_card.dart';
import 'package:clarity/features/q_and_a/widgets/audio_recorder_sheet.dart';
import 'package:clarity/features/q_and_a/widgets/question_card.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;
  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen>
    with SingleTickerProviderStateMixin {
  late List<Answer> _answers;
  late AnimationController _fabController;
  bool _isFabMenuOpen = false;
  final MediaService _mediaService = MediaService();

  @override
  void initState() {
    super.initState();
    _answers = List<Answer>.from(widget.question.answers);
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
      if (_isFabMenuOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  void _showAnswerSheet() {
    if (_isFabMenuOpen) _toggleFabMenu();
    final answerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Your Answer',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                      hintText: 'Type your answer here...'),
                  maxLines: 5,
                  minLines: 3,
                  autofocus: true),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (answerController.text.isNotEmpty) {
                      setState(() {
                        _answers.add(Answer(
                          text: answerController.text,
                          author: 'You',
                          isOwnAnswer: true,));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Post Answer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickVideo() async {
    if (_isFabMenuOpen) _toggleFabMenu();
    final file = await _mediaService.pickVideoFromCamera();
    if (file != null) {
      setState(() {
        _answers.add(Answer(
          text: '',
          author: 'You',
          isOwnAnswer: true,
          attachmentType: AttachmentType.video,
          attachedFilePath: file.path,
        ));
      });
    }
  }

  void _recordAudio() async {
    if (_isFabMenuOpen) _toggleFabMenu();
    final String? filePath = await showModalBottomSheet(
      context: context,
      builder: (context) => const AudioRecorderSheet(),
    );

    if (filePath != null) {
      setState(() {
        _answers.add(Answer(
          text: '',
          author: 'You',
          isOwnAnswer: true,
          attachmentType: AttachmentType.audio,
          attachedFilePath: filePath,
        ));
      });
    }
  }

  void _handleAnswerVote(Answer answer, bool isUpvote) {
    setState(() {
      final newVote = isUpvote ? UserVote.up : UserVote.down;

      if (newVote == answer.myVote) {
        answer.myVote = UserVote.none;
        if (isUpvote) {
          answer.upvotes--;
        } else {
          answer.downvotes--;
        }
      } else {
        if (answer.myVote == UserVote.up) {
          answer.upvotes--;
        }
        if (answer.myVote == UserVote.down) {
          answer.downvotes--;
        }

        answer.myVote = newVote;
        if (isUpvote) {
          answer.upvotes++;
        } else {
          answer.downvotes++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      floatingActionButton: widget.question.isOwnQuestion
          ? null
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFabMenuItem(
              icon: Icons.mic,
              label: 'Audio',
              visible: _isFabMenuOpen,
              onPressed: _recordAudio),
          _buildFabMenuItem(
              icon: Icons.videocam,
              label: 'Video',
              visible: _isFabMenuOpen,
              onPressed: _pickVideo),
          _buildFabMenuItem(
              icon: Icons.edit,
              label: 'Text',
              visible: _isFabMenuOpen,
              onPressed: _showAnswerSheet),
          FloatingActionButton(
            onPressed: _toggleFabMenu,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _fabController,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: QuestionCard(
                    questionText: widget.question.text,
                    author: widget.question.author,
                    upvotes: widget.question.upvotes,
                    downvotes: widget.question.downvotes,
                    answerCount: _answers.length,
                    myVote: widget.question.myVote,
                    onAnswersTap: () {},
                    attachedFilePath: widget.question.attachedFilePath,
                    attachmentType: widget.question.attachmentType,
                    votingEnabled: false,
                    onVote: (isUpvote) {},
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text("Answers",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final answer = _answers[index];
                    return AnswerCard(
                      answer: answer,
                      onVote: (isUpvote) {
                        _handleAnswerVote(answer, isUpvote);
                      },
                    );
                  },
                  childCount: _answers.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          if (_isFabMenuOpen)
            GestureDetector(
              onTap: _toggleFabMenu,
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
        ],
      ),
    );
  }

  Widget _buildFabMenuItem(
      {required IconData icon,
        required String label,
        required bool visible,
        required VoidCallback onPressed}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: visible ? 1.0 : 0.0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (visible)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(label),
              ),
            const SizedBox(width: 12),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: onPressed,
              child: Icon(icon),
            ),
          ],
        ),
      ),
    );
  }
}