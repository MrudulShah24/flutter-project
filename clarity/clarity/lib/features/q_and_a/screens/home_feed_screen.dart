// lib/features/q_and_a/screens/home_feed_screen.dart

import 'package:clarity/features/q_and_a/models/models.dart';
import 'package:clarity/features/q_and_a/screens/question_detail_screen.dart';
import 'package:clarity/features/q_and_a/widgets/question_card.dart';
import 'package:clarity/features/auth/screens/landing_screen.dart';
import 'package:clarity/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:clarity/features/profile/screens/profile_screen.dart';
import 'package:clarity/services/media_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final _questionController = TextEditingController();
  final MediaService _mediaService = MediaService();
  PlatformFile? _attachedFile;
  late final FocusNode _questionFocusNode;

  final List<Question> _questions = [
    Question(
      text:
      'What are the best practices for state management in Flutter for a large-scale app?',
      author: 'Jane Doe',
      upvotes: 12,
      downvotes: 2,
      answers: [
        Answer(
          text: 'BLoC or Riverpod are top choices.',
          author: 'Chris',
          upvotes: 42,
          downvotes: 1,
          replies: [
            const Reply(author: "Jane Doe", text: "Thanks, Chris! That's helpful.")
          ],
        ),
        Answer(
          text: 'Provider is simpler for smaller projects.',
          author: 'Alex',
          upvotes: 15,
          downvotes: 5,
          attachmentType: AttachmentType.video,
          attachedFilePath: 'dummy/path/to/video.mp4',
        ),
      ],
    ),
    Question(
      text:
      'How can I optimize performance in a Flutter app with complex animations?',
      author: 'John Smith',
      upvotes: 5,
      downvotes: 0,
      answers: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _questionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _questionFocusNode.dispose();
    super.dispose();
  }

  void _postQuestion() {
    if (_questionController.text.isNotEmpty || _attachedFile != null) {
      setState(() {
        _questions.insert(
          0,
          Question(
            text: _questionController.text,
            author: 'You',
            answers: [],
            isOwnQuestion: true,
            attachedFilePath: _attachedFile?.path,
            // Determine attachment type based on file extension
            attachmentType: _attachedFile?.extension == 'mp4'
                ? AttachmentType.video
                : AttachmentType.audio,
          ),
        );
        _questionController.clear();
        _attachedFile = null;
      });
      _questionFocusNode.unfocus();
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingScreen()),
            (route) => false,
      );
    }
  }

  void _handleQuestionVote(Question question, bool isUpvote) {
    setState(() {
      final newVote = isUpvote ? UserVote.up : UserVote.down;
      if (newVote == question.myVote) {
        question.myVote = UserVote.none;
        if (isUpvote) {
          question.upvotes--;
        } else {
          question.downvotes--;
        }
      } else {
        if (question.myVote == UserVote.up) {
          question.upvotes--;
        }
        if (question.myVote == UserVote.down) {
          question.downvotes--;
        }
        question.myVote = newVote;
        if (isUpvote) {
          question.upvotes++;
        } else {
          question.downvotes++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'My Profile',
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(allQuestions: _questions)));
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Clarity'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.leaderboard_outlined),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen()));
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildAskQuestionCard(theme),
            const SizedBox(height: 20),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Recent Questions",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return QuestionCard(
                    questionText: question.text,
                    author: question.author,
                    upvotes: question.upvotes,
                    downvotes: question.downvotes,
                    answerCount: question.answers.length,
                    attachedFilePath: question.attachedFilePath,
                    attachmentType: question.attachmentType,
                    myVote: question.myVote,
                    onVote: (isUpvote) {
                      _handleQuestionVote(question, isUpvote);
                    },
                    onAnswersTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuestionDetailScreen(question: question),
                        ),
                      ).then((_) {
                        // This setState call forces the feed to refresh
                        // when you come back from the detail screen.
                        setState(() {});
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskQuestionCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _questionController,
                focusNode: _questionFocusNode,
                decoration: const InputDecoration(
                    hintText: 'What\'s on your mind?',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none),
                maxLines: 3,
                minLines: 1),
            if (_attachedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Chip(
                  label: Text(
                    _attachedFile!.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onDeleted: () => setState(() => _attachedFile = null),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        tooltip: 'Attach from Gallery',
                        icon:
                        Icon(Icons.attach_file, color: Colors.grey[400]),
                        onPressed: () async {
                          final file =
                          await _mediaService.pickFileFromGallery();
                          setState(() => _attachedFile = file);
                        }),
                    IconButton(
                        tooltip: 'Record Video',
                        icon: Icon(Icons.videocam_outlined,
                            color: Colors.grey[400]),
                        onPressed: () async {
                          // This would need conversion from XFile to PlatformFile
                        }),
                  ],
                ),
                ElevatedButton(
                    onPressed: _postQuestion, child: const Text('Post')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}