import 'package:shangrila/src/common/bussiness/common.dart';
import 'package:shangrila/src/common/bussiness/company.dart';
import 'package:shangrila/src/common/bussiness/message.dart';
import 'package:shangrila/src/common/bussiness/stamps.dart';
import 'package:shangrila/src/common/bussiness/user.dart';
import 'package:shangrila/src/common/const.dart';
import 'package:shangrila/src/interface/connect/event/event.dart';
import 'package:shangrila/src/interface/connect/product/product_list.dart';
import 'package:shangrila/src/model/company_site_model.dart';
import 'package:shangrila/src/model/home_menu_model.dart';
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

  List<HomeMenuModel> homeMenus = [];
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
    if (globals.userId != '') {
      UserModel user = await ClUser().getUserFromId(context, globals.userId);
      userQrCode = user.qrCode;
      userName = user.userFirstName + ' ' + user.userLastName;
      userNo = user.userNo;
      userGrade = user.grade;

      globals.userRank = await ClCoupon().loadRankData(context, globals.userId);
      if (userGrade == '1') userGrade = 'Advanced';

      getUnreadMessageCount();
    } else {
      globals.userName = 'ログインなし';
    }
    sites = await ClCompany().loadCompanySites(context, APPCOMANYID);
    homeMenus = await ClCommon().loadConnectHomeMenu(context);

    // isUseStampAndCoupon = await ClCoupon().isHaveCouponOrStamp(context);

    globals.isCart = homeMenus
        .where((element) => element.menuKey == 'connect_product')
        .isNotEmpty;
    setState(() {});
    return [];
  }

  Future<void> getUnreadMessageCount() async {
    unreadMessageCount = await ClMessage()
        .loadUnreadMessageCount(context, globals.userId, APPCOMANYID);
    setState(() {});
  }

  void onTapHomeMenu(context, HomeMenuModel homeMenu, {String siteUrl = ''}) {
    if (!homeMenu.isFree && globals.userId == '') {
      Navigator.pushNamed(context, '/Login');
      return;
    }

    if (homeMenu.menuKey == 'connect_reserve')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectReserveOrgan();
      }));

    if (homeMenu.menuKey == 'connect_check_in')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectCheck();
      }));
    if (homeMenu.menuKey == 'connect_message')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectMessage();
      }));
    if (homeMenu.menuKey == 'connect_coupon' && isUseStampAndCoupon)
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectCoupons();
      }));
    if (homeMenu.menuKey == 'connect_advise')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnetAdvises();
      }));
    if (homeMenu.menuKey == 'connect_history')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectHistory();
      }));
    if (homeMenu.menuKey == 'connect_organ')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectOrganList();
      }));
    if (homeMenu.menuKey == 'connect_product')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ProductList();
      }));
    if (homeMenu.menuKey == 'connect_event')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectEvent();
      }));
    if (homeMenu.menuKey == 'connect_sale')
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectSale(url: siteUrl);
      }));
  }

  @override
  Widget build(BuildContext context) {
    globals.connectHeaerTitle = 'メニュー';

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
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
                              _getHeader(),
                              SizedBox(height: 8),
                              if (globals.userId != '')
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text('MEMBER\'S CARD',
                                      style: cardTitleStyle),
                                ),
                              if (globals.userId != '') _getMemberCard(),
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
      )),
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

  Widget _getHeader() {
    return Container(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8),
          Container(
              padding: EdgeInsets.only(top: 15),
              child: Image.asset('images/logo.png')),
          Expanded(child: Container()),
          Container(
              padding: EdgeInsets.only(top: 10),
              width: 70,
              height: 70,
              color: Colors.white.withOpacity(0.5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image: AssetImage('images/icon/person.png'),
                        width: 16,
                        color: Color(0xff5a5a5a)),
                    SizedBox(height: 8),
                    Text(globals.userName,
                        style:
                            TextStyle(fontSize: 10, color: Color(0xff5a5a5a)))
                  ])),
          ElevatedButton(
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            child: Container(
              width: 70,
              height: 70,
              color: primaryColor,
              child: Icon(Icons.menu, color: Colors.white, size: 32),
            ),
            style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity(horizontal: -2),
                padding: EdgeInsets.all(0),
                elevation: 0,
                onPrimary: Colors.white),
          ),
        ],
      ),
    );
  }

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
              ...homeMenus.map((e) => e.menuKey == 'connect_sale'
                  ? Column(
                      children: [...sites.map((e) => _getSiteMenuContent(e))])
                  : _getMenuContent(e)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMenuContent(HomeMenuModel homeMenu) {
    String iconPath = '';
    int badgeCount = 0;
    switch (homeMenu.menuKey) {
      case 'connect_reserve':
        iconPath = 'icon_calancer.png';
        break;
      case 'connect_check_in':
        iconPath = 'icon_checkin.png';
        break;
      case 'connect_message':
        badgeCount = unreadMessageCount;
        iconPath = 'icon_messeage.png';
        break;
      case 'connect_coupon':
        iconPath = 'icon_brush.png';
        break;
      case 'connect_advise':
        iconPath = 'icon_advise.png';
        break;
      case 'connect_history':
        iconPath = 'icon_history.png';
        break;
      case 'connect_organ':
        iconPath = 'icon_organlist.png';
        break;
      case 'connect_product':
        iconPath = 'icon_card.png';
        break;
      case 'connect_event':
        iconPath = 'icon_card.png';
        break;
      default:
    }
    return _getMenuItemContent(
        homeMenu.label, iconPath, () => onTapHomeMenu(context, homeMenu),
        badgeCount: badgeCount);
  }

  Widget _getSiteMenuContent(CompanySiteModel siteMenu) {
    String iconPath = 'icon_blog.png';
    if (sites.indexOf(siteMenu) == 0) iconPath = 'icon_sale.png';

    HomeMenuModel saleMenu =
        homeMenus.firstWhere((element) => element.menuKey == 'connect_sale');
    return _getMenuItemContent(
      siteMenu.title,
      iconPath,
      () => onTapHomeMenu(context, saleMenu, siteUrl: siteMenu.url),
    );
  }

  Widget _getMenuItemContent(String title, String iconPath, tapFunc,
      {badgeCount = 0}) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffd9d9d9)))),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ListTile(
          onTap: tapFunc,
          leading: _getMenuIconContainer(iconPath),
          trailing: _getMenuArrowContainer(),
          contentPadding: EdgeInsets.only(left: 2, right: 0),
          title: Stack(children: [
            Positioned(child: _getMenuTitleContainer(title)),
            if (badgeCount > 0)
              Positioned(right: 40, child: _getBadgeContainer(badgeCount))
          ])),
    );
  }

  Widget _getMenuIconContainer(String iconPath) {
    return Container(
        width: 30, child: Image.asset('images/icon/' + iconPath, height: 60));
  }

  Widget _getMenuArrowContainer() {
    return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
            color: Color(0xfff16982), borderRadius: BorderRadius.circular(26)),
        child: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 18));
  }

  Widget _getMenuTitleContainer(String title) {
    return Container(
      alignment: Alignment.center,
      child: Text(title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(82, 82, 82, 1))),
    );
  }

  Widget _getBadgeContainer(int Cnt) {
    return Container(
      alignment: Alignment.center,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.red),
      child: Text(Cnt.toString(),
          style: TextStyle(fontSize: 14, color: Colors.white)),
    );
  }
}
