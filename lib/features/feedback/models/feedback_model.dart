import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FeedbackModel extends Equatable {
  final String id;
  final String eventId;
  final String talkId;
  final String? talkTitle;
  final String? speakerId;
  final String? speakerName;
  final int rating;
  final String? positiveComments;
  final String? improvementComments;
  final DateTime submittedAt;
  final String deviceId;

  const FeedbackModel({
    required this.id,
    required this.eventId,
    required this.talkId,
    this.talkTitle,
    this.speakerId,
    this.speakerName,
    required this.rating,
    this.positiveComments,
    this.improvementComments,
    required this.submittedAt,
    required this.deviceId,
  });

  FeedbackModel copyWith({
    String? id,
    String? eventId,
    String? talkId,
    String? talkTitle,
    String? speakerId,
    String? speakerName,
    int? rating,
    String? positiveComments,
    String? improvementComments,
    DateTime? submittedAt,
    String? deviceId,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      talkId: talkId ?? this.talkId,
      talkTitle: talkTitle ?? this.talkTitle,
      speakerId: speakerId ?? this.speakerId,
      speakerName: speakerName ?? this.speakerName,
      rating: rating ?? this.rating,
      positiveComments: positiveComments ?? this.positiveComments,
      improvementComments: improvementComments ?? this.improvementComments,
      submittedAt: submittedAt ?? this.submittedAt,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'talkId': talkId,
      'talkTitle': talkTitle,
      'speakerId': speakerId,
      'speakerName': speakerName,
      'rating': rating,
      'positiveComments': positiveComments,
      'improvementComments': improvementComments,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'deviceId': deviceId,
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json, String id) {
    return FeedbackModel(
      id: id,
      eventId: json['eventId'] as String,
      talkId: json['talkId'] as String,
      talkTitle: json['talkTitle'] as String?,
      speakerId: json['speakerId'] as String?,
      speakerName: json['speakerName'] as String?,
      rating: json['rating'] as int,
      positiveComments: json['positiveComments'] as String?,
      improvementComments: json['improvementComments'] as String?,
      submittedAt: (json['submittedAt'] as Timestamp).toDate(),
      deviceId: json['deviceId'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        talkId,
        talkTitle,
        speakerId,
        speakerName,
        rating,
        positiveComments,
        improvementComments,
        submittedAt,
        deviceId,
      ];
}
