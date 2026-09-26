import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal_model.dart';
import 'auth_provider.dart';

class GoalsNotifier extends AsyncNotifier<List<GoalModel>> {
  @override
  Future<List<GoalModel>> build() {
    return ref.read(storageServiceProvider).fetchGoals();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(storageServiceProvider).fetchGoals(),
    );
  }

  Future<void> addGoal({
    required String title,
    String description = '',
    String category = 'personal',
  }) async {
    final storage = ref.read(storageServiceProvider);
    final created = await storage.createGoal(
      title: title,
      description: description,
      category: category,
    );
    final current = state.value ?? [];
    state = AsyncData([created, ...current]);
  }

  Future<void> toggleComplete(GoalModel goal) async {
    final updated = goal.copyWith(completed: !goal.completed);
    await ref.read(storageServiceProvider).updateGoal(updated);
    final current = state.value ?? [];
    state = AsyncData([
      for (final g in current)
        if (g.id == goal.id) updated else g,
    ]);
  }
}

final goalsProvider =
    AsyncNotifierProvider<GoalsNotifier, List<GoalModel>>(GoalsNotifier.new);
