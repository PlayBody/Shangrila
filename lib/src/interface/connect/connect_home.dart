import 'package:shangrila/src/common/bussiness/common.dart';
import 'package:shangrila/src/common/bussiness/company.dart';
import 'package:shangrila/src/common/bussiness/message.dart';
import 'package:shangrila/src/common/bussiness/stamps.dart';
import 'package:shangrila/src/common/bussiness/user.dart';
import 'package:shangrila/src/common/const.dart';
import 'package:shangrila/src/interface/connect/event/event.dart';
import 'package:shangrila/src/interface/connect/product/product_list.dart';
import 'package:shangrila/src/model/company_site_model.dart';
import 'package:shangrila/src/model/usermodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../common/globals.dart' as globals;
import 'advise/connect_advises.dart';
import 'check/connect_check.dart';
import 'coupon/connect_coupons.dart';
import 'history/connect_history.dart';
import 'message/connect_message.dart';
import 'organs/connect_organ_list.dart';
import 'reserve/connect_reserve_organs.dart';
import 'layout/connect_bottom.dart';
import 'layout/connect_drawer.dart';
import 'sale/connect_sale.dart';

class ConnectHome extends StatefulWidget {
  const ConnectHome({Key? key}) : super(key: key);

  @override
  _ConnectHome createState() => _ConnectHome();
}

class _ConnectHome extends State<ConnectHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>(); // ADD THIS LINE
  late Future<List> loadData;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  String userQrCode = '';
  String userName = '';
  String userNo = '';
  String userGrade = '';
  int unreadMessageCount = 0;

  List<String> homeMenus = [];
  List<CompanySiteModel> sites = [];
  bool isUseStampAndCoupon = true;

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'connect-2-id', // id
        'connect-2-title', // title
        description: 'connect-1-description', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                // channel.description,
                icon: 'launch_background',
              ),
            ));
      }
      getUnreadMessageCount();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String notificationType = message.data['type'].toString();
      if (notificationType == 'message') {
        pushMessageMake();
      }
    });
  }

  Future<void> pushMessageMake() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ConnectMessage();
    }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List> loadInitData() async {
    UserModel user = await ClUser().getUserFromId(context, globals.userId);

    userQrCode = user.qrCode;
    userName = user.userFirstName + ' ' + user.userLastName;
    userNo = user.userNo;
    userGrade = user.grade;

    globals.userRank = await ClCoupon().loadRankData(context, globals.userId);

    if (userGrade == '1') userGrade = 'Advanced';

    sites = await ClCompany().loadCompanySites(context, APPCOMANYID);
    homeMenus = await ClCommon().loadConnectHomeMenu(context);

    // isUseStampAndCoupon = await ClCoupon().isHaveCouponOrStamp(context);

    globals.isCart = homeMenus.contains('connect_product');
    getUnreadMessageCount();
    setState(() {});
    return [];
  }

  Future<void> getUnreadMessageCount() async {
    unreadMessageCount = await ClMessage()
        .loadUnreadMessageCount(context, globals.userId, APPCOMANYID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    globals.connectHeaerTitle = 'メニュー';

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white, //.fromRGBO(244, 244, 234, 1),
        //appBar: MyConnetAppBar(),
        body: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Builder(
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/home_body_back.jpg'),
                        alignment: Alignment.bottomCenter),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 80,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Image.asset('images/logo.png'),
                                    ),
                                    Expanded(child: Container()),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      width: 70,
                                      height: 70,
                                      color: Colors.white.withOpacity(0.5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                              image: AssetImage(
                                                  'images/icon/person.png'),
                                              width: 16,
                                              color: Color(0xff5a5a5a)),
                                          SizedBox(height: 8),
                                          // Icon(Icons.person_rounded, size: 32, color: Color(0xff5a5a5a)),
                                          // Icon(Icons.person_rounded,
                                          //     size: 32,
                                          //     color: Color(0xff5a5a5a)),
                                          Text(
                                            globals.userName,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xff5a5a5a)),
                                          )
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _scaffoldKey
                                          .currentState!
                                          .openDrawer(),
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        color: primaryColor,
                                        child: Icon(Icons.menu,
                                            color: Colors.white, size: 32),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        visualDensity:
                                            VisualDensity(horizontal: -2),
                                        padding: EdgeInsets.all(0),
                                        elevation: 0,
                                        onPrimary: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Text('MEMBER\'S CARD',
                                    style: cardTitleStyle),
                              ),
                              _getMemberCard(),
                              _getMenuTitle(),
                            ]),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/cart_back.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      _getMenuListContent(),
                      ConnectBottomBar(isHome: true)
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        drawer: ConnectDrawer(),
      ),
    );
  }

  var cardTitleStyle = TextStyle(
      fontSize: 16,
      fontFamily: 'KozGoPr6',
      fontWeight: FontWeight.bold,
      color: Color(0xff4f3b20));

  var userLabelStyle = TextStyle(
    fontSize: 12,
    color: Color(0xff6cc6ce),
    fontFamily: 'Hiragino',
  );

  var userCommentStyle =
      TextStyle(color: Color(0xff5a5a5a), fontFamily: 'Hiragino', fontSize: 12);

  Widget _getMemberCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(children: [
        Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(image: AssetImage('images/logo.png'), width: 180),
            _getMemberName(),
            SizedBox(height: 8),
            _getUserNoRankContent(
                'images/icon/icon_person.png', '会員番号 No.' + userNo),
            SizedBox(height: 4),
            _getUserNoRankContent(
                'images/icon/icon_diamond.png',
                'RANK : ' +
                    (globals.userRank == null
                        ? ''
                        : globals.userRank!.rankName)),
          ],
        )),
        Expanded(child: Container()),
        _getQRGenerate(),
      ]),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/card_back.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(3, 3),
            blurRadius: 10.0,
          )
        ],
      ),
    );
  }

  Widget _getQRGenerate() {
    if (userQrCode == '') return Container();
    return Container(
      width: 110,
      height: 110,
      child: QrImage(
        padding: EdgeInsets.all(18),
        data: userQrCode,
        embeddedImage: AssetImage('images/qr_logo.png'),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(20, 20),
        ),
        version: QrVersions.auto,
        size: 220.0,
      ),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(100)),
    );
  }

  var cardFontColor = Color(0xFF271914);
  Widget _getMemberName() {
    return Container(
        child: Row(
      children: [
        Text('会員証 : ', style: userLabelStyle),
        Text(globals.userName, style: userCommentStyle),
      ],
    ));
  }

  Widget _getUserNoRankContent(icon, txt) {
    return Row(
      children: [
        Image(image: AssetImage(icon), width: 15, color: Color(0xff6cc6ce)),
        SizedBox(width: 6),
        Text(txt, style: userCommentStyle),
      ],
    );
  }

  Widget _getMenuTitle() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        alignment: Alignment.center,
        child: Text(
          'Menu',
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontFamily: 'Amazon',
          ),
        ));
  }

  Widget _getMenuListContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              ...homeMenus.map(
                (e) => e == 'connect_sale'
                    ? _getSaleMenuColumn()
                    : _getMenuItem(e),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMenuItem(menuKey) {
    if (menuKey == 'connect_reserve')
      return _getMenuContent('予  約', 'icon_calancer.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnectReserveOrgan();
        }));
      });

    if (menuKey == 'connect_check_in')
      return _getMenuContent('チェックイン', 'icon_checkin.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnectCheck();
        }));
      });
    if (menuKey == 'connect_message')
      return _getMenuContent('メッセージ', 'icon_messeage.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnectMessage();
        }));
      }, isMesseage: true);
    if (menuKey == 'connect_coupon' && isUseStampAndCoupon)
      return _getMenuContent('スタンプとクーポン', 'icon_brush.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnectCoupons();
        }));
      });
    if (menuKey == 'connect_advise')
      return _getMenuContent('先生のアドバイス', 'icon_advise.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnetAdvises();
        }));
      });
    if (menuKey == 'connect_history')
      return _getMenuContent('次の予約と履歴', 'icon_history.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnectHistory();
        }));
      });
    if (menuKey == 'connect_organ')
      return _getMenuContent('店舗一覧', 'icon_organlist.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnectOrganList();
        }));
      });
    if (menuKey == 'connect_product')
      return _getMenuContent('回数券購入', 'icon_card.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ProductList();
        }));
      });
    if (menuKey == 'connect_event')
      return _getMenuContent('イベントカレンダー', 'icon_card.png', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ConnectEvent();
        }));
      });

    return Container();
  }

  Widget _getSaleMenuColumn() {
    return Column(children: [
      ...sites.map(
        (e) => _getMenuContent(
          e.title == '' ? 'タイトルなし' : e.title,
          sites.indexOf(e) == 0 ? 'icon_sale.png' : 'icon_blog.png',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) {
            return ConnectSale(url: e.url);
          })),
        ),
      )
    ]);
  }

  Widget _getMenuContent(label, iconPath, tapFunc, {bool isMesseage = false}) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffd9d9d9)))),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ListTile(
          leading: Container(
              width: 30,
              child: Image.asset('images/icon/' + iconPath, height: 60)),
          trailing: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Color(0xfff16982),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 18,
              )),
          // Image.asset('connect_images/icon_arrow_right.png',
          //     height: 26),
          contentPadding: EdgeInsets.only(left: 2, right: 0),
          onTap: tapFunc,
          title: Stack(children: [
            Positioned(
                child: Container(
                    alignment: Alignment.center,
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(82, 82, 82, 1))))),
            if (isMesseage && unreadMessageCount > 0)
              Positioned(
                  right: 40,
                  child: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red),
                      child: Text(unreadMessageCount.toString(),
                          style: TextStyle(fontSize: 14, color: Colors.white))))
          ])),
    );
  }
}
