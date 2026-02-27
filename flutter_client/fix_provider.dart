import 'dart:io';

void main() async {
  final file = File('lib/providers/task_providers.dart');
  var content = await file.readAsString();

  content = content.replaceFirst(
      '''class TaskViewModeNotifier extends Notifier<bool> {''',
      '''class TaskSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final taskSearchQueryProvider = NotifierProvider<TaskSearchQueryNotifier, String>(TaskSearchQueryNotifier.new);

class TaskViewModeNotifier extends Notifier<bool> {'''
  );

  content = content.replaceFirst(
      '''if (selectedCategory == null) return tasks;\n    return tasks.where((t) => t.category == selectedCategory).toList();''',
      '''if (selectedCategory != null) {
      tasks = tasks.where((t) => t.category == selectedCategory).toList();
    }
    final searchQuery = ref.watch(taskSearchQueryProvider);
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      tasks = tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return tasks;'''
  );

  content = content.replaceFirst(
      '''if (selectedCategory == null) return tasks;\r\n    return tasks.where((t) => t.category == selectedCategory).toList();''',
      '''if (selectedCategory != null) {
      tasks = tasks.where((t) => t.category == selectedCategory).toList();
    }
    final searchQuery = ref.watch(taskSearchQueryProvider);
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      tasks = tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return tasks;'''
  );

  await file.writeAsString(content);
  print('Done!');
}
