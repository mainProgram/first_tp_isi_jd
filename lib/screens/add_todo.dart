import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({
    super.key,
    this.todo
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController _titreController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      _titreController.text = title;
      _descriptionController.text = description;
    }
  }

  // DateTime selectedDateTime = DateTime.now();
  // TextEditingController _dateEcheanceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modification' : 'Ajout de tâche'
        )
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titreController,
            decoration: InputDecoration(
              hintText: "Titre"
            ),
          ),  
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: "Description"
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 5,
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData, 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isEdit ? "Modifier" : "Enregistrer"
              ),
            )
          )
        ],
      ),
    );
  }

  Future<void> updateData() async{
    final todo = widget.todo;
    if(todo == null){
      print("objectbgjugjg");
      return;
    }
    final id = todo['_id'];
    final titre = _titreController.text;
    final description = _descriptionController.text;
    final body = {
      "title" : titre,
      "description" : description,
      "is_completed" : false,
    };
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri, 
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json"
      },
    );
      // Show success or fail
    if(response.statusCode == 200){
      showSuccessMessage("Modification réussie");
    }
    else{
      showErrorMessage("Modification echouée");
    }
  }

  Future<void> submitData() async{
    // Get data
    final titre = _titreController.text;
    final description = _descriptionController.text;
    // final dateEcheance = _dateEcheanceController.text;
    final body = {
      "title" : titre,
      "description" : description,
      "is_completed" : false,
    };
    // Submit data
    final url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri, 
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json"
      },
    );

    // Show success or fail
    if(response.statusCode == 201){
      showSuccessMessage("Creation réussie");
      _titreController.text = '';
      _descriptionController.text = '';
    }
    else{
      showErrorMessage("Creation echouée");
    }
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
} 