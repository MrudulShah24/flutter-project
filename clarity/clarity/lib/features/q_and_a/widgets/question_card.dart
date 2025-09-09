import 'package:clarity/features/q_and_a/models/models.dart';
import 'package:clarity/features/q_and_a/widgets/audio_player_widget.dart';
import 'package:clarity/features/q_and_a/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;
  final String author;
  final int upvotes;
  final int downvotes;
  final int answerCount;
  final VoidCallback onAnswersTap;
  final String? attachedFilePath;
  final Function(bool isUpvote) onVote;
  final UserVote myVote;
  final bool votingEnabled;
  final AttachmentType attachmentType;

  const QuestionCard({
    super.key,
    required this.questionText,
    required this.author,
    required this.upvotes,
    required this.downvotes,
    required this.answerCount,
    required this.onAnswersTap,
    this.attachedFilePath,
    required this.onVote,
    required this.myVote,
    this.votingEnabled = true,
    this.attachmentType = AttachmentType.none,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        backgroundColor: primaryColor,
                        child: Text(author.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 12),
                    Text(author,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 16),
                if (attachmentType != AttachmentType.none && attachedFilePath != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: attachmentType == AttachmentType.video
                        ? VideoPlayerWidget(videoPath: attachedFilePath!)
                        : AudioPlayerWidget(audioPath: attachedFilePath!),
                  ),
                if (questionText.isNotEmpty)
                  Text(questionText,
                      style:
                      theme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded),
                        color: myVote == UserVote.up ? primaryColor : Colors.grey[400],
                        onPressed: votingEnabled ? () => onVote(true) : null),
                    Text(upvotes.toString(),
                        style: TextStyle(color: myVote == UserVote.up ? primaryColor : Colors.grey[400])),
                    const SizedBox(width: 16),
                    IconButton(
                        icon: const Icon(Icons.arrow_downward_rounded),
                        color: myVote == UserVote.down ? primaryColor : Colors.grey[400],
                        onPressed: votingEnabled ? () => onVote(false) : null),
                    Text(downvotes.toString(),
                        style: TextStyle(color: myVote == UserVote.down ? primaryColor : Colors.grey[400])),
                  ],
                ),
                TextButton.icon(
                  icon: Icon(Icons.comment_outlined, color: Colors.grey[400]),
                  label: Text('$answerCount Answers',
                      style: TextStyle(color: Colors.grey[400])),
                  onPressed: onAnswersTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}