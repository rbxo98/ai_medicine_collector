import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicine_collection_box/model.dart';

class loading_page extends StatelessWidget {
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(children: [Image.asset("lib/assets/loading_image.jpg"),
      Center(
        child: CircularProgressIndicator(),
      )]),
    );
  }
}
