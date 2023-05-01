import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  DateTime selectedDateTime = DateTime.now();
  TextEditingController _titreController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateEcheanceController = TextEditingController();
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
      _dateEcheanceController.text =  DateFormat('dd-MM-yyyy').format(DateTime.parse(todo['dateEcheance']));
    }
  }

  // DateTime selectedDateTime = DateTime.now();
  // TextEditingController _dateEcheanceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
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
          TextFormField(
                  readOnly: true,
                  controller: _dateEcheanceController,
                  decoration: InputDecoration(
                    labelText: 'Date d\'échéance',
                  ),
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2025),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        selectedDateTime = selectedDate;
                        _dateEcheanceController.text =
                          DateFormat('dd-MM-yyyy').format(selectedDate);
                      }
                    }
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData, 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isEdit ? "Modifier" : "Enregistrer"
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
              textStyle: TextStyle(
                fontSize: 20.0,
              )
            ),            
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async{
    final todo = widget.todo;
    if(todo == null){
      return;
    }
    final id = todo['id'];
    final titre = _titreController.text;
    final description = _descriptionController.text;
    final dateEcheance = _dateEcheanceController.text;
    final body = {
      "title" : titre,
      "description" : description,
      "is_completed" : false,
      "dateEcheance" : dateEcheance,
    };
    final url = 'http://192.168.1.8:8000/api/v1/todos/$id';
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
    final dateEcheance = _dateEcheanceController.text;
    final body = {
      "title" : titre,
      "description" : description,
      "is_completed" : false,
      "dateEcheance" : dateEcheance,
    };
    // Submit data
    final url = 'http://192.168.1.8:8000/api/v1/todos';
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
      _dateEcheanceController.text = '';
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