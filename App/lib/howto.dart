import 'package:flutter/material.dart';

class how_capsule extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:Text("캡슐 배출 방법"),
        titleTextStyle: TextStyle(color: Colors.black),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body:Padding(
        padding: EdgeInsets.all(8),
        child: Text("캡슐 분리배출 요령"),
      )
    );
  }

}

class how_powder extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title:Text("가루약 배출 방법"),
          titleTextStyle: TextStyle(color: Colors.black),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body:Padding(
          padding: EdgeInsets.all(8),
          child: Text("가루약 분리배출 요령"),
        )
    );
  }

}

class how_liquid extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title:Text("물약 배출 방법"),
          titleTextStyle: TextStyle(color: Colors.black),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body:Padding(
          padding: EdgeInsets.all(8),
          child: Text("물약 분리배출 요령"),
        )
    );
  }

}

class how_ointment extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title:Text("연고형 배출 방법"),
          titleTextStyle: TextStyle(color: Colors.black),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body:Padding(
          padding: EdgeInsets.all(8),
          child: Text("연고형 분리배출 요령"),
        )
    );
  }

}