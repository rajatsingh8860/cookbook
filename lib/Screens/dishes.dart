import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/Screens/addDish.dart';
import 'package:cookbook/Screens/favouriteCuisine.dart';
import 'package:cookbook/Screens/receipe.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Dishes extends StatefulWidget {
  final docId, name;

  const Dishes({this.docId, this.name});
  @override
  DishesState createState() => DishesState();
}

class DishesState extends State<Dishes> {
  List<String> suggestions = List();
  Map<String, dynamic> _userData;
  AccessToken _accessToken;
  bool _checking = true;
  var notLoggedIn = false;
  var loading = true;

  getSuggestions() async {
    await FirebaseFirestore.instance
        .collection('cuisine')
        .doc(widget.docId)
        .collection('Dishes')
        .snapshots()
        .listen((event) {
      event.docs.forEach((element) async {
        setState(() {
          suggestions.add(element["dishName"]);
        });
      });
    });
  }

  Future<void> _checkIfIsLogged() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _checking = false;
    });
    if (accessToken != null) {
      final userData = await FacebookAuth.instance.getUserData();
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    } else {
      setState(() {
        notLoggedIn = true;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    _checkIfIsLogged();
    getSuggestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            title: Text("Cuisine"),
            brightness: Brightness.dark,
            centerTitle: true,
            actions:   <Widget>[
              loading   ? Center(
                              child: CircularProgressIndicator(),
                            )
                          :
              notLoggedIn
                ? Container()
                :StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('cuisine').doc(widget.docId).collection('favourites').doc(_userData['id'].toString())
                      .snapshots(),
                  builder: (context, snapshot) {
                    return  !snapshot.hasData
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          :(snapshot.data['favourite'] == false)
                        ? InkWell(
                            onTap: () async {
                             FirebaseFirestore.instance.collection('cuisine').doc(widget.docId).collection('favourites').doc(_userData['id'].toString())
                                  .set({
                                'favourite': true,
                              });
                              Fluttertoast.showToast(
                                  msg:
                                      "${snapshot.data['name'].toString()} marked as favourite");
                            },
                            child: Icon(Icons.star_outline))
                        : InkWell(
                            onTap: () async {
                             FirebaseFirestore.instance.collection('cuisine').doc(widget.docId).collection('favourites').doc(_userData['id'].toString())
                                  .set({
                                'favourite': false,
                              });
                            },
                            child: Icon(Icons.star, color: Colors.red));
                  }),
              IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: DataSearch(widget.docId, suggestions));
                  })
            ]),
        body: loading   ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: height / 1.3,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('cuisine')
                          .doc(widget.docId)
                          .collection('Dishes')
                          .snapshots(),
                      builder: (context, snapshot) {
                        return !snapshot.hasData
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
                                padding: EdgeInsets.all(4),
                                child: GridView.builder(
                                    itemCount: snapshot.data.documents.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2),
                                    itemBuilder: (context, index) {
                                      var dishId = snapshot
                                          .data.documents[index].documentID;

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Receipe(
                                              dishName: snapshot
                                                  .data.documents[index]
                                                  .get('dishName'),
                                              docId: widget.docId,
                                              dishId: dishId,
                                              url: snapshot
                                                  .data.documents[index]
                                                  .get('url'),
                                              receipe: snapshot
                                                  .data.documents[index]
                                                  .get('receipe'),
                                              time: snapshot
                                                  .data.documents[index]
                                                  .get('timeRequired'),
                                            );
                                          }));
                                        },
                                        child: Card(
                                            elevation: 3,
                                            child: Container(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                  CircleAvatar(
                                                    minRadius: 50,
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data
                                                            .documents[index]
                                                            .get('url')),
                                                  ),
                                                  Text(
                                                    snapshot
                                                        .data.documents[index]
                                                        .get('dishName'),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ]))),
                                      );
                                    }),
                              );
                      })),
            ),
            notLoggedIn
                ? Container()
                : InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return addDish(
                            docId: widget.docId,
                            userId: _userData['id'].toString());
                      }));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      height: height / 15,
                      width: width / 1.2,
                      child: Center(
                          child: Text(
                        "Add dish",
                        style: TextStyle(fontSize: 18),
                      )),
                    ),
                  ),
          ],
        ));
  }
}

class DataSearch extends SearchDelegate<String> {
  DataSearch(this.docId, this.suggestions);
  List<String> suggestions = List();
  var docId;
  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for app bar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icons on the left of app bar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some search  result based on selection
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('cuisine')
          .doc(docId)
          .collection('Dishes')
          .where("dishName", isEqualTo: query)
          .snapshots(),
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.all(width / 20),
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: width / 20,
                        mainAxisSpacing: height / 30,
                        childAspectRatio: width / (height / 2),
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      var dishId = snapshot.data.documents[index].documentID;

                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Receipe(
                              dishName: snapshot.data.documents[index]
                                  .get('dishName'),
                              docId: docId,
                              dishId: dishId,
                              url: snapshot.data.documents[index].get('url'),
                              receipe:
                                  snapshot.data.documents[index].get('receipe'),
                              time: snapshot.data.documents[index]
                                  .get('timeRequired'),
                            );
                          }));
                        },
                        child: Card(
                            elevation: 3,
                            child: Container(
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                  CircleAvatar(
                                    minRadius: 50,
                                    backgroundImage: NetworkImage(snapshot
                                        .data.documents[index]
                                        .get('url')),
                                  ),
                                  Text(
                                    snapshot.data.documents[index]
                                        .get('dishName'),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ]))),
                      );
                    }),
              );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something
    final suggestionList =
        suggestions.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = suggestionList[index];
          showResults(context);
        },
        leading: Icon(Icons.group),
        title: RichText(
            text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                children: [
              TextSpan(
                text: suggestionList[index].substring(query.length),
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
            ])),
      ),
      itemCount: suggestionList.length,
    );
  }
}
