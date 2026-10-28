import 'subject_model.dart';

class Enrollment {
  final int id;
  final Subject subject;
  final String progressPercent;
  final String enrolledAt;
  final String expiresAt;

  Enrollment({
    required this.id,
    required this.subject,
    required this.progressPercent,
    required this.enrolledAt,
    required this.expiresAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? 0,
      subject: Subject.fromJson(json['subject'] ?? {}),
      progressPercent: json['progress_percent']?.toString() ?? '0.0',
      enrolledAt: json['enrolled_at'] ?? '',
      expiresAt: json['expires_at'] ?? '',
    );
  }
}
