import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TarefasScreen extends StatefulWidget {
  final String nomeLista;
  final List<Map<String, dynamic>> tarefas;
  final Function salvarTarefas;
  final Function excluirLista;

  const TarefasScreen({
    super.key,
    required this.nomeLista,
    required this.tarefas,
    required this.salvarTarefas,
    required this.excluirLista,
  });

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  late List<Map<String, dynamic>> _tarefas;
  final TextEditingController _tarefaController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final int _minimoTarefas = 2;
  final int _maximoTarefas = 5;

  @override
  void initState() {
    super.initState();
    _tarefas = List<Map<String, dynamic>>.from(widget.tarefas);
  }

  void _adicionarTarefa() {
    if (_tarefas.length >= _maximoTarefas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Máximo de $_maximoTarefas tarefas permitido.")),
      );
      return;
    }
    if (_tarefaController.text.isNotEmpty &&
        _descricaoController.text.isNotEmpty &&
        _horarioController.text.isNotEmpty) {
      setState(() {
        _tarefas.add({
          "tarefa": _tarefaController.text,
          "descricao": _descricaoController.text,
          "horario": _horarioController.text,
          "feito": false,
        });
      });
      widget.salvarTarefas();
      _tarefaController.clear();
      _descricaoController.clear();
      _horarioController.clear();
    }
  }

  void _removerTarefa(int index) {
    if (_tarefas.length <= _minimoTarefas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("É necessário informar no mínimo $_minimoTarefas tarefas."),
        ),
      );
      return;
    }
    setState(() {
      _tarefas.removeAt(index);
    });
    widget.salvarTarefas();
  }

  void _salvarLista() {
    if (_tarefas.length < _minimoTarefas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "É necessário informar no mínimo $_minimoTarefas tarefas.")),
      );
      return;
    }
    widget.salvarTarefas();
    Navigator.pop(context);
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Excluir Lista"),
          content: const Text("Tem certeza que deseja excluir esta lista?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                widget.excluirLista();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeLista),
        backgroundColor: const Color.fromARGB(255, 107, 188, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmarExclusao,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tarefaController,
              decoration: const InputDecoration(labelText: "Nome da Tarefa"),
            ),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: "Descrição"),
            ),
            TextField(
              controller: _horarioController,
              decoration: const InputDecoration(labelText: "Horário"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _adicionarTarefa,
              child: const Text("Adicionar Tarefa"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = _tarefas[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        tarefa["tarefa"],
                        style: TextStyle(
                          decoration: tarefa["feito"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                          "Descrição: ${tarefa['descricao']} - Horário: ${tarefa['horario']}"),
                      leading: Checkbox(
                        value: tarefa["feito"],
                        onChanged: (value) => setState(() {
                          tarefa["feito"] = value ?? false;
                        }),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerTarefa(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _salvarLista,
              child: const Text("Salvar Lista"),
            ),
          ],
        ),
      ),
    );
  }
}
