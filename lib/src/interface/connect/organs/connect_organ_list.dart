import 'dart:async';
import 'dart:math';

import 'package:shangrila/src/common/apiendpoint.dart';
import 'package:shangrila/src/common/const.dart';
import 'package:shangrila/src/http/webservice.dart';
import 'package:shangrila/src/interface/component/form/main_form.dart';
import 'package:shangrila/src/interface/connect/organs/connect_organ_view.dart';
import 'package:shangrila/src/model/organmodel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class ConnectOrganList extends StatefulWidget {
  const ConnectOrganList({Key? key}) : super(key: key);

  @override
  _ConnectOrganList createState() => _ConnectOrganList();
}

class _ConnectOrganList extends State<ConnectOrganList> {
  late Future<List> loadData;

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition? initCameraPosition;

  List<OrganModel> organs = [];
  String openQuestion = '';

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  Future<List> loadInitData() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    }
    
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng initialPosition = LatLng(position.latitude, position.longitude);

    initCameraPosition = CameraPosition(
      target: initialPosition,
      zoom: 14,
    );
    setState(() {});

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadOrganListUrl,
        {'company_id': APPCOMANYID}).then((value) => results = value);
    organs = [];
    if (results['isLoad']) {
      for (var item in results['organs']) {
        if (item['lat'] == null ||
            item['lon'] == null ||
            double.tryParse(item['lat']) == null ||
            double.tryParse(item['lon']) == null) {
          item['distance'] = '';
        } else {
          LatLng latlong =
              new LatLng(double.parse(item['lat']), double.parse(item['lon']));
          item['distance'] = clacDistance(initialPosition, latlong);
          _markers.add(Marker(
              markerId: MarkerId("a"),
              draggable: true,
              position: latlong,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              onDragEnd: (_currentlatLng) {
                latlong = _currentlatLng;
              }));
        }
        organs.add(OrganModel.fromJson(item));
      }
    }

    setState(() {});
    return [];
  }

  int clacDistance(LatLng pos1, LatLng pos2) {
    const double pi = 3.1415926535897932;
    const R = 6371e3; // metres
    var fLat1 = pos1.latitude * pi / 180; // φ, λ in radians
    var fLat2 = pos2.latitude * pi / 180;
    var si = (pos2.latitude - pos1.latitude) * pi / 180;
    var ra = (pos2.longitude - pos1.longitude) * pi / 180;

    var a = sin(si / 2) * sin(si / 2) +
        cos(fLat1) * cos(fLat2) * sin(ra / 2) * sin(ra / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double d = R * c;

    return d.floor();
  }

  @override
  Widget build(BuildContext context) {
    return MainForm(
      title: '店舗一覧',
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Column(
                children: [
                  _getOrganSearch(),
                  // _getMapView(),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Image(image: AssetImage('images/organ_map_bar.jpg')),
                        Container(
                          height: 270,
                          decoration: BoxDecoration(color: Colors.grey),
                          child: GoogleMap(
                            markers: _markers,
                            mapType: MapType.normal,
                            initialCameraPosition: initCameraPosition!,
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                          ),
                        ),
                        Image(image: AssetImage('images/organ_map_bar.jpg')),
                        Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('images/organ_back.jpg'))),
                          child: Column(
                            children: [
                              Image(
                                  image: AssetImage(
                                      'images/organ_floor_match.png')),
                              ...organs.map((e) => _getOrganItem(e)),
                            ],
                          ),
                        )
                      ],
                    )),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  var txtQuestionStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  var txtAnswerStyle = TextStyle(fontSize: 18);

  Widget _getOrganSearch() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8),
          isDense: true,
          prefixIcon: Icon(Icons.search, size: 18),
          hintText: '店舗を検索',
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  // Widget _getMapView() {
  //   return Container(
  //     height: 180,
  //     decoration: BoxDecoration(color: Colors.grey),
  //     child: GoogleMap(
  //       markers: _markers,
  //       mapType: MapType.terrain,
  //       initialCameraPosition: initCameraPosition!,
  //       onMapCreated: (GoogleMapController controller) {
  //         _controller.complete(controller);
  //       },
  //     ),
  //   );
  // }

  Widget _getOrganItem(OrganModel item) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return ConnectOrganView(organId: item.organId);
          }));
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            // boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getOrganImage(item),
              SizedBox(width: 12),
              _getOrganContent(item),
              SizedBox(width: 8),
            ],
          ),
        ));
  }

  Widget _getOrganImage(item) {
    return Container(
      width: 110,
      height: 110,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: item.organImage == null || item.organImage!.isEmpty
            ? Image.network(organImageUrl + 'no-organ-image-company-1.png',
                fit: BoxFit.contain)
            : Image.network(organImageUrl + item.organImage!,
                fit: BoxFit.cover),
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _getOrganContent(OrganModel item) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              padding: EdgeInsets.only(top: 4),
              child: Row(children: [
                Text(
                  '営業中',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xffe15d92),
                      fontWeight: FontWeight.bold),
                ),
                Expanded(child: Container()),
                Text(
                    (item.distance == null || item.distance == '')
                        ? ''
                        : (item.distance! + 'm'),
                    style: TextStyle(fontSize: 16))
              ])),
          Container(
              child: Text(item.organName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff525252)))),
          Container(
              child: Text(item.organAddress!,
                  style: TextStyle(fontSize: 12, color: Color(0xff525252)))),
          Container(
            child: Row(children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: Colors.green,
                    padding: EdgeInsets.all(6),
                    visualDensity: VisualDensity(vertical: -3, horizontal: 3)),
                child: Text('電話問い合わせ', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  callDialog(
                      context, item.organPhone == null ? '' : item.organPhone!);
                },
              ),
              Expanded(child: Container()),
              if (item.snsurl != null && item.snsurl != '')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Color(0xff4db5da),
                      padding: EdgeInsets.all(6),
                      visualDensity:
                          VisualDensity(vertical: -3, horizontal: 3)),
                  child: Text('twitter', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    callDialog(context,
                        item.organPhone == null ? '' : item.organPhone!);
                  },
                ),
              // TextButton(
              //     onPressed: () {
              //       Navigator.push(context, MaterialPageRoute(builder: (_) {
              //         return ConnectOrganView(organId: item.organId);
              //       }));
              //     },
              //     child: Text('詳細', style: TextStyle(fontSize: 14)))
            ]),
          )
        ],
      ),
    );
  }

  void callDialog(BuildContext context, String phone) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  alignment: Alignment.center,
                  child: Text('電話問い合わせ',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    primary: Colors.orange),
                child: Container(
                    child: Row(children: [
                  Container(
                      padding: EdgeInsets.only(left: 30),
                      alignment: Alignment.center,
                      width: 60,
                      child: Icon(Icons.phone, color: Colors.white, size: 42)),
                  Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text('お問い合わせ', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text(phone, style: TextStyle(fontSize: 22))
                        ],
                      ))
                ])),
                onPressed: () {
                  launchUrl(Uri.parse("tel://" + phone));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
