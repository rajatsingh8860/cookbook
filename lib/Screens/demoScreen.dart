import 'dart:core';
import 'package:flutter/material.dart';



class MyHomePage extends StatefulWidget {
  MyHomePage();


  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int count = 1;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List.generate(count, (int i) => new InputWidget(i));

    return new Scaffold(
        appBar: new AppBar(title: new Text("widget.title")),
        body: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: children
        ),
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            setState(() {
              count = count + 1;
            });
          },
        )
    );
  }
}

class InputWidget extends StatelessWidget {

  final int index;

  InputWidget(this.index);

  @override
  Widget build(BuildContext context) {
    return new Text("InputWidget: " + index.toString());
  }
}