
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _taches =
  FirebaseFirestore.instance.collection("taches");
  DateTime selectedDateTime = DateTime.now();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateEcheanceController = TextEditingController();

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if(documentSnapshot != null){
      _titreController.text = documentSnapshot["titre"];
      _descriptionController.text = documentSnapshot["description"]; 
      _dateEcheanceController.text =  DateFormat('dd-MM-yyyy').format(documentSnapshot["dateEcheance"].toDate()).toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (BuildContext ctx){
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: "Titre"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Renseigner la date';
                }
                return null;
              },
            ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text("Modifier"),
                onPressed: () async {
                  final String titre = _titreController.text;
                  final String description = _descriptionController.text;
                  final Timestamp dateEcheance = Timestamp.fromDate(selectedDateTime);
                  await _taches
                    .doc(documentSnapshot!.id)
                    .update({"titre":titre, "description":description, "dateEcheance":dateEcheance});
                    _titreController.text = "";
                    _dateEcheanceController.text = "";
                    _descriptionController.text = "";
                }, 
              )   
            ]
          ),
        );
      }
    );
  }
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    if(documentSnapshot != null){
      _titreController.text = documentSnapshot["titre"];
      _descriptionController.text = documentSnapshot["description"];
      _dateEcheanceController.text = documentSnapshot["dateEcheance"];
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (BuildContext ctx){
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20
          ),
          child: Form(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titreController,
                  decoration: const InputDecoration(labelText: "Titre"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Renseigner le titre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Renseigner la description';
                    }
                    return null;
                  },
                ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Renseigner la date';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text("Créer"),
                onPressed: () async {
                  final String titre = _titreController.text;
                  final String description = _descriptionController.text;
                  final Timestamp dateEcheance = Timestamp.fromDate(selectedDateTime);

                  await _taches
                    .add({"titre":titre, "description":description, "dateEcheance":dateEcheance});
                    _titreController.text = "";
                    _dateEcheanceController.text = "";
                    _descriptionController.text = "";
                }, 
              )   
            ]
            ),
          ),
        );
      }
    );
  }
  Future<void> _delete(String tacheId) async {
      await _taches.doc(tacheId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Supprimé !"),)
      );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: StreamBuilder(
          stream: _taches.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
            if(streamSnapshot.hasData){
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index){
                  final DocumentSnapshot documentSnapshot = 
                  streamSnapshot.data!.docs[index];
                  DateTime date = (streamSnapshot.data!.docs[index]['dateEcheance'] as Timestamp).toDate();
                  String formatted = DateFormat('dd-MM-yyyy').format(date);
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child : ListTile(
                      title: Text(documentSnapshot["titre"]),
                      subtitle: Text(formatted + " " + documentSnapshot["description"]),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)
                            ),
                             IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        ),
    );
  }
}