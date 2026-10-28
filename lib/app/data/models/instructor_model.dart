class Instructor {
  final int id;
  final String username;
  final String fullName;

  Instructor({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}
