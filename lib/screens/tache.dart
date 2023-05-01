import 'dart:convert';

import 'package:http/http.dart' as http;

class Tache{
  String baseUrl = "http://192.168.1.8:8000/api/v1/todos";

  Future<List> getAllTasks() async  {
    try{
      var response = await http.get(Uri.parse(baseUrl));
      if(response.statusCode == 200){
        return jsonDecode(response.body);
      }
      else{
        return Future.error("Erreur provenant du serveur");
      }
    }catch(e){
      return Future.error(e);
    }
  }
}