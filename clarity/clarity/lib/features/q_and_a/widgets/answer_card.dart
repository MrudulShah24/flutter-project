// lib/features/q_and_a/widgets/answer_card.dart

import 'package:clarity/features/q_and_a/models/models.dart';
import 'package:clarity/features/q_and_a/widgets/reply_card.dart';
import 'package:clarity/features/q_and_a/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';

class AnswerCard extends StatefulWidget {
  final Answer answer;
  final Function(bool isUpvote) onVote;

  const AnswerCard({
    super.key,
    required this.answer,
    required this.onVote,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  bool _isExpanded = false;
  final _replyController = TextEditingController();
  late final List<Reply> _localReplies;

  @override
  void initState() {
    super.initState();
    _localReplies = List<Reply>.from(widget.answer.replies);
  }

  void _postReply() {
    if (_replyController.text.isNotEmpty) {
      setState(() {
        _localReplies.add(Reply(author: "You", text: _replyController.text));
        _replyController.clear();
      });
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot send an empty reply."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final answer = widget.answer;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.8),
                  child: Text(answer.author.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Text(answer.author,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: Colors.grey[400])),
              ],
            ),
            const SizedBox(height: 16),
            if (answer.attachedFilePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: VideoPlayerWidget(videoPath: answer.attachedFilePath!),
              ),
            if (answer.text.isNotEmpty)
              Text(answer.text, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(Icons.reply, size: 16, color: Colors.grey[400]),
                  label: Text("Reply (${_localReplies.length})",
                      style: TextStyle(color: Colors.grey[400])),
                ),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded),
                    color: answer.myVote == UserVote.up ? primaryColor : Colors.grey[400],
                    onPressed: answer.isOwnAnswer ? null : () => widget.onVote(true)),
                Text(answer.upvotes.toString(),
                    style: TextStyle(color: answer.myVote == UserVote.up ? primaryColor : Colors.grey[400])),
                const SizedBox(width: 16),
                IconButton(
                    icon: const Icon(Icons.arrow_downward_rounded),
                    color: answer.myVote == UserVote.down ? primaryColor : Colors.grey[400],
                    onPressed: answer.isOwnAnswer ? null : () => widget.onVote(false)),
                Text(answer.downvotes.toString(),
                    style: TextStyle(color: answer.myVote == UserVote.down ? primaryColor : Colors.grey[400])),
              ],
            ),
            if (_isExpanded) _buildRepliesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          const Divider(),
          ..._localReplies.map(
                  (reply) => ReplyCard(author: reply.author, text: reply.text)),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 8),
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Add a reply...',
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, size: 20),
                  onPressed: _postReply,
                ),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}