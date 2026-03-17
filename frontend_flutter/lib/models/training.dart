/// Backend training record used for the rotating two-minute training feature.
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
