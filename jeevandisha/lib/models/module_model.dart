import 'activity_model.dart';

class ModuleModel {
  const ModuleModel({
    required this.id,
    required this.moduleNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.order = 0,
    this.progress = 0,
    this.activities = const [],
  });

  final String id;
  final int moduleNumber;
  final String title;
  final String description;
  final String icon;
  final int order;
  final double progress;
  final List<ActivityModel> activities;

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final activitiesJson = json['activities'] as List<dynamic>? ?? [];
    return ModuleModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      moduleNumber: (json['moduleNumber'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? '📘').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      activities: activitiesJson
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleNumber': moduleNumber,
        'title': title,
        'description': description,
        'icon': icon,
        'order': order,
        'progress': progress,
        'activities': activities.map((a) => a.toJson()).toList(),
      };
}
