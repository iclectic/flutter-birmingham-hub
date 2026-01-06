import 'package:equatable/equatable.dart';

class Speaker extends Equatable {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String? imageUrl;
  final String? twitterHandle;
  final String? linkedinUrl;
  final List<String> topics;

  const Speaker({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    this.imageUrl,
    this.twitterHandle,
    this.linkedinUrl,
    this.topics = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        bio,
        imageUrl,
        twitterHandle,
        linkedinUrl,
        topics,
      ];

  Speaker copyWith({
    String? id,
    String? name,
    String? title,
    String? bio,
    String? imageUrl,
    String? twitterHandle,
    String? linkedinUrl,
    List<String>? topics,
  }) {
    return Speaker(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'bio': bio,
      'imageUrl': imageUrl,
      'twitterHandle': twitterHandle,
      'linkedinUrl': linkedinUrl,
      'topics': topics,
    };
  }

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      bio: json['bio'] as String,
      imageUrl: json['imageUrl'] as String?,
      twitterHandle: json['twitterHandle'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
