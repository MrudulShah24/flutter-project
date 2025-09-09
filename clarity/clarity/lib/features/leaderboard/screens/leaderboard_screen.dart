// lib/features/leaderboard/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:clarity/features/leaderboard/widgets/leaderboard_list_item.dart';

// Simple data model for a leaderboard entry
class UserScore {
  final String name;
  final int score;

  // --- THIS IS THE FIX ---
  // Add the 'const' keyword to the constructor
  const UserScore({required this.name, required this.score});
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  // --- Mock Data ---
  // Now that the constructor is const, these lists are valid
  final List<UserScore> weeklyScores = const [
    UserScore(name: 'Alex', score: 150),
    UserScore(name: 'Chris', score: 125),
    UserScore(name: 'You', score: 110),
    UserScore(name: 'Jane Doe', score: 95),
    UserScore(name: 'John Smith', score: 80),
  ];
  final List<UserScore> monthlyScores = const [
    UserScore(name: 'Jane Doe', score: 850),
    UserScore(name: 'Chris', score: 790),
    UserScore(name: 'Alex', score: 720),
    UserScore(name: 'John Smith', score: 650),
    UserScore(name: 'You', score: 610),
  ];
  final List<UserScore> allTimeScores = const [
    UserScore(name: 'Chris', score: 5420),
    UserScore(name: 'Jane Doe', score: 5150),
    UserScore(name: 'John Smith', score: 4890),
    UserScore(name: 'Alex', score: 4500),
    UserScore(name: 'You', score: 4210),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'All-Time'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeaderboardList(weeklyScores),
            _buildLeaderboardList(monthlyScores),
            _buildLeaderboardList(allTimeScores),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(List<UserScore> scores) {
    return ListView.builder(
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final user = scores[index];
        return LeaderboardListItem(
          rank: index + 1,
          name: user.name,
          score: user.score,
        );
      },
    );
  }
}