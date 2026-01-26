import 'dart:typed_data';

/// Model class to hold all CFP form data across steps
class CfpFormData {
  // Speaker details
  String? fullName;
  String? tagline;
  String? bio;
  Uint8List? photoData;
  String? photoFileName;
  String? location;
  String? company;
  String? role;
  String? pronouns;
  String? twitterHandle;
  String? linkedinUrl;
  String? githubUrl;
  String? websiteUrl;
  String? email;

  // Talk details
  String? title;
  String? abstract;
  TalkLevel? level;
  TalkFormat? format;
  int? durationMinutes;
  List<String> tags;

  CfpFormData({
    this.fullName,
    this.tagline,
    this.bio,
    this.photoData,
    this.photoFileName,
    this.location,
    this.company,
    this.role,
    this.pronouns,
    this.twitterHandle,
    this.linkedinUrl,
    this.githubUrl,
    this.websiteUrl,
    this.email,
    this.title,
    this.abstract,
    this.level,
    this.format,
    this.durationMinutes,
    this.tags = const [],
  });

  bool get isSpeakerDetailsValid {
    return fullName != null && 
           fullName!.isNotEmpty && 
           bio != null && 
           bio!.isNotEmpty &&
           email != null &&
           email!.isNotEmpty;
  }

  bool get isTalkDetailsValid {
    return title != null && 
           title!.isNotEmpty && 
           abstract != null && 
           abstract!.isNotEmpty &&
           level != null &&
           format != null &&
           durationMinutes != null;
  }
}

enum TalkLevel {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  final String label;
  const TalkLevel(this.label);
}

enum TalkFormat {
  presentation('Presentation'),
  workshop('Workshop'),
  panel('Panel Discussion'),
  lightning('Lightning Talk');

  final String label;
  const TalkFormat(this.label);
}
