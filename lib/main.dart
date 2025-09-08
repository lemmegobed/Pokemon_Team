import 'package:flutter/material.dart';
import 'myapp.dart';
import 'add_team.dart';
import 'team.dart';
import 'package:get_storage/get_storage.dart'; 

// void main() {
//   runApp(const Pokemon());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); 
  runApp(const Pokemon());
}


