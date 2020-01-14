import 'package:flutter/material.dart';

void main() =>
    runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Flutter Home Page'),
    ));


class HomePage extends StatelessWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
          children: <Widget>[
          ]
      ),
    );
  }
}
