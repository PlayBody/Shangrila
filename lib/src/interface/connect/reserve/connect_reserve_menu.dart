import 'package:shangrila/src/common/bussiness/menus.dart';
import 'package:shangrila/src/common/const.dart';
import 'package:shangrila/src/common/functions.dart';
import 'package:shangrila/src/interface/component/button/default_buttons.dart';
import 'package:shangrila/src/interface/component/form/main_form.dart';
import 'package:shangrila/src/interface/component/text/header_text.dart';
import 'package:flutter/material.dart';
import 'package:shangrila/src/interface/connect/reserve/reserve_staff.dart';

import '../../../common/dialogs.dart';
import '../../../model/menumodel.dart';
import '../../../common/globals.dart' as globals;

import 'connect_menu_view.dart';

class ConnectReserveMenus extends StatefulWidget {
  final String organId;
  const ConnectReserveMenus({required this.organId, Key? key})
      : super(key: key);

  @override
  _ConnectReserveMenus createState() => _ConnectReserveMenus();
}

class _ConnectReserveMenus extends State<ConnectReserveMenus> {
  late Future<List> loadData;
  List<MenuModel> menus = [];
  int _menuNumber = globals.menuSelectNumber;

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  Future<List> loadInitData() async {
    menus = await ClMenu().loadMenuList(context, {
      'company_id': APPCOMANYID,
      'organ_id': widget.organId,
      'is_user_menu': '1'
    });

    // globals.connectReserveMenuList = [];

    setState(() {});
    return [];
  }

  Future<void> updateReserveMenu(MenuModel selMenu) async {
    for (var item in globals.connectReserveMenuList) {
      if (item.menuId == selMenu.menuId) {
        Dialogs().infoDialog(context, '既に予約されました。');
        return;
      }
    }
    // await Dialogs().waitDialog(context, 'メニューに追加しました。');
    setState(() {
      selMenu.multiNumber = _menuNumber.toString();
      globals.connectReserveMenuList.add(selMenu);
    });
  }

  Future<void> removeMenuFromReserve(e) async {
    bool conf = true; // await Dialogs().confirmDialog(context, '削除しますか？');
    if (conf) {
      setState(() {
        globals.connectReserveMenuList.remove(e);
      });
    }
  }

  void pushMenuDetailView(String menuId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ConnectMenuView(menuId: menuId);
    }));
  }

  @override
  Widget build(BuildContext context) {
    globals.connectHeaerTitle = 'メニュー' + globals.menuSelectNumber.toString();
    return MainForm(
      title: 'メニュー(' + globals.menuSelectNumber.toString() + ')',
      bgColor: Color(0xfff4f4ea),
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Column(children: <Widget>[
                _getMenusContent(),
                Header3Text(label: '注文内容一覧'),
                SizedBox(height: 8),
                _getContentBottom(),
              ]),
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
    );
  }

  Widget _getMenusContent() {
    return Expanded(
      flex: 3,
      child: SingleChildScrollView(
        child: Column(children: [...menus.map((menu) => _getMenu(menu))]),
      ),
    );
  }

  Widget _getMenu(MenuModel menu) {
    return GestureDetector(
      onTap: () => updateReserveMenu(menu),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xffb8b8b8)))),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Color(0xffec5a01)),
            ),
            SizedBox(width: 16),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.menuTitle.length > 23
                      ? (menu.menuTitle.substring(0, 21) + '...')
                      : menu.menuTitle,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff525252)),
                ),
              ],
            )),
            Container(
                padding: EdgeInsets.only(right: 16),
                alignment: Alignment.centerRight,
                width: 100,
                child: Text(Funcs().currencyFormat(menu.menuPrice) + '円',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff525252)))),
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    visualDensity: VisualDensity(vertical: -2),
                    elevation: 0,
                    primary: Color(0xffffe6d7),
                    onPrimary: Color(0xffec5a01)),
                child: Text(
                  '詳 細',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => pushMenuDetailView(menu.menuId),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getContentBottom() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _getReservesContent(),
            SizedBox(height: 12),
            _getButtons()
          ],
        ),
      ),
    );
  }

  Widget _getReservesContent() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...globals.connectReserveMenuList
                .map((e) => _getReserveContentRow(e)),
          ],
        ),
      ),
    );
  }

  Widget _getReserveContentRow(e) {
    return Container(
        color: (globals.connectReserveMenuList.indexOf(e) % 2 != 0)
            ? Colors.white
            : Color(0xffeff9e6),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Container(
            alignment: Alignment.center,
            width: 12,
            child: Text(
              e.multiNumber,
              style: TextStyle(color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: Colors.red,
            ),
          ),
          SizedBox(width: 4),
          Expanded(child: Text(e.menuTitle)),
          Container(
            width: 80,
            child: e.multiNumber == _menuNumber.toString()
                ? Flat1Button(
                    tapFunc: () => removeMenuFromReserve(e), label: '削  除')
                : null,
          )
        ]));
  }

  Widget _getButtons() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(child: Container()),
          Container(
            width: 250,
            child: PrimaryButton(label: '次へ', tapFunc: () => pushReserve()),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  void pushReserve() {
    if (globals.connectReserveMenuList
            .where((element) => element.multiNumber == _menuNumber.toString())
            .length <
        1) {
      Dialogs().infoDialog(context, '予約メニューを選択してください。');
      return;
    }
    if (_menuNumber > globals.reserveMultiUsers.length) {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ReserveStaff(organId: widget.organId);
      }));
    } else {
      globals.menuSelectNumber = _menuNumber + 1;
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectReserveMenus(organId: widget.organId);
      }));
    }
  }
}
