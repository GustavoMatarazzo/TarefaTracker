import 'package:flutter/material.dart';
import 'package:projeto/data/database.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper databaseHELP = DatabaseHelper();
  bool _hideCompletedTasks = false;

  @override
  void initState() {
    super.initState();
    databaseHELP = DatabaseHelper();
  }

  void _toggleTaskCompletion(int id, bool isCompleted) async {
    await databaseHELP.updateTaskCompletion(id, isCompleted);

    if (isCompleted) {
      await databaseHELP.incrementUserPoints(id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(          'TarefaTracker',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_hideCompletedTasks ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _hideCompletedTasks = !_hideCompletedTasks;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: databaseHELP.getTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              final tasks = snapshot.data!;
              final incompleteTasks = tasks.where((task) => task['isCompleted'] == 0).toList();
              final completedTasks = tasks.where((task) => task['isCompleted'] == 1).toList();
              final visibleTasks = _hideCompletedTasks
                  ? incompleteTasks
                  : [...incompleteTasks, ...completedTasks];

              if (visibleTasks.isEmpty) {
                return Center(
                  child: Text('Nenhuma tarefa encontrada.'),
                );
              }

              return ListView.builder(
                itemCount: visibleTasks.length,
                itemBuilder: (context, index) {
                  final task = visibleTasks[index];
                  final isCompleted = task['isCompleted'] == 1;

                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(taskId: task['id']),
                        ),
                      ).then((_) => setState(() {}));
                    },

                    child: Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Checkbox(
                          value: isCompleted,
                          onChanged: (bool? value) {
                            setState(() {
                              _toggleTaskCompletion(task['id'], value!);
                            });
                          },
                        ),
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task['description']),
                            Text('Prioridade: ${task['priority']}'),
                            Text('Vencimento: ${formatarData(task['dueDate'])}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text('Nenhuma tarefa encontrada.'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  String formatarData(String dateString) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateTime date = DateTime.parse(dateString);
    return dateFormat.format(date);
  }




}
