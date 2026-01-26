import 'package:equatable/equatable.dart';

class Talk extends Equatable {
  final String id;
  final String title;
  final String description;
  final String speakerId;
  final List<String> tags;
  final TalkLevel level;
  final int durationMinutes;
  final String? slidesUrl;
  final String? videoUrl;

  const Talk({
    required this.id,
    required this.title,
    required this.description,
    required this.speakerId,
    this.tags = const [],
    this.level = TalkLevel.intermediate,
    required this.durationMinutes,
    this.slidesUrl,
    this.videoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        speakerId,
        tags,
        level,
        durationMinutes,
        slidesUrl,
        videoUrl,
      ];

  Talk copyWith({
    String? id,
    String? title,
    String? description,
    String? speakerId,
    List<String>? tags,
    TalkLevel? level,
    int? durationMinutes,
    String? slidesUrl,
    String? videoUrl,
  }) {
    return Talk(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      speakerId: speakerId ?? this.speakerId,
      tags: tags ?? this.tags,
      level: level ?? this.level,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      slidesUrl: slidesUrl ?? this.slidesUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'speakerId': speakerId,
      'tags': tags,
      'level': level.name,
      'durationMinutes': durationMinutes,
      'slidesUrl': slidesUrl,
      'videoUrl': videoUrl,
    };
  }

  factory Talk.fromJson(Map<String, dynamic> json) {
    return Talk(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      speakerId: json['speakerId'] as String,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      level: TalkLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => TalkLevel.intermediate,
      ),
      durationMinutes: json['durationMinutes'] as int,
      slidesUrl: json['slidesUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }
}

enum TalkLevel {
  beginner,
  intermediate,
  advanced,
}
