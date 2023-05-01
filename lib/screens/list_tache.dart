import 'package:flutter/material.dart';
import 'package:tp2/screens/tache.dart';

class ListTache extends StatefulWidget {
  const ListTache({super.key});

  @override
  State<ListTache> createState() => _ListTacheState();
}

class _ListTacheState extends State<ListTache> {  
  Tache tacheService = Tache();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topAppBar,
      body: Container(
        child: FutureBuilder<List>(
          future: tacheService.getAllTasks(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) {
                final items = snapshot.data;
                final item = items![i] as Map;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
                        child: Text('${i+1}'),
                      ),
                      title: Text(
                        item["title"], 
                        style: TextStyle(fontSize: 20.0),
                      ),
                      subtitle: Text(
                        item["description"] + "\n",
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  );
                },
              );
            }
            else{
              return const Center (child: Text("Pas de tâche !"),);
            }
          },
        )
      )
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
}

 