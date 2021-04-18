import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/Screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

String prettyPrint(Map json) {
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}

class FaceBookLogin extends StatefulWidget {
  @override
  FaceBookLoginState createState() => FaceBookLoginState();
}

class FaceBookLoginState extends State<FaceBookLogin> {
  Map<String, dynamic> _userData;
  AccessToken _accessToken;
  bool _checking = true;
  var loading = true;
  var notLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
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

  Future<void> _login() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;
    } else {}

    setState(() {
      _checking = false;
    });
    Fluttertoast.showToast(msg: "Logged in !!");
     FirebaseFirestore.instance
                                  .collection('favourite cuisine')
                                  .doc(_userData['id'].toString()).set({'name':""});
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }

  Future<void> _logOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: const Text('Facebook login'),
          centerTitle: true,
        ),
        body: (loading)
            ? Center(child: CircularProgressIndicator())
            : _checking
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: EdgeInsets.only(top: height / 2),
                            child: Column(
                              children: [
                                Text(
                                  "Welcome to  ",
                                  style: TextStyle(fontSize: 30),
                                ),
                                Text(
                                  "cuisine hub !!",
                                  style: TextStyle(fontSize: 30),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: EdgeInsets.only(top: height / 3),
                            width: width / 1.2,
                            child: ElevatedButton(
                              child: Text(
                                _userData != null ? "LOGOUT" : "LOGIN",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _userData != null ? _logOut : _login,
                            ),
                          ),
                        ),
                        SizedBox(height: height / 30),
                        InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Home();
                              }));
                            },
                            child: Container(
                                height: height / 20,
                                child: Center(
                                    child: Text(
                                  "Skip for now",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold),
                                ))))
                      ],
                    ),
                  ),
      ),
    );
  }
}
