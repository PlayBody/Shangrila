import 'package:shangrila/src/interface/connect/layout/connect_bottom.dart';
import 'package:shangrila/src/interface/connect/layout/connect_drawer.dart';
import 'package:shangrila/src/interface/connect/layout/header.dart';
import 'package:flutter/material.dart';

import '../../../common/globals.dart' as globals;

class MainForm extends StatelessWidget {
  final title;
  final bgColor;
  final Widget render;
  const MainForm(
      {required this.title, this.bgColor, required this.render, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    globals.connectHeaerTitle = title;
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage('images/home_body_back.jpg'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter),
        ),
        child: Scaffold(
          appBar: MyConnetAppBar(),
          body: render,
          backgroundColor:
              bgColor == null ? Colors.transparent : bgColor, //, //
          drawer: ConnectDrawer(),
          bottomNavigationBar: ConnectBottomBar(),
        ));
  }
}
