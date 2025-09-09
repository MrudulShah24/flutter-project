// lib/features/q_and_a/models/models.dart

enum AttachmentType { none, audio, video }
enum UserVote { none, up, down }

class Reply {
  final String author;
  final String text;
  const Reply({required this.author, required this.text});
}

class Answer {
  String text;
  final String author;
  int upvotes;
  int downvotes;
  final bool isOwnAnswer;
  final List<Reply> replies;
  final String? attachedFilePath;
  final AttachmentType attachmentType;
  UserVote myVote;

  Answer({
    required this.text,
    required this.author,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isOwnAnswer = false,
    this.replies = const [],
    this.attachedFilePath,
    this.attachmentType = AttachmentType.none,
    this.myVote = UserVote.none,
  });
}

class Question {
  String text;
  final String author;
  int upvotes;
  int downvotes;
  final List<Answer> answers;
  final bool isOwnQuestion;
  final String? attachedFilePath;
  final AttachmentType attachmentType;
  UserVote myVote;

  Question({
    required this.text,
    required this.author,
    this.upvotes = 0,
    this.downvotes = 0,
    required this.answers,
    this.isOwnQuestion = false,
    this.attachedFilePath,
    this.attachmentType = AttachmentType.none,
    this.myVote = UserVote.none,
  });
}