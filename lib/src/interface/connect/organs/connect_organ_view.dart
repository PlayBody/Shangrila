import 'dart:async';

import 'package:shangrila/src/common/apiendpoint.dart';
import 'package:shangrila/src/http/webservice.dart';
import 'package:shangrila/src/interface/component/form/main_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConnectOrganView extends StatefulWidget {
  final String organId;
  const ConnectOrganView({required this.organId, Key? key}) : super(key: key);

  @override
  _ConnectOrganView createState() => _ConnectOrganView();
}

class _ConnectOrganView extends State<ConnectOrganView> {
  late Future<List> loadData;

  String organName = '';
  String? organImage;
  String organAddress = '';
  String phoneNumber = '';
  String comment = '';
  String activeStartTime = '';
  String activeEndTime = '';
  String access = '';
  String parking = '';

  @override
  void initState() {
    super.initState();
    loadData = loadOrganData();
  }

  Future<List> loadOrganData() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadOrganInfo,
        {'organ_id': widget.organId}).then((value) => results = value);

    if (results['isLoad']) {
      var organ = results['organ'];
      organName = organ['organ_name'];
      organImage = organ['image'];
      organAddress = organ['address'] == null ? '' : organ['address'];
      phoneNumber = organ['phone'] == null ? '' : organ['phone'];
      comment = organ['comment'] == null ? '' : organ['comment'];
      activeStartTime = organ['active_start_time'] == null
          ? ''
          : DateFormat('HH:mm').format(
              DateTime.parse('2000-01-01 ' + organ['active_start_time']));
      activeEndTime = organ['active_end_time'] == null
          ? ''
          : DateFormat('HH:mm')
              .format(DateTime.parse('2000-01-01 ' + organ['active_end_time']));

      access = organ['access'] == null ? '' : organ['access'];
      parking = organ['parking'] == null ? '' : organ['parking'];
    }

    setState(() {});
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MainForm(
      title: organName,
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Column(
                children: [
                  _getOrganItem(),
                  SizedBox(height: 60),
                  _getPhoneContent(),
                  _getBussinessTime(),
                  _getAccessContent(),
                  _getParkContent(),
                  _getComment(),
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

  Widget _getOrganItem() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getOrganImage(),
          SizedBox(width: 12),
          _getOrganContent(),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  double labelWidth = 120;
  var rowPadding = EdgeInsets.fromLTRB(30, 10, 30, 10);
  var decorationTopLine =
      BoxDecoration(border: Border(top: BorderSide(color: Colors.grey)));
  Widget _getOrganImage() {
    return Container(
      width: 140,
      height: 90,
      child: organImage == null || organImage!.isEmpty
          ? Image.network(organImageUrl + 'no_image.jpg')
          : Image.network(organImageUrl + organImage!),
    );
  }

  Widget _getOrganContent() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '営業中',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Container(
              child: Text(organName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Container(child: Text(organAddress, style: TextStyle(fontSize: 12))),
          Container(
              child: ElevatedButton(
            child: Text('地図アプリで見る'),
            onPressed: () {},
          )),
        ],
      ),
    );
  }

  Widget _getPhoneContent() {
    return Container(
        padding: rowPadding,
        decoration: decorationTopLine,
        child: Row(
          children: [
            Container(width: labelWidth, child: Text('電話番号')),
            Container(child: Text(phoneNumber))
          ],
        ));
  }

  Widget _getBussinessTime() {
    return Container(
        padding: rowPadding,
        decoration: decorationTopLine,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: labelWidth, child: Text('営業時間')),
            Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 60, child: Text('平日')),
                    Container(
                        child: Text(activeStartTime + '~' + activeEndTime))
                  ],
                ),
                Row(
                  children: [
                    Container(width: 60, child: Text('土日祝')),
                    Container(child: Text('10:00～21:00'))
                  ],
                ),
              ],
            ))
          ],
        ));
  }

  Widget _getAccessContent() {
    return Container(
        padding: rowPadding,
        decoration: decorationTopLine,
        child: Row(
          children: [
            Container(width: labelWidth, child: Text('アクセス')),
            Container(child: Text(access))
          ],
        ));
  }

  Widget _getParkContent() {
    return Container(
        padding: rowPadding,
        decoration: decorationTopLine,
        child: Row(
          children: [
            Container(width: labelWidth, child: Text('駐車場')),
            Container(child: Text(parking))
          ],
        ));
  }

  Widget _getComment() {
    return Container(
        padding: rowPadding,
        decoration: decorationTopLine,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: labelWidth, child: Text('その他')),
            Expanded(child: Text(comment))
          ],
        ));
  }
}
