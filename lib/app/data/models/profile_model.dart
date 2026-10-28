class Profile {
  final int id;
  final String username;
  final String role;
  final int activeSubjectsCount;

  Profile({
    required this.id,
    required this.username,
    required this.role,
    required this.activeSubjectsCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      activeSubjectsCount: json['active_subjects_count'] ?? 0,
    );
  }
}
