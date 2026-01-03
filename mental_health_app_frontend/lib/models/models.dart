// lib/models/models.dart
class MeditationCategory {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String backgroundMusicUrl;
  MeditationCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.backgroundMusicUrl,
  });
}

class MeditationSession {
  final int id;
  final String title;
  final int duration;
  final String description;
  final String mediaUrl;
  MeditationSession({
    required this.id,
    required this.title,
    required this.duration,
    required this.description,
    required this.mediaUrl,
  });
}

class YogaCategory {
  final int id;
  final String name;
  final String description;
  final String icon;
  YogaCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class YogaSession {
  final int id;
  final String title;
  final int duration;
  final String description;
  final String mediaUrl;
  YogaSession({
    required this.id,
    required this.title,
    required this.duration,
    required this.description,
    required this.mediaUrl,
  });
}

class UserActivity {
  final int userId;
  final String activityType; // "meditation" or "yoga"
  final int sessionId;
  final DateTime timestamp;
  UserActivity({
    required this.userId,
    required this.activityType,
    required this.sessionId,
    required this.timestamp,
  });
}