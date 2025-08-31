import 'package:flutter/material.dart';

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Page")),
      body: Center(
        child: Hero(
          tag: 'fab-hero', // ต้องตรงกับหน้าแรก
          child: Image.asset(
            'assets/images/loopy.jpg',
            width: 300,
            height: 300,
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Image.asset('assets/images/loopy.jpg', width: 30, height: 30),
      // ),
    );
  }
}
