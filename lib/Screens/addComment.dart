import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/widgets.dart';
import 'package:cookbook/Screens/circle.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class addComment extends StatefulWidget {

  final docId,dishId;

  const addComment({this.docId, this.dishId});

  @override
  addCommentState createState() => addCommentState();
}

class addCommentState extends State<addComment> {
  TextEditingController comment = TextEditingController();

  File _image;
  final picker = ImagePicker();
  bool uploading = false;
  firebase_storage.Reference ref;
  final formKey = GlobalKey<FormState>();
  Size size = Size.fromWidth(110);

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
        'comments': comment.text,
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
        title: Text('Add cuisine'),
      ),
      body: Form(
        key: formKey,
        child: uploading
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
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
                      height: height / 1.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.08,
                                vertical: height * 0.01),
                            child: TextFormField(
                              maxLines: 4,
                              controller: comment,
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
                                hintText: "comment",
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
                                      Navigator.pop(context);
                                    });
                                  }
                                },
                                child: Text("Add cuisine")),
                          )
                        ],
                      )),
                ),
              ),
      ),
    );
  }
}
