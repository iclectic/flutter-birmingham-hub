import 'package:equatable/equatable.dart';

class AgendaItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? speakerId;
  final String? talkId;
  final AgendaItemType type;
  final int? trackNumber;

  const AgendaItem({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.speakerId,
    this.talkId,
    this.type = AgendaItemType.talk,
    this.trackNumber,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        endTime,
        location,
        speakerId,
        talkId,
        type,
        trackNumber,
      ];

  AgendaItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? speakerId,
    String? talkId,
    AgendaItemType? type,
    int? trackNumber,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      speakerId: speakerId ?? this.speakerId,
      talkId: talkId ?? this.talkId,
      type: type ?? this.type,
      trackNumber: trackNumber ?? this.trackNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'speakerId': speakerId,
      'talkId': talkId,
      'type': type.name,
      'trackNumber': trackNumber,
    };
  }

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      speakerId: json['speakerId'] as String?,
      talkId: json['talkId'] as String?,
      type: AgendaItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AgendaItemType.talk,
      ),
      trackNumber: json['trackNumber'] as int?,
    );
  }
}

enum AgendaItemType {
  talk,
  workshop,
  break,
  registration,
  networking,
  keynote,
  panel,
  other,
}
