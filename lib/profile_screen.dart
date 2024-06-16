import 'package:flutter/material.dart';
import 'data/database.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DatabaseHelper databaseHELP = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  int _goal = 0;
  int _points = 0;
  bool _loaded = false;
  bool concluida = false;
  TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final profile = await databaseHELP.getUserProfile();
    if (profile != null) {
      setState(() {
        _goal = profile['goal'];
        _points = profile['points'];
        _goalController.text = _goal.toString();
        _loaded = true;
      });
      _checkGoalCompletion();
    }
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await databaseHELP.updateUserProfile({'id': 1, 'goal': _goal, 'points': _points});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meta salva com sucesso')));
      _checkGoalCompletion();
    }
  }

  Future<void> _resetPoints() async {
    await databaseHELP.updateUserProfile({'id': 1, 'goal': 0, 'points': 0});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pontos zerados')));
    setState(() {
      _goal = 0;
      _goalController.text = '0';
      _points = 0;
      concluida = false;
    });
  }

  void _checkGoalCompletion() {
    setState(() {
      concluida = (_points >= _goal && _goal != 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Usuário'),
      ),
      body: _loaded
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Meta do Usuário:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _goalController,
                decoration: InputDecoration(labelText: 'Digite sua meta'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _goal = int.parse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma meta';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Pontos Acumulados:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '$_points pontos',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveGoal,
                    child: Text('Salvar Meta'),
                  ),
                  ElevatedButton(
                    onPressed: _resetPoints,
                    child: Text('Zerar pontos'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Visibility(
                  visible: concluida,
                  child: const Center(
                    child: Text(
                      'Parabéns, você atingiu sua meta!!',
                      style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
