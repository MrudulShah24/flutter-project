// lib/features/leaderboard/widgets/leaderboard_list_item.dart

import 'package:flutter/material.dart';

class LeaderboardListItem extends StatelessWidget {
  final int rank;
  final String name;
  final int score;

  const LeaderboardListItem({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
  });

  // Helper to get styling for top 3 ranks
  Widget _getRankIcon(BuildContext context) {
    final colors = [Colors.amber, Colors.grey[400], const Color(0xFFCD7F32)];
    final icons = [Icons.emoji_events, Icons.emoji_events, Icons.emoji_events];

    if (rank <= 3) {
      return Icon(icons[rank - 1], color: colors[rank - 1]);
    } else {
      return Text(
        rank.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isTopThree = rank <= 3;

    return Card(
      elevation: isTopThree ? 2 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isTopThree ? theme.colorScheme.surface.withValues(alpha: 0.5) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isTopThree ? BorderSide(color: (const [Colors.amber, Colors.grey, Color(0xFFCD7F32)])[rank-1], width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Center(child: _getRankIcon(context)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '$score pts',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}