import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_model.dart';
import '../models/module_model.dart';
import 'auth_provider.dart';

final modulesProvider = FutureProvider<List<ModuleModel>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.fetchModules();
});

final moduleProvider =
    FutureProvider.family<ModuleModel, String>((ref, id) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.fetchModule(id);
});

final activityProvider =
    FutureProvider.family<ActivityModel, String>((ref, id) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.fetchActivity(id);
});
