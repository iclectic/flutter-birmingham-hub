import 'package:equatable/equatable.dart';

class CfpSubmission extends Equatable {
  final String id;
  final String title;
  final String description;
  final String speakerName;
  final String speakerEmail;
  final String? speakerBio;
  final DateTime submittedAt;
  final SubmissionStatus status;
  final String? reviewNotes;

  const CfpSubmission({
    required this.id,
    required this.title,
    required this.description,
    required this.speakerName,
    required this.speakerEmail,
    this.speakerBio,
    required this.submittedAt,
    this.status = SubmissionStatus.pending,
    this.reviewNotes,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        speakerName,
        speakerEmail,
        speakerBio,
        submittedAt,
        status,
        reviewNotes,
      ];

  CfpSubmission copyWith({
    String? id,
    String? title,
    String? description,
    String? speakerName,
    String? speakerEmail,
    String? speakerBio,
    DateTime? submittedAt,
    SubmissionStatus? status,
    String? reviewNotes,
  }) {
    return CfpSubmission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      speakerName: speakerName ?? this.speakerName,
      speakerEmail: speakerEmail ?? this.speakerEmail,
      speakerBio: speakerBio ?? this.speakerBio,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'speakerName': speakerName,
      'speakerEmail': speakerEmail,
      'speakerBio': speakerBio,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.name,
      'reviewNotes': reviewNotes,
    };
  }

  factory CfpSubmission.fromJson(Map<String, dynamic> json) {
    return CfpSubmission(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      speakerName: json['speakerName'] as String,
      speakerEmail: json['speakerEmail'] as String,
      speakerBio: json['speakerBio'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubmissionStatus.pending,
      ),
      reviewNotes: json['reviewNotes'] as String?,
    );
  }
}

enum SubmissionStatus {
  pending,
  underReview,
  accepted,
  rejected,
}
