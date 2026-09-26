import '../core/storage.dart';
import '../models/activity_model.dart';
import '../models/checkin_model.dart';
import '../models/goal_model.dart';
import '../models/module_model.dart';
import '../models/progress_model.dart';
import 'api_service.dart';

class StorageService {
  const StorageService();

  Future<void> clearSession() => AppStorage.clearAll();

  Future<bool> isOnboarded() => AppStorage.isOnboarded();

  Future<void> setOnboarded(bool value) => AppStorage.setOnboarded(value);

  Future<List<ModuleModel>> fetchModules() async {
    try {
      final data = await ApiService.get('/modules');
      final list = data is List ? data : (data['modules'] as List? ?? []);
      return list
          .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _demoModules;
    }
  }

  Future<ModuleModel> fetchModule(String id) async {
    try {
      final data = await ApiService.get('/modules/$id') as Map<String, dynamic>;
      final map = data['module'] as Map<String, dynamic>? ?? data;
      return ModuleModel.fromJson(map);
    } catch (_) {
      return _demoModules.firstWhere(
        (m) => m.id == id,
        orElse: () => _demoModules.first,
      );
    }
  }

  Future<ActivityModel> fetchActivity(String id) async {
    try {
      final data =
          await ApiService.get('/activities/$id') as Map<String, dynamic>;
      final map = data['activity'] as Map<String, dynamic>? ?? data;
      return ActivityModel.fromJson(map);
    } catch (_) {
      for (final m in _demoModules) {
        for (final a in m.activities) {
          if (a.id == id) return a;
        }
      }
      return _demoModules.first.activities.first;
    }
  }

  Future<void> completeActivity(
    String id, {
    Map<String, String>? practiceResponses,
    Map<String, String>? reflectionResponses,
    String? applyResponse,
  }) async {
    try {
      await ApiService.post(
        '/activities/$id/complete',
        {
          ...?practiceResponses != null
              ? {'practiceResponses': practiceResponses}
              : null,
          ...?reflectionResponses != null
              ? {'reflectionResponses': reflectionResponses}
              : null,
          ...?applyResponse != null ? {'applyResponse': applyResponse} : null,
        },
      );
    } catch (_) {}
  }

  Future<List<GoalModel>> fetchGoals() async {
    try {
      final data = await ApiService.get('/goals');
      final list = data is List ? data : (data['goals'] as List? ?? []);
      return list
          .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _demoGoals;
    }
  }

  Future<GoalModel> createGoal({
    required String title,
    String action = '',
    String schedule = '',
    String firstStep = '',
    String description = '',
    String category = 'personal',
  }) async {
    try {
      final data = await ApiService.post(
        '/goals',
        {
          'goal': title,
          'action': action.isNotEmpty ? action : description,
          'schedule': schedule,
          'firstStep': firstStep,
        },
      ) as Map<String, dynamic>;
      final map = data['goal'] as Map<String, dynamic>? ?? data;
      return GoalModel.fromJson(map);
    } catch (_) {
      return GoalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goal: title,
        action: action.isNotEmpty ? action : description,
        schedule: schedule,
        firstStep: firstStep,
      );
    }
  }

  Future<void> updateGoal(GoalModel goal) async {
    try {
      await ApiService.put('/goals/${goal.id}', goal.toJson());
    } catch (_) {}
  }

  Future<CheckinModel> submitCheckin({
    required String feeling,
    String note = '',
  }) async {
    try {
      final data = await ApiService.post(
        '/checkins',
        {'feeling': feeling},
      ) as Map<String, dynamic>;
      final map = data['checkin'] as Map<String, dynamic>? ?? data;
      return CheckinModel.fromJson(map);
    } catch (_) {
      return CheckinModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        feeling: feeling,
        date: DateTime.now(),
      );
    }
  }

  Future<ProgressModel> fetchProgress() async {
    try {
      final data = await ApiService.get('/progress') as Map<String, dynamic>;
      final map = data['progress'] as Map<String, dynamic>? ?? data;
      return ProgressModel.fromJson(map);
    } catch (_) {
      return const ProgressModel(
        overall: 0.2,
        activitiesCompleted: 5,
        activitiesTotal: 25,
        goalsCompleted: 0,
        goalsTotal: 1,
        currentWeek: 1,
        currentModule: 1,
        weeklyMinutes: 40,
      );
    }
  }

  Future<void> createStudySession({
    String topic = 'Focus session',
    int duration = 25,
    List<String> recallPoints = const [],
    String status = 'in_progress',
  }) async {
    try {
      await ApiService.post(
        '/study',
        {
          'topic': topic.isNotEmpty ? topic : 'Focus session',
          'duration': duration,
          'recallPoints': recallPoints,
          'status': status,
        },
      );
    } catch (_) {}
  }
}

final _demoModules = [
  ModuleModel(
    id: 'm1',
    moduleNumber: 1,
    title: 'Know Yourself',
    description: 'Build awareness of your values, strengths, and patterns.',
    icon: '🧭',
    order: 1,
    progress: 0.2,
    activities: [
      ActivityModel(
        id: 'a1',
        moduleId: 'm1',
        title: 'What are values?',
        type: 'learn',
        order: 1,
        estimatedMinutes: 5,
        learnContent: const LearnContent(
          heading: 'Values are your inner compass',
          body:
              'Values are qualities that matter to you. Goals are destinations; values are directions.',
          keyIdea: 'A value guides choices even when no one is watching.',
        ),
      ),
      ActivityModel(
        id: 'a2',
        moduleId: 'm1',
        title: 'Map your top 3',
        type: 'practice',
        order: 2,
        estimatedMinutes: 8,
        practiceFields: const [
          PracticeField(label: 'Value 1', placeholder: 'e.g. Honesty'),
          PracticeField(label: 'Value 2', placeholder: 'e.g. Growth'),
          PracticeField(label: 'Value 3', placeholder: 'e.g. Balance'),
        ],
      ),
    ],
  ),
  const ModuleModel(
    id: 'm2',
    moduleNumber: 2,
    title: 'Steady Mind',
    description: 'Tools for stress, focus, and emotional balance.',
    icon: '🌿',
    order: 2,
    progress: 0,
  ),
];

final _demoGoals = [
  GoalModel(
    id: 'g1',
    goal: 'Sleep before midnight',
    action: 'Start wind-down at 11pm',
    schedule: 'Weeknights',
    firstStep: 'Set a phone alarm for 10:45pm',
    status: 'active',
  ),
];
