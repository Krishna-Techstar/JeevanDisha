import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/progress_model.dart';
import 'auth_provider.dart';

final progressProvider = FutureProvider<ProgressModel>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.fetchProgress();
});
