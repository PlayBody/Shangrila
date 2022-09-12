import 'package:shangrila/src/common/apiendpoint.dart';
import 'package:shangrila/src/http/webservice.dart';
import 'package:shangrila/src/interface/component/form/main_form.dart';
import 'package:shangrila/src/model/couponmodel.dart';
import 'package:flutter/material.dart';
import '../../../common/globals.dart' as globals;
import 'connect_coupon_complete.dart';

class ConnectCouponConfirm extends StatefulWidget {
  const ConnectCouponConfirm({Key? key}) : super(key: key);

  @override
  _ConnectCouponConfirm createState() => _ConnectCouponConfirm();
}

class _ConnectCouponConfirm extends State<ConnectCouponConfirm> {
  late Future<List> loadData;

  List<CouponModel> coupons = [];

  @override
  void initState() {
    super.initState();
    loadData = loadMenuData();
  }

  Future<List> loadMenuData() async {
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiLoadCouponListUrl,
        {'user_id': globals.userId}).then((value) => results = value);
    coupons = [];
    if (results['isLoad']) {
      for (var item in results['coupons']) {
        coupons.add(CouponModel.fromJson(item));
      }

      setState(() {});
    }
    return [];
  }

  Future<void> userCoupon() async {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ConnectCouponComplete();
    }));
  }

  var txtTitleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  var txtContentStyle = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return MainForm(
      title: 'スタンプ',
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60),
                  Container(
                    alignment: Alignment.center,
                    child: Text('スタンプ5個を使用しますか？', style: txtTitleStyle),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        ElevatedButton(
                            onPressed: () {
                              userCoupon();
                            },
                            child: Text('はい')),
                        SizedBox(width: 40),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('いいえ')),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                  Container(
                    child: Text('', style: txtContentStyle),
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
}
