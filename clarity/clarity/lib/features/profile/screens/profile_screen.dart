import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clarity/features/q_and_a/models/models.dart';
import 'package:clarity/features/q_and_a/widgets/question_card.dart';
import 'package:clarity/features/q_and_a/widgets/answer_card.dart';
import 'package:clarity/features/q_and_a/screens/question_detail_screen.dart';
import 'package:clarity/features/profile/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final List<Question> allQuestions;
  const ProfileScreen({super.key, required this.allQuestions});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = 'You';
  int score = 4210;

  List<Question> _userQuestions = [];
  List<Answer> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _filterUserContent();
  }

  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        username = prefs.getString('username') ?? 'You';
      });
    }
  }

  void _filterUserContent() {
    final filteredQuestions =
    widget.allQuestions.where((q) => q.author == 'You').toList();

    final filteredAnswers = <Answer>[];
    for (var question in widget.allQuestions) {
      filteredAnswers.addAll(question.answers.where((a) => a.author == 'You'));
    }

    setState(() {
      _userQuestions = filteredQuestions;
      _userAnswers = filteredAnswers;
    });
  }

  void _navigateToEditProfile() async {
    final newUsername = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentUsername: username),
      ),
    );

    if (newUsername != null && newUsername.isNotEmpty) {
      setState(() {
        username = newUsername;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildProfileHeader(context)),
            ];
          },
          body: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'My Questions'),
                  Tab(text: 'My Answers'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildQuestionsList(),
                    _buildAnswersList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              username.substring(0, 1),
              style:
              theme.textTheme.headlineLarge?.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          Text(username, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Score', score.toString()),
              _buildStatColumn('Questions', _userQuestions.length.toString()),
              _buildStatColumn('Answers', _userAnswers.length.toString()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Profile'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuestionsList() {
    if (_userQuestions.isEmpty) {
      return const Center(child: Text("You haven't posted any questions yet."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _userQuestions.length,
      itemBuilder: (context, index) {
        final question = _userQuestions[index];
        return QuestionCard(
          questionText: question.text,
          author: question.author,
          upvotes: question.upvotes,
          downvotes: question.downvotes,
          answerCount: question.answers.length,
          attachedFilePath: question.attachedFilePath,
          myVote: question.myVote,
          votingEnabled: !question.isOwnQuestion,
          attachmentType: question.attachmentType,
          onVote: (isUpvote) {},
          onAnswersTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        QuestionDetailScreen(question: question)));
          },
        );
      },
    );
  }

  Widget _buildAnswersList() {
    if (_userAnswers.isEmpty) {
      return const Center(child: Text("You haven't posted any answers yet."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _userAnswers.length,
      itemBuilder: (context, index) {
        final answer = _userAnswers[index];
        return AnswerCard(
          answer: answer,
          onVote: (isUpvote) {},
        );
      },
    );
  }
}