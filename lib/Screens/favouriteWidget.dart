import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomSettingsWidget extends StatefulWidget {
  
  var isEditable;


   CustomSettingsWidget({this.isEditable});

  @override
  _CustomSettingsWidgetState createState() => _CustomSettingsWidgetState();
}

class _CustomSettingsWidgetState extends State<CustomSettingsWidget> {
  var editable = false;
  var onChange = false;
  var userId;
  TextEditingController name = TextEditingController();
  

   @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: widget.isEditable
            ? IconButton(icon: Icon(Icons.star_outlined), onPressed: (){
                        setState(() {
                          widget.isEditable = !widget.isEditable;
                        });
            }):IconButton(icon: Icon(Icons.star_outlined,color: Colors.black), onPressed: (){
                        setState(() {
                          widget.isEditable =  !widget.isEditable;
                        });
            })
            );
  }
}
