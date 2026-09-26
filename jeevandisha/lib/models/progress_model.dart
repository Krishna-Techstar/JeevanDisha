class ProgressModel {
  const ProgressModel({
    this.overall = 0,
    this.activitiesCompleted = 0,
    this.activitiesTotal = 0,
    this.goalsCompleted = 0,
    this.goalsTotal = 0,
    this.currentWeek = 1,
    this.currentModule = 1,
    this.weeklyMinutes = 0,
    this.weeklyCheckins = 0,
    this.weeklySelfCare = 0,
    this.moduleProgress = const {},
  });

  final double overall;
  final int activitiesCompleted;
  final int activitiesTotal;
  final int goalsCompleted;
  final int goalsTotal;
  final int currentWeek;
  final int currentModule;
  final int weeklyMinutes;
  final int weeklyCheckins;
  final int weeklySelfCare;
  final Map<String, double> moduleProgress;

  /// Back-compat for UI that showed streak.
  int get streak => currentWeek;

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    final rawModules = json['moduleProgress'] as Map<String, dynamic>? ?? {};
    return ProgressModel(
      overall: (json['overall'] as num?)?.toDouble() ?? 0,
      activitiesCompleted: (json['activitiesCompleted'] as num?)?.toInt() ?? 0,
      activitiesTotal: (json['activitiesTotal'] as num?)?.toInt() ?? 0,
      goalsCompleted: (json['goalsCompleted'] as num?)?.toInt() ?? 0,
      goalsTotal: (json['goalsTotal'] as num?)?.toInt() ?? 0,
      currentWeek: (json['currentWeek'] as num?)?.toInt() ?? 1,
      currentModule: (json['currentModule'] as num?)?.toInt() ?? 1,
      weeklyMinutes: (json['weeklyMinutes'] as num?)?.toInt() ?? 0,
      weeklyCheckins: (json['weeklyCheckins'] as num?)?.toInt() ?? 0,
      weeklySelfCare: (json['weeklySelfCare'] as num?)?.toInt() ?? 0,
      moduleProgress: rawModules.map(
        (k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'activitiesCompleted': activitiesCompleted,
        'activitiesTotal': activitiesTotal,
        'goalsCompleted': goalsCompleted,
        'goalsTotal': goalsTotal,
        'currentWeek': currentWeek,
        'currentModule': currentModule,
        'weeklyMinutes': weeklyMinutes,
        'weeklyCheckins': weeklyCheckins,
        'weeklySelfCare': weeklySelfCare,
        'moduleProgress': moduleProgress,
      };
}
