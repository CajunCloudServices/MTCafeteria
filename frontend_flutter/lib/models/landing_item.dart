/// A single announcement/reminder/event shown on the home screen.
class LandingItem {
  const LandingItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.startDate,
    required this.endDate,
  });

  final int id;
  final String type;
  final String title;
  final String content;
  final String startDate;
  final String endDate;

  factory LandingItem.fromJson(Map<String, dynamic> json) {
    return LandingItem(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }
}
