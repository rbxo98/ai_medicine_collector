import 'dart:developer';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:medicine_collection_box/admin_page.dart';
import 'package:medicine_collection_box/howto.dart';
import 'package:medicine_collection_box/loading.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
      ],
    );
    return MaterialApp(
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainState();
}

class MainState extends State<Main> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  late TabController tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<Map<String, Marker>>? _markers;
  var logger = Logger();
  final LatLng _center = LatLng(37.4772172924214, 126.629107679813);
  Uint8List? markerIcon;
  bool admin_status = false;
  LatLng? nowpos;
  int admin = 0;

  @override
  void initState() {
    _markers = showMarker(_center);
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Marker> getMarker(
      String MachineNum, Map<String, dynamic> MachineList) async {
    markerIcon = await getBytesFromAsset('lib/assets/marker.png', 50);
    var address = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(MachineList['lat'], MachineList['lng']));
    print(address[0]);
    return Marker(
        markerId: MarkerId(MachineNum),
        icon: BitmapDescriptor.fromBytes(markerIcon!),
        position: LatLng(MachineList['lat'], MachineList['lng']),
        onTap: () async {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      title: Text("폐의약품 수거함 상태"),
                      titleTextStyle: TextStyle(color: Colors.black),
                      centerTitle: true,
                      iconTheme: IconThemeData(color: Colors.black),
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularPercentIndicator(
                                    radius: 60,
                                    center: Text(
                                      "부피 " +
                                          MachineList['volume'].toString() +
                                          "%",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    lineWidth: 12,
                                    percent: MachineList['volume'].toDouble(),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("주소: " +
                                              address[0]
                                                  .addressLine!
                                                  .substring(5)),
                                          Text(""),
                                          Text(""),
                                          Text("세부위치: " +
                                              MachineList['detailinfo']),
                                          Text(""),
                                          Text(""),
                                          Image.asset(
                                              "lib/assets/중구보건소3 ICL_0724.jpg"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ));
              });
        });
  }

  Stream<Map<String, Marker>> showMarker(LatLng pos) async* {
    Map<String, Marker> items = {};
    var meta = await _db
        .collection('MachineData')
        .where('lat', isGreaterThan: pos.latitude - 0.05)
        .where('lat', isLessThan: pos.latitude + 0.05)
        .get()
        .then((value) {
      return value;
    });

    var data = meta.docs.where((element) =>
        element.data()['lng'] > pos.longitude - 0.05 &&
        element.data()['lng'] < pos.longitude + 0.05);
    for (var machinedata in data) {
      await getMarker(
              machinedata.data()['machineid'].toString(), machinedata.data())
          .then((marker) {
        items[machinedata.data()['machineid'].toString()] = marker;
      });
    }
    yield items;
  }

  Padding TabWidget(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Padding HowtoWidget(String text) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
          onTap: () {
            switch (text) {
              case "capsule":
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => how_capsule()));
                break;
              case "powder":
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => how_powder()));
                break;
              case "liquid":
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => how_liquid()));
                break;
              case "ointment":
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => how_ointment()));
                break;
            }
          },
          child: Image.asset(
            "lib/assets/" + text + ".png",
            scale: 2.45,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Flexible(
        flex: 8,
        child: Stack(children: [
          StreamBuilder<Map<String, Marker>>(
              stream: _markers,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  GoogleMap map = GoogleMap(
                    onCameraMove: (cameraposition) {
                      setState(() {
                        nowpos = cameraposition.target;
                      });
                    },
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15,
                    ),
                    markers: snapshot.data!.values.toSet(),
                  );
                  return map;
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _markers = showMarker(nowpos!);
                      });
                    },
                    child: Text("이 지역 새로고침"))),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Visibility(
                  visible: admin_status,
                  child: ElevatedButton(
                      onPressed: admin_status
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context0) => admin_page()));
                            }
                          : null,
                      child: Text("관리자")))),
        ]),
      ),
      Flexible(
        flex: 8,
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.white,
                bottom: TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 1.5, color: Colors.lightBlue),
                    insets: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  tabs: [
                    TabWidget("항목별\n배출 요령"),
                    TabWidget("FAQ"),
                    TabWidget("Q&A"),
                    TabWidget("자료실"),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HowtoWidget("capsule"),
                                HowtoWidget("powder")
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HowtoWidget("liquid"),
                                HowtoWidget("ointment")
                              ],
                            )
                          ],
                        ),
                      )),
                  Container(child: Text("intab2")),
                  GestureDetector(
                    child: Container(child: Text("intab3")),
                    onDoubleTap: () {
                      setState(() {
                        admin++;
                        print(admin);
                        if (admin == 1) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController idcontroller =
                                    TextEditingController();
                                TextEditingController pwcontroller =
                                    TextEditingController();
                                return AlertDialog(
                                  content: SizedBox(
                                    height: 100,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: idcontroller,
                                        ),
                                        TextFormField(
                                          controller: pwcontroller,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          print(idcontroller.text);
                                          print(pwcontroller.text);
                                          try {
                                            final res = await FirebaseAuth
                                                .instance
                                                .signInWithEmailAndPassword(
                                                    email: idcontroller.text,
                                                    password: pwcontroller.text)
                                                .then((value) {
                                              setState(() {
                                                admin_status = true;
                                                Navigator.pop(context);
                                              });
                                            });
                                          } on FirebaseAuthException catch (e) {
                                            if (e.code == 'user-not-found') {
                                              logger.w(
                                                  'No user found for that email.');
                                            } else if (e.code ==
                                                'wrong-password') {
                                              logger.w(
                                                  'Wrong password provided for that user.');
                                            }
                                          }
                                        },
                                        child: Text("확인")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("취소")),
                                  ],
                                );
                              });
                          admin = 0;
                        }
                      });
                    },
                  ),
                  Container(child: Text("intab4")),
                ],
              )),
        ),
      ),
    ]));
  }
}
