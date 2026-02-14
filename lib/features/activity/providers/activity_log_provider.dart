import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/activity_log_model.dart';
import '../../../services/activity_log_service.dart';

/// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

/// Stream provider for activity logs
final activityLogsStreamProvider = StreamProvider<List<ActivityLog>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }
  return ActivityLogService.streamLogs(userId);
});

/// State provider for selected log level filter
final selectedLogLevelProvider = StateProvider<String?>((ref) => null);

/// Provider for filtered activity logs
final filteredActivityLogsProvider = Provider<List<ActivityLog>>((ref) {
  final logsAsync = ref.watch(activityLogsStreamProvider);
  final selectedLevel = ref.watch(selectedLogLevelProvider);

  return logsAsync.when(
    data: (logs) {
      if (selectedLevel == null) {
        return logs;
      }
      return logs.where((log) => log.level == selectedLevel).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// State provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for searched activity logs
final searchedActivityLogsProvider = Provider<List<ActivityLog>>((ref) {
  final filteredLogs = ref.watch(filteredActivityLogsProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return filteredLogs;
  }

  return filteredLogs.where((log) {
    final query = searchQuery.toLowerCase();
    return log.action.toLowerCase().contains(query) ||
        log.details.toLowerCase().contains(query);
  }).toList();
});
