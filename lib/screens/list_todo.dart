import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tp2/screens/add_todo.dart';

class TodolistPage extends StatefulWidget {
  const TodolistPage({super.key});

  @override
  State<TodolistPage> createState() => _TodolistPageState();
}

class _TodolistPageState extends State<TodolistPage> {
  bool isLoading = true;
  List items = [];
  @override

  void initState(){
    super.initState();
    fetchTodo();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topAppBar,
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement : RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['id'].toString(); 
              final formatted = DateFormat('dd-MM-yyyy').format(DateTime.parse(item['dateEcheance']));
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                  child: Text('${index+1}'),
                ),                
                title: Text(item['title']),
                subtitle: Text(item["description"] + "\n" + formatted.toString()),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if(value == 'editer'){
                      navigateToEditPage(item);
                    }
                    else if(value == 'supprimer'){
                      deleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [ 
                      PopupMenuItem(
                        child: Text("Éditer"),
                        value: 'editer',
                      ),
                      PopupMenuItem(
                        value: 'supprimer',
                        child: Text("Supprimer"),
                      ),
                    ];
                  },
                ),
              );
            }
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage, 
        label: Text("Ajouter"),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      ),
    );
  }
  final topAppBar = AppBar(
    elevation: 0.1,
    backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
    title: Text("Liste des tâches"),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.list),
        onPressed: () {},
      )
    ],
  );

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async{
    // Delete the item
    final url = 'http://192.168.1.8:8000/api/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if(response.statusCode == 200){
      showSuccessMessage("Suppression réussie !");
    // Remove item from list
      final filtered = items.where((element) => element["id"] != id).toList();
      setState(() {
        items = filtered;
      });
    }else{
      showErrorMessage("Suppression impossible !");
    }
  }

  Future<void> fetchTodo() async {
    final url = 'http://192.168.1.8:8000/api/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode == 200){
      final json = jsonDecode(response.body) as Map;
      final result = json["items"] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message)
  {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSuccessMessage(String message)
  {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}