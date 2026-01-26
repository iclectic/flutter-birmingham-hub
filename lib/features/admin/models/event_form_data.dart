class EventFormData {
  String? id;
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  String? venue;
  String? venueAddress;
  String? imageUrl;
  bool isPublished;

  EventFormData({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.venue,
    this.venueAddress,
    this.imageUrl,
    this.isPublished = false,
  });

  bool get isValid {
    return title != null &&
        title!.isNotEmpty &&
        description != null &&
        description!.isNotEmpty &&
        startDate != null &&
        endDate != null &&
        venue != null &&
        venue!.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'venue': venue,
      'venueAddress': venueAddress,
      'imageUrl': imageUrl,
      'isPublished': isPublished,
    };
  }

  factory EventFormData.fromJson(Map<String, dynamic> json) {
    return EventFormData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      venue: json['venue'],
      venueAddress: json['venueAddress'],
      imageUrl: json['imageUrl'],
      isPublished: json['isPublished'] ?? false,
    );
  }
}
