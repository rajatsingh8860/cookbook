import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/Screens/dishes.dart';
import 'package:cookbook/Screens/facebookLogin.dart';
import 'package:cookbook/Screens/addCuisine.dart';
import 'package:cookbook/Screens/favouriteCuisine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> _userData;
  AccessToken _accessToken;
  bool _checking = true;
  var notLoggedIn = false;
  var loading = true;
  var notMarkedFavourite = true;

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
    return WillPopScope(
       onWillPop: (){
        SystemNavigator.pop();
      },
          child: Scaffold(

          floatingActionButton: notLoggedIn
              ? Container()
              : FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return addReceipe();
                    }));
                  }),
          appBar: AppBar(
            actions:[notLoggedIn
                ? Container()
                : 
               InkWell(
                onTap: () async {
                   await FacebookAuth.instance.logOut();
                        _accessToken = null;
                        _userData = null;
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return FaceBookLogin();
                        }));
                },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  height:height/20,
                  child: Center(child: Text('Log out')),
                  
                ),
                              ),
              ),
            ],
            brightness: Brightness.dark,
            title: Text("Cuisine"),
            centerTitle: true,
            
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: height,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('cuisine')
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
                                    var docId =
                                        snapshot.data.documents[index].documentID;

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) {
                                          return Dishes(docId: docId,
                                                          name: snapshot
                                                          .data.documents[index]
                                                          .get('name')
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
                                                  backgroundImage: NetworkImage(
                                                      snapshot
                                                          .data.documents[index]
                                                          .get('url')),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      snapshot
                                                          .data.documents[index]
                                                          .get('name'),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                                                                   ],
                                                )
                                              ]))),
                                    );
                                  }),
                            );
                    })),
          )),
    );
  }
}
