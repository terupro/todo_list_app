import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/models/db/db.dart';
import 'package:todo_list_app/models/freezed/todo.dart';

// DBの操作を行うクラス （dbの操作にstateを絡める）
class TodoDatabaseNotifier extends StateNotifier<TodoStateData> {
  TodoDatabaseNotifier() : super(TodoStateData());

  final _db = MyDatabase(); //DBへの操作を行う

  // 書き込み処理
  writeData(TempTodoItemData data) async {
    if (data.title.isEmpty) {
      return;
    }
    TodoItemCompanion entry = TodoItemCompanion(
      title: Value(data.title),
      description: Value(data.description),
      date: Value(data.date),
    );
    state = state.copyWith(isLoading: true);
    await _db.writeTodo(entry); //テーブルに入力されたデータを送る
    readData();
  }

  // 更新処理
  updateData(TodoItemData data) async {
    if (data.title.isEmpty) {
      return;
    }
    state = state.copyWith(isLoading: true);
    await _db.updateTodo(data);
    readData();
  }

  // 削除処理
  deleteData(TodoItemData data) async {
    state = state.copyWith(isLoading: true);
    await _db.deleteTodo(data.id);
    readData();
  }

  // 読み込み処理
  readData() async {
    state = state.copyWith(isLoading: true);
    final todoItems = await _db.readAllTodoData();
    state = state.copyWith(
      isLoading: false,
      isReadyData: true,
      todoItems: todoItems,
    );
  }
}

// 無名関数の中に処理を書くことで初期化を可能にしている。これにより、常に最新の状態を管理できる。
final todoDatabaseProvider = StateNotifierProvider((_) {
  TodoDatabaseNotifier notify = TodoDatabaseNotifier();
  notify.readData();
  return notify; // 初期化
});

// 入力された新規タスクの状態を管理する
final titleProvider = StateProvider((ref) => '');
final descriptionProvider = StateProvider((ref) => '');
final dateProvider = StateProvider<DateTime?>((ref) => null);


