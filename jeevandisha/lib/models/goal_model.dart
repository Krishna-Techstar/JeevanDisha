class GoalModel {
  const GoalModel({
    required this.id,
    required this.goal,
    this.action = '',
    this.schedule = '',
    this.targetDate,
    this.firstStep = '',
    this.status = 'active',
    this.createdAt,
  });

  final String id;
  final String goal;
  final String action;
  final String schedule;
  final DateTime? targetDate;
  final String firstStep;
  final String status;
  final DateTime? createdAt;

  String get title => goal;
  bool get completed => status == 'completed';
  double get progress => completed ? 1 : 0;
  String get description =>
      [action, schedule, firstStep].where((s) => s.isNotEmpty).join(' · ');
  String get category => 'personal';

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      goal: (json['goal'] ?? json['title'] ?? '').toString(),
      action: (json['action'] ?? '').toString(),
      schedule: (json['schedule'] ?? '').toString(),
      targetDate: json['targetDate'] != null
          ? DateTime.tryParse(json['targetDate'].toString())
          : null,
      firstStep: (json['firstStep'] ?? '').toString(),
      status: (json['status'] ??
              ((json['completed'] == true) ? 'completed' : 'active'))
          .toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal': goal,
        'action': action,
        'schedule': schedule,
        'targetDate': targetDate?.toIso8601String(),
        'firstStep': firstStep,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };

  GoalModel copyWith({
    String? goal,
    String? action,
    String? schedule,
    DateTime? targetDate,
    String? firstStep,
    String? status,
    bool? completed,
  }) {
    return GoalModel(
      id: id,
      goal: goal ?? this.goal,
      action: action ?? this.action,
      schedule: schedule ?? this.schedule,
      targetDate: targetDate ?? this.targetDate,
      firstStep: firstStep ?? this.firstStep,
      status: completed == true
          ? 'completed'
          : completed == false
              ? 'active'
              : (status ?? this.status),
      createdAt: createdAt,
    );
  }
}
