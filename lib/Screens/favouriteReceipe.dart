import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/Screens/allComments.dart';
import 'package:cookbook/Screens/notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FavouriteReceipe extends StatefulWidget {
  final docId;
  final dishName;
  final dishId;
  final url, receipe, time;

  const FavouriteReceipe({
    this.docId,
    this.dishName,
    this.dishId,
    this.url,
    this.receipe,
    this.time,
  });
  @override
  FavouriteReceipeState createState() => FavouriteReceipeState();
}

class FavouriteReceipeState extends State<FavouriteReceipe> {
  Map<String, dynamic> _userData;
  AccessToken _accessToken;
  bool _checking = true;
  var notLoggedIn = false;
  var loading = true;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(widget.dishName),
          centerTitle: true,
        ),
        body: Column(
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
                        var docId = snapshot.data.documents[0].documentID;

                        return !snapshot.hasData
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
                                padding: EdgeInsets.all(4),
                                child: SingleChildScrollView(
                                  child: Container(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                        CircleAvatar(
                                          minRadius: 60,
                                          backgroundImage:
                                              NetworkImage(widget.url),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Card(
                                            elevation: 5,
                                            margin: EdgeInsets.only(
                                                top: height / 30),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Time Required",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18)),
                                                  Text(
                                                    "${widget.time.toString()} minutes",
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Card(
                                            elevation: 5,
                                            margin: EdgeInsets.only(
                                                top: height / 30),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                widget.receipe,
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ])),
                                ));
                      }),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AllComments(
                            docId: widget.docId, dishId: widget.dishId);
                      }));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: height / 15,
                      width:   notLoggedIn
                ? width/1.2
                :width / 3,
                      child: Center(
                        child: Text(
                          "Comments",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                   notLoggedIn
                ? Container()
                : InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Notes(
                            docId: widget.docId, dishId: widget.dishId);
                      }));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: width / 3,
                      height: height / 15,
                      child: Center(
                        child: Text(
                          "Notes",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
