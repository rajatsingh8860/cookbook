import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/widgets.dart';
import 'package:cookbook/Screens/circle.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AllComments extends StatefulWidget {

  final docId,dishId;

  const AllComments({this.docId, this.dishId});

  @override
  AllCommentsState createState() => AllCommentsState();
}

class AllCommentsState extends State<AllComments> {
  TextEditingController notes = TextEditingController();

  File _image;
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
       FirebaseFirestore.instance
                        .collection('cuisine')
                        .doc(widget.docId)
                        .collection('Dishes')
                        .doc(widget.dishId)
                    .collection('comment').add({
        'comments': notes.text,
      }).then((value) {
        setState(() {
          uploading = false;
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
        title: Text('Notes'),
      ),
      body: SingleChildScrollView(
              child: Form(
          key: formKey,
          child: uploading
              ? Container(
                margin: EdgeInsets.only(top:height/2.4,left:width/2),
                child: CircularProgressIndicator())
              : Center(
                  child: Container(
                      width: width,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  height:   notLoggedIn
                ? height
                :height/1.7,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('cuisine')
                        .doc(widget.docId)
                        .collection('Dishes')
                        .doc(widget.dishId)
                    .collection('comment')
                        .snapshots(),
                    builder: (context, snapshot) {



                      return !snapshot.hasData ? Center(
                        child: CircularProgressIndicator(),
                      ) :
                      Container(
                        padding: EdgeInsets.all(4),
                        child: GridView.builder(
                              itemCount: snapshot.data.documents.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: height/width*2,
                                  crossAxisCount: 1),
                              itemBuilder: (context, index) {


                                return InkWell(

                                  child: Card(

                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(snapshot.data.documents[index].get('comments'),style: TextStyle(fontWeight:FontWeight.bold),),
                                      )),
                                );
                              }),
                      );
                    })),
            ),
          ),
                          ),
                            notLoggedIn
                ? Container()
                :Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.08,
                                vertical: height * 0.01),
                            child: TextFormField(
                              maxLines: 4,
                              controller: notes,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                hintText: "note",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
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
                            width: width / 1.2,
                            child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState.validate()) {
                                    addData().then((value) {
                                    });
                                  }
                                },
                                child: Text("Add note")),
                          )
                        ],
                      )),
                ),
        ),
      ),
    );
  }
}
