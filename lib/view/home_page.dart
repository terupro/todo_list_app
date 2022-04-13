import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:todo_list_app/models/db/db.dart';
import 'package:todo_list_app/models/freezed/todo.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:todo_list_app/view_models/todo_provider.dart';

class HomePage extends ConsumerWidget {
  // 入力中のtodoのインスタンスを作成
  TempTodoItemData temp = TempTodoItemData();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 状態が変化するたびに再ビルドする
    final todoProvider = ref.watch(todoDatabaseProvider);

    // メソッドや値を取得する
    final todoNotifierProvider = ref.watch(todoDatabaseProvider.notifier);

    // 追加画面を閉じたら再ビルドするために使用する
    List<TodoItemData> todoItems = todoNotifierProvider.state.todoItems;

    // todoの一覧を格納するリスト
    List<Widget> tiles = _buildTodoList(todoItems, todoNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: ListView(children: tiles),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context2) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _createTask(temp),
                ],
              );
            },
          );
          temp = TempTodoItemData();
        },
      ),
    );
  }

  // todo一覧
  List<Widget> _buildTodoList(
    List<TodoItemData> items,
    TodoDatabaseNotifier db,
  ) {
    List<Widget> list = [];
    for (TodoItemData item in items) {
      Widget tile = _tile(item, db);
      list.add(tile);
    }
    return list;
  }

  // todo
  Widget _tile(TodoItemData item, TodoDatabaseNotifier db) {
    return Consumer(
      builder: ((context, ref, child) {
        return Slidable(
          child: Card(
            child: ListTile(
              title: Text(item.title),
              subtitle: Text(item.description),
              trailing: Text(
                item.date == null
                    ? ""
                    : DateFormat('M/dd H:mm').format(item.date!),
              ),
            ),
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                flex: 1,
                icon: Icons.create,
                backgroundColor: Colors.green,
                label: '編集',
                onPressed: (_) async {
                  await showDialog(
                    context: context,
                    builder: (context2) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _createTask(temp),
                        ],
                      );
                    },
                  );
                },
              ),
              SlidableAction(
                flex: 1,
                icon: Icons.delete,
                backgroundColor: Colors.red,
                label: '削除',
                onPressed: (_) {
                  db.deleteData(item);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  // 新規タスクの作成
  Widget _createTask(TempTodoItemData temp) {
    return Consumer(
      builder: ((context, ref, child) {
        // 状態が変化するたびに再ビルドする
        final _todoProvider = ref.watch(todoDatabaseProvider);

        // メソッドや値を取得する
        final _todoNotifierProvider = ref.watch(todoDatabaseProvider.notifier);

        // 追加画面を閉じたら再ビルドするために使用する
        List<TodoItemData> todoItems = _todoNotifierProvider.state.todoItems;

        // todoの一覧を格納するリスト
        List<Widget> tiles = _buildTodoList(todoItems, _todoNotifierProvider);

        // 入力されたタスクの状態を管理する
        final _titleProvider = ref.watch(titleProvider);
        final _titleNotifierProvider = ref.watch(titleProvider.notifier);
        final _descriptionProvider = ref.watch(descriptionProvider);
        final _descriptionNotifierProvider =
            ref.watch(descriptionProvider.notifier);
        final _dateProvider = ref.watch(dateProvider);
        final _dateNotifierProvider = ref.watch(dateProvider.notifier);

        // コントローラー
        final _titleController =
            TextEditingController(text: _titleNotifierProvider.state);
        final _descriptionController =
            TextEditingController(text: _descriptionNotifierProvider.state);

        return AlertDialog(
          title: const Text("New Task"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'タイトル',
                      ),
                      onChanged: (value) {
                        temp = temp.copyWith(title: value);
                      },
                      onSubmitted: (value) {
                        value = _titleNotifierProvider.state;

                        temp = temp.copyWith(title: value);
                      },
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '説明',
                      ),
                      onChanged: (value) {
                        temp = temp.copyWith(description: value);
                      },
                      onSubmitted: (value) {
                        value = _titleNotifierProvider.state;
                        temp = temp.copyWith(description: value);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            DatePicker.showDateTimePicker(
                              context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              onConfirm: (date) {
                                // 期限を保存するために使います
                                _dateNotifierProvider.state = date;
                                temp = temp.copyWith(date: date);
                              },
                              currentTime: DateTime.now(),
                              locale: LocaleType.jp,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 5.0),
                              Text(
                                _dateNotifierProvider.state == null
                                    ? "日付指定"
                                    : _dateNotifierProvider.state
                                        .toString()
                                        .substring(0, 10),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // データの追加
                            _todoNotifierProvider.writeData(temp);
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
