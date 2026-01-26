import 'package:cloud_firestore/cloud_firestore.dart';

class PublicEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String? venueAddress;
  final String? imageUrl;
  final bool isPublished;

  PublicEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.venue,
    this.venueAddress,
    this.imageUrl,
    this.isPublished = true,
  });

  factory PublicEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PublicEvent(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      venue: data['venue'] as String,
      venueAddress: data['venueAddress'] as String?,
      imageUrl: data['imageUrl'] as String?,
      isPublished: data['isPublished'] as bool? ?? false,
    );
  }
}
