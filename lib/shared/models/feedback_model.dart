import 'package:equatable/equatable.dart';

class Feedback extends Equatable {
  final String id;
  final String? userId;
  final String? talkId;
  final String? speakerId;
  final String? eventId;
  final int rating;
  final String? comment;
  final DateTime submittedAt;
  final List<String> tags;

  const Feedback({
    required this.id,
    this.userId,
    this.talkId,
    this.speakerId,
    this.eventId,
    required this.rating,
    this.comment,
    required this.submittedAt,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        talkId,
        speakerId,
        eventId,
        rating,
        comment,
        submittedAt,
        tags,
      ];

  Feedback copyWith({
    String? id,
    String? userId,
    String? talkId,
    String? speakerId,
    String? eventId,
    int? rating,
    String? comment,
    DateTime? submittedAt,
    List<String>? tags,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      talkId: talkId ?? this.talkId,
      speakerId: speakerId ?? this.speakerId,
      eventId: eventId ?? this.eventId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      submittedAt: submittedAt ?? this.submittedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'talkId': talkId,
      'speakerId': speakerId,
      'eventId': eventId,
      'rating': rating,
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      talkId: json['talkId'] as String?,
      speakerId: json['speakerId'] as String?,
      eventId: json['eventId'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
