// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:shangrila/src/common/const.dart';

import '../../../common/globals.dart' as global;

class MyConnetAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      elevation: 4,
      titleSpacing: 0,
      title: Container(
        height: 70,
        child: Container(
          margin: EdgeInsets.only(left: 20),
          padding: EdgeInsets.only(top: 12),
          child: Image.asset('images/logo.png'),
        ),

        // Row(
        //   children: [
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     Container(
        //         padding: EdgeInsets.only(bottom: 10, left: 16),
        //         // margin: EdgeInsets.symmetric(vertical: 16),
        //         child: Text(
        //           global.connectHeaerTitle,
        //           style: TextStyle(
        //               color: primaryColor,
        //               fontWeight: FontWeight.bold,
        //               fontSize: 20,
        //               letterSpacing: 1.5),
        //         )),
        //     Container(
        //       width: 150,
        //       height: 4,
        //       decoration: BoxDecoration(
        //           color: Color(0xffd4dc57),
        //           borderRadius: BorderRadius.only(
        //             topRight: Radius.circular(8),
        //             bottomRight: Radius.circular(8),
        //           )),
        //     )
        //   ],
        // ),
        //     Expanded(child: Container()),
        //   ],
        // ),
      ),
      actions: [
        Container(
          padding: EdgeInsets.only(top: 10),
          width: 70,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                  width: 16,
                  image: AssetImage('images/icon/person.png'),
                  color: Color(0xff5a5a5a)),
              // Icon(Icons.person_rounded, size: 32, color: Color(0xff5a5a5a)),
              SizedBox(height: 8),
              Text(
                global.userName,
                style: TextStyle(fontSize: 10, color: Color(0xff5a5a5a)),
              )
            ],
          ),
        ),
        ElevatedButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
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
            ))
      ],
    );
  }
}
