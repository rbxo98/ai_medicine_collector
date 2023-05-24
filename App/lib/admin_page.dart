import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';

class admin_page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => adminState();
}

class adminState extends State<admin_page> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: InkWell(
              onTap: () async {
                await _db
                    .collection('MachineData')
                    .where('volume', isGreaterThan: 0.7)
                    .get()
                    .then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              collect_target_page(data: value)));
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                child: Center(
                    child: Text(
                  "수거 대상 확인",
                  textAlign: TextAlign.center,
                )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                child: Center(
                    child: Text(
                  "Q&A 답변 작성",
                  textAlign: TextAlign.center,
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class collect_target_page extends StatefulWidget {
  QuerySnapshot? data;

  collect_target_page({this.data});

  @override
  State<StatefulWidget> createState() => collect_target_state(data: data);
}

class collect_target_state extends State<collect_target_page> {
  QuerySnapshot? data;
  Future<List<Container>>? items;

  collect_target_state({
    this.data,
  });

  Future<List<Container>> getListViewItem(QuerySnapshot data) async {
    List<Container> items = [];
    for (var machines in data.docs) {
      var machine = machines.data() as Map<String, dynamic>;
      print(machine['lat'].runtimeType);
      List<Address> addresslist = await Geocoder.local
          .findAddressesFromCoordinates(
              Coordinates(machine['lat'], machine['lng'])) as List<Address>;
      String address = addresslist[0].addressLine!;
      items.add(Container(
        color: Colors.white,
        child: Column(
          children: [
            Text(address.substring(5)),
            Text(machine['detailinfo']),
            Text(machine['machineid'].toString()),
            Text(machine['volume'].toString()),
          ],
        ),
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    items = getListViewItem(data!);
    return Scaffold(
      body: FutureBuilder<List<Container>>(
          future: items,
          builder:
              (BuildContext context, AsyncSnapshot<List<Container>?> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!,
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
