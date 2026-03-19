/// Legacy backend training record used by older prototype dashboard flows.
///
/// The active detailed 2-minute training viewer now uses the manual local
/// corpus in `training_text_data.dart`.
class Training {
  const Training({
    required this.id,
    required this.title,
    required this.content,
    required this.assignedDate,
  });

  final int id;
  final String title;
  final String content;
  final String assignedDate;

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      assignedDate: json['assignedDate'] as String,
    );
  }
}
