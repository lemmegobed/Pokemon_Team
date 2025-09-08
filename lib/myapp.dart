import 'package:flutter/material.dart';
import 'package:get/get.dart';   
import 'team.dart';

class Pokemon extends StatelessWidget {
  const Pokemon({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(   
      title: 'Pokémon Team Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TeamPage(),
    );
  }
}
