import 'dart:async';
import 'package:shangrila/src/common/bussiness/company.dart';
import 'package:shangrila/src/common/bussiness/user.dart';
import 'package:shangrila/src/common/const.dart';
import 'package:shangrila/src/interface/connect/connect_login.dart';
import 'package:shangrila/src/interface/connect/password_reset.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shangrila/src/interface/connect/connect_register.dart';
import 'package:shangrila/src/model/companymodel.dart';
import 'package:shangrila/src/model/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:square_in_app_payments/in_app_payments.dart';

import 'src/interface/connect/connect_home.dart';
import 'src/interface/connect/license.dart';
import 'src/common/globals.dart' as globals;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
      .then((_) => runApp(new MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        child: MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ja'),
        const Locale('en'),
      ],
      locale: const Locale('ja'),
      debugShowCheckedModeBanner: false,
      title: 'Form Samples',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: AppInit(), //ConnectRegister(), //AdminHome(), //AppInit(),
      routes: <String, WidgetBuilder>{
        '/Home': (BuildContext context) => new ConnectHome(),
        '/Login': (BuildContext context) => new ConnectLogin(),
        '/License': (BuildContext context) => new LicenseView(),
        '/Register': (BuildContext context) => new ConnectRegister(),
        '/Reset': (BuildContext context) => new PasswordReset(),
      },
    ));
  }
}

class AppInit extends StatefulWidget {
  const AppInit({Key? key}) : super(key: key);

  @override
  _AppInit createState() => _AppInit();
}

class _AppInit extends State<AppInit> {
  late Future<List> loadData;

  @override
  void initState() {
    super.initState();
    _initSquarePayment();
    loadData = loadAppData();
  }

  Future<void> _initSquarePayment() async {
    CompanyModel company =
        await ClCompany().loadCompanyInfo(context, APPCOMANYID);
    globals.squareToken = company.squareToken;
    await InAppPayments.setSquareApplicationId(company.squareApplicationId);
  }

  Future<List> loadAppData() async {
    String? deviceToken;
    deviceToken = await FirebaseMessaging.instance
        .getToken()
        .then((token) => deviceToken = token);
    if (deviceToken == null) deviceToken = 'LocalDevice';
    globals.connectDeviceToken = deviceToken!; // == null ? '' : deviceToken!;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String saveUserId = prefs.getString('is_rirakukan_login_id') ?? '';

    if (saveUserId != '') {
      UserModel user = await ClUser().getUserFromId(context, saveUserId);
      if (user.userId != '') {
        globals.userId = user.userId.toString();
        globals.userName =
            user.userFirstName + ' ' + user.userLastName.toString();
      }
    }

    bool? isAgreeLicense = prefs.getBool('is_rirakukan_agree_license') ?? false;
    if (isAgreeLicense) {
      Navigator.pushNamed(context, '/Home');
    } else {
      Navigator.pushNamed(context, '/License');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<List>(
          future: loadData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container();
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
