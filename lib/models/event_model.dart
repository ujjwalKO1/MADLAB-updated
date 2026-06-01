class EventModel {
  final String id;
  final String name;
  final String clubName;
  final String applicationType; // 'Registration' or 'Volunteering'
  final String formLink;
  final String imagePath;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.name,
    required this.clubName,
    required this.applicationType,
    required this.formLink,
    required this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
