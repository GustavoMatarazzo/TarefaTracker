import 'package:flutter/material.dart';

import 'data/database.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
   late DatabaseHelper databaseHELP = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  DateTime? _dueDate;
  String? _priority;

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHELP = DatabaseHelper();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Tarefa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
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
                decoration: InputDecoration(labelText: 'Prioridade'),
                items: ['Alta', 'Média', 'Baixa'].map((String priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Map<String, dynamic> task = {
                      'title': _title,
                      'description': _description,
                      'dueDate': _dueDate != null ? _dueDate!.toIso8601String() : null,
                      'priority': _priority,
                    };
                    addTask(task);
                    Navigator.pop(context);
                  }
                },
                child: Text('Salvar Tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addTask(Map<String,dynamic> task) async{
    await databaseHELP.insertTask(task);


  }
}
