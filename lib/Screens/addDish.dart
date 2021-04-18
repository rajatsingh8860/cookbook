import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/widgets.dart';
import 'package:cookbook/Screens/circle.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class addDish extends StatefulWidget {

  final docId,userId;

  const addDish({this.docId, this.userId});

  @override
  addDishState createState() => addDishState();
}


class addDishState extends State<addDish> {

  TextEditingController dishName = TextEditingController();
  TextEditingController timeRequired = TextEditingController();
  TextEditingController receipe = TextEditingController();

  File _image;
  var userId;
  final picker = ImagePicker();
  bool uploading = false;
  firebase_storage.Reference ref;
  final formKey = GlobalKey<FormState>();
  Size size = Size.fromWidth(110);
  
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

  
  getImage() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(pickedFile?.path);
    });
  }

  addData() async {
    setState(() {
      uploading = true;
    });

    ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image.path)}');
    await ref.putFile(_image).whenComplete(() async {
      var downloadUrl = await ref.getDownloadURL(); //.then((value) {
     await FirebaseFirestore.instance
                      .collection('cuisine')
                      .doc(widget.docId)
                      .collection('Dishes').add({
        'url': downloadUrl,
        'dishName': dishName.text,
        'timeRequired':timeRequired.text,
        'receipe':receipe.text,
        'favourite':'false'
      });
      

       FirebaseFirestore.instance
                      .collection('cuisine')
                      .doc(widget.docId)
                      .collection('Dishes').get().then((QuerySnapshot value){
         value.docs.forEach((element) {
           FirebaseFirestore.instance
                      .collection('cuisine')
                      .doc(widget.docId)
                      .collection('Dishes').doc(element.id).collection('favourites').doc(_userData['id'].toString())
           .set({
             'favourite':false
          });
         });
       })
      .then((value) {
        setState(() {
          uploading = false;
        });
      });
    });
  }

 

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: Text('Add Dish'),
      ),
      body:  uploading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
              child: Form(
          key: formKey,
          child:Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    margin: EdgeInsets.only(top:height/30),
                    decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                      boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                    ),
                      width: width,
                       height: height/1.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _image == null
                              ? GestureDetector(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: Container(
                                    child: CircleAvatar(
                                        radius: height / 15,
                                        backgroundColor: Colors.blue,
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: height / 40),
                                                child: Icon(Icons.account_circle,
                                                    color: Colors.white,
                                                    size: height / 20),
                                              ),
                                              Text(
                                                "Add Photo",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: Container(
                                    child: CircleImage(
                                      size: size,
                                      child: Image.file(
                                        _image,
                                        width: size.width,
                                        height: size.height,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                ),

                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.08,
                                vertical: height * 0.01),
                            child: TextFormField(
                              controller: dishName,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                                hintText: "Dish Name",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                              ),
                              validator: (v) {
                                if (v.trim().isEmpty)
                                  return 'Please enter something';
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.08,
                                vertical: height * 0.01),
                            child: TextFormField(
                               keyboardType: TextInputType.number,
                              controller: timeRequired,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                                hintText: "Minutes Required",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                              ),
                              validator: (v) {
                                if (v.trim().isEmpty)
                                  return 'Please enter something';
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.08,
                                vertical: height * 0.01),
                            child: TextFormField(
                             maxLines:4,
                              controller: receipe,
                              decoration: InputDecoration(
                              
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                                hintText: "Receipe",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 1.0),
                                ),
                              ),
                              validator: (v) {
                                if (v.trim().isEmpty)
                                  return 'Please enter something';
                                return null;
                              },
                            ),
                          ),
                         Container(
                           width: width/1.3,
                           child: ElevatedButton(onPressed: (){
                              if (formKey.currentState.validate()) {
                                if(_image == null){
                                  Fluttertoast.showToast(msg:"Please add image");
                                }
                                else if(_image != null){
                                addData().then((value) {
                                  Navigator.pop(context);
                                });
                              }
                              }
                           }, child: Text("Add Dish")),
                         )
                        ],
                      )),
                ),
              ),
        ),
      ),
    );
  }
}
