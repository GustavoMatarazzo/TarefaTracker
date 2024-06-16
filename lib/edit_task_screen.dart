import 'package:flutter/material.dart';
import 'package:projeto/data/database.dart';
import 'home_screen.dart';

class EditTaskScreen extends StatefulWidget {
  final int taskId;

  EditTaskScreen({required this.taskId});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  DatabaseHelper databaseHELP = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  DateTime? _dueDate;
  String? _priority;
  bool _isCompleted = false;
  bool pronto =false;
  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final task = await databaseHELP.getTask(widget.taskId);
    print('task$task');
    if (task != null) {
      setState(() {
        _title = task['title'];
        _description = task['description'];
        _dueDate = DateTime.parse(task['dueDate']);
        _priority = task['priority'];
        _isCompleted = task['isCompleted'] == 1;
      });
    }
    pronto =true;
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Map<String, dynamic> updatedTask = {
        'id': widget.taskId,
        'title': _title,
        'description': _description,
        'dueDate': _dueDate != null ? _dueDate!.toIso8601String() : null,
        'priority': _priority,
        'isCompleted': _isCompleted ? 1 : 0,
      };
      await databaseHELP.updateTask(updatedTask,widget.taskId);
      Navigator.pop(context);
    }
  }

  Future<void> _deleteTask() async {
    await databaseHELP.deleteTask(widget.taskId);
    Navigator.pop(context);
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Editar Tarefa'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _deleteTask();
              },
            ),
          ],
        ),
        body: pronto?Padding(
        padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: ListView(
    children: <Widget>[
    TextFormField(
    initialValue: _title,
    decoration: InputDecoration(labelText: 'Título'),
    onSaved: (value) => _title = value,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor, insira um título';
    }
    return null;
    },
    ),
    TextFormField(
    initialValue: _description,
    decoration: InputDecoration(labelText: 'Descrição'),
    onSaved: (value) => _description = value,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Por favor, insira uma descrição';
    }
    return null;
    },
    ),
    ListTile(
    title: Text(_dueDate == null
    ? 'Data de Vencimento'
        : 'Data de Vencimento: ${_dueDate!.toLocal()}'.split(' ')[0]),
    trailing: Icon(Icons.calendar_today),
    onTap: () => _selectDueDate(context),
    ),
      DropdownButtonFormField(
        value: _priority,
        decoration: InputDecoration(labelText: 'Prioridade'),
        items: [
          DropdownMenuItem(
            value: 'Alta (30 pts)',
            child: Text('Alta (30 pts)'),
          ),
          DropdownMenuItem(
            value: 'Média (20 pts)',
            child: Text('Média (20 pts)'),
          ),
          DropdownMenuItem(
            value: 'Baixa (10 pts)',
            child: Text('Baixa (10 pts)'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _priority = value as String?;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Por favor, selecione uma prioridade';
          }
          return null;
        },
      ),

      CheckboxListTile(
    title
        : Text('Concluída'),
      value: _isCompleted,
      onChanged: (value) {
        setState(() {
          _isCompleted = value!;
        });
      },
    ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () async {
          await _saveTask();
        },
        child: Text('Salvar'),
      ),
    ],
    ),
    ),
        ):Center(child: CircularProgressIndicator(),)
    );
  }
}