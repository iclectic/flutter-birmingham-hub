import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAgendaItem {
  String id;
  String title;
  String? description;
  DateTime startTime;
  DateTime endTime;
  String location;
  String? speakerId;
  String? talkId;
  String type;
  int? trackNumber;
  bool isCustom;

  AdminAgendaItem({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.speakerId,
    this.talkId,
    required this.type,
    this.trackNumber,
    this.isCustom = false,
  });

  Duration get duration {
    return endTime.difference(startTime);
  }

  bool hasOverlapWith(AdminAgendaItem other) {
    // Check if this item overlaps with another item in the same track
    if (trackNumber != other.trackNumber) {
      return false; // Different tracks can have overlapping times
    }
    
    // Check for overlap
    return (startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime));
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
      'type': type,
      'trackNumber': trackNumber,
      'isCustom': isCustom,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'speakerId': speakerId,
      'talkId': talkId,
      'type': type,
      'trackNumber': trackNumber,
      'isCustom': isCustom,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AdminAgendaItem.fromJson(Map<String, dynamic> json) {
    return AdminAgendaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      speakerId: json['speakerId'] as String?,
      talkId: json['talkId'] as String?,
      type: json['type'] as String,
      trackNumber: json['trackNumber'] as int?,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  factory AdminAgendaItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminAgendaItem(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] as String,
      speakerId: data['speakerId'] as String?,
      talkId: data['talkId'] as String?,
      type: data['type'] as String,
      trackNumber: data['trackNumber'] as int?,
      isCustom: data['isCustom'] as bool? ?? false,
    );
  }

  AdminAgendaItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? speakerId,
    String? talkId,
    String? type,
    int? trackNumber,
    bool? isCustom,
  }) {
    return AdminAgendaItem(
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
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
