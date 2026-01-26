import 'package:cloud_firestore/cloud_firestore.dart';

class PublicAgendaItem {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? speakerId;
  final String? talkId;
  final String type;
  final int? trackNumber;
  final bool isCustom;

  PublicAgendaItem({
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

  factory PublicAgendaItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PublicAgendaItem(
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
}
