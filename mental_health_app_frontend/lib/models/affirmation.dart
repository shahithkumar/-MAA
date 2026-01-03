class Affirmation {
  final int id;
  final String text;
  final int? category;
  final String? categoryName;
  final String? categoryIcon;
  final bool isActive;

  Affirmation({
    required this.id,
    required this.text,
    this.category,
    this.categoryName,
    this.categoryIcon,
    required this.isActive,
  });

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      id: json['id'],
      text: json['text'] ?? '',
      category: json['category'] ?? json['category_id'],
      categoryName: json['category_name'],
      categoryIcon: json['category_icon'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class AffirmationCategory {
  final int id;
  final String name;
  final String icon;
  final String? description;
  final int affirmationCount;

  AffirmationCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    required this.affirmationCount,
  });

  factory AffirmationCategory.fromJson(Map<String, dynamic> json) {
    return AffirmationCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '🌸',
      description: json['description'],
      affirmationCount: json['affirmation_count'] ?? 0,
    );
  }
}

class CustomAffirmation {
  final int id;
  final String affirmationText;
  final String focusArea;
  final String? challenge;
  final String? positiveDirection;
  final DateTime createdAt;

  CustomAffirmation({
    required this.id,
    required this.affirmationText,
    required this.focusArea,
    this.challenge,
    this.positiveDirection,
    required this.createdAt,
  });

  factory CustomAffirmation.fromJson(Map<String, dynamic> json) {
    return CustomAffirmation(
      id: json['id'],
      affirmationText: json['affirmation_text'] ?? '',
      focusArea: json['focus_area'] ?? '',
      challenge: json['challenge'],
      positiveDirection: json['positive_direction'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}