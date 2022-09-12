import 'dart:convert';

import 'package:shangrila/src/common/globals.dart' as globals;
import 'package:shangrila/src/http/webservice.dart';
import 'package:shangrila/src/model/order_model.dart';
import 'package:shangrila/src/model/reservemodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../apiendpoint.dart';
import '../const.dart';

class ClReserve {
  Future<List<TimeRegion>> loadReserveConditions(context, String organId,
      String? staffId, String fromDate, String toDate, String timeDiff) async {
    String apiUrl = apiBase + '/apireserves/loadReserveConditions';

    int sumTime = 0;
    globals.connectReserveMenuList.forEach((element) {
      sumTime = sumTime + int.parse(element.menuTime);
    });

    int interval = 0;
    globals.connectReserveMenuList.forEach((element) {
      if (int.parse(element.menuInterval) > interval)
        interval = int.parse(element.menuInterval);
    });

    sumTime = sumTime + interval;
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'staff_id': staffId == null ? '' : staffId,
      'organ_id': organId,
      'from_date': fromDate,
      'to_date': DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.parse(toDate).add(Duration(minutes: sumTime))),
      'user_id': globals.userId,
    }).then((v) => {results = v});
    List<TimeRegion> regions = [];

    Map<String, dynamic> timeResults = {};
    for (var item in results['regions']) {
      String newTime = DateFormat('yyyy-MM-dd HH:00:00')
          .format(DateTime.parse(item['time']));

      if (int.parse(timeDiff) < 60)
        newTime = DateFormat('yyyy-MM-dd HH:mm:00')
            .format(DateTime.parse(item['time']));

      if (timeResults[newTime] == null) {
        timeResults[newTime] = {};
        timeResults[newTime]['type'] = item['type'].toString();
        timeResults[newTime]['time'] = newTime;
      } else {
        if (int.parse(timeResults[newTime]['type']) >
            int.parse(item['type'].toString())) {
          timeResults[newTime]['type'] = item['type'].toString();
        }
      }
    }
    Map<String, dynamic> finalResults = {};
    timeResults.forEach((key, item) {
      if (!DateTime.parse(key).isAfter(DateTime.parse(toDate))) {
        if (item['type'] == '1' || item['type'] == '2') {
          String _type = item['type'].toString();

          for (int i = int.parse(timeDiff);
              i < sumTime + int.parse(timeDiff);
              i += int.parse(timeDiff)) {
            String _key = DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.parse(key).add(Duration(minutes: i)));

            if (timeResults[_key]['type'] == '0' ||
                timeResults[_key]['type'] == '3') {
              _type = timeResults[_key]['type'];
            }
          }
          finalResults[key] = item;
          finalResults[key]['type'] = _type;
        } else {
          finalResults[key] = item;
        }
      }
    });

    finalResults.forEach((key, item) {
      var _cellBGColor = Color(0xfffdfdf6);
      var _cellText = '';
      var _textColor = Colors.grey;
      if (item['type'] == '1') {
        _cellBGColor = Colors.white;
        _cellText = staffId == null ? '○' : '◎';
        _textColor = Colors.red;
      }
      if (item['type'] == '2') {
        _cellBGColor = Colors.white;
        _textColor = Colors.green;
        _cellText = '□';
      }
      if (item['type'] == '3') {
        _cellBGColor = Color(0xfffdfdf6);
        _cellText = 'x';
      }
      regions.add(TimeRegion(
          startTime: DateTime.parse(item['time']),
          endTime: DateTime.parse(item['time']).add(Duration(minutes: 60)),
          enablePointerInteraction: true,
          color: _cellBGColor,
          text: _cellText,
          textStyle: TextStyle(
              color: _textColor, fontSize: 18, fontWeight: FontWeight.bold)));
    });

    return regions;
  }

  Future<List<ReserveModel>> loadUserReserveList(
      context, userId, organId, fromDate, toDate) async {
    String apiURL = apiBase + '/apireserves/loadUserReserveList';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'user_id': globals.userId,
      'organ_id': organId,
      'from_date': fromDate,
      'to_date': toDate,
    }).then((value) => results = value);

    List<ReserveModel> reserves = [];
    if (results['isLoad']) {
      for (var item in results['reserves']) {
        reserves.add(ReserveModel.fromJson(item));
      }
    }

    return reserves;
  }

  Future<String?> loadLastReserveStaffId(context, String organId) async {
    String apiUrl = apiBase + '/apireserves/getLastReserve';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'user_id': globals.userId,
      'organ_id': organId,
    }).then((v) => {results = v});
    return results['staff_id'] == '' ? null : results['staff_id'].toString();
  }

  Future<bool> updateReserveStatus(context, String reserveId) async {
    String apiUrl = apiBase + '/apireserves/updateReserveStatus';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'reserve_id': reserveId,
    }).then((v) => {results = v});

    return results['isStampAdd'];
  }

  Future<bool> enteringOrgan(
      context, String organId, String reserveId, String menuIds) async {
    String apiUrl = apiBase + '/apireserves/enteringOrgan';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
      'order_id': reserveId,
      'menu_ids': menuIds,
      'user_id': globals.userId
    }).then((v) => {results = v});

    return results['isStampAdd'];
  }

  Future<ReserveModel?> getReserveNow(context, String organId) async {
    String apiUrl = apiBase + '/apireserves/getReserveNow';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'user_id': globals.userId,
      'organ_id': organId,
    }).then((v) => {results = v});

    if (results['isExistReserve']) {
      return ReserveModel.fromJson(results['reserve']);
    }

    return null;
  }

  Future<List<OrderModel>> loadReserveList(context) async {
    String apiURL = apiBase + '/apiorders/loadOrderList';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'user_id': globals.userId,
      'is_reserve_list': '1'
    }).then((value) => results = value);
    List<OrderModel> historys = [];
    if (results['isLoad']) {
      for (var item in results['orders']) {
        historys.add(OrderModel.fromJson(item));
      }
    }

    return historys;
  }

  Future<List<OrderModel>> loadReserves(context, param) async {
    String apiURL = apiBase + '/apiorders/loadOrderList';
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiURL, param)
        .then((value) => results = value);
    List<OrderModel> reserves = [];
    if (results['isLoad']) {
      for (var item in results['orders']) {
        reserves.add(OrderModel.fromJson(item));
      }
    }

    return reserves;
  }

  Future<OrderModel?> loadReserveInfo(context, String orderId) async {
    String apiURL = apiBase + '/apiorders/loadOrderInfo';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {'order_id': orderId}).then(
        (value) => results = value);
    OrderModel? reserve;

    if (results['isLoad']) {
      reserve = OrderModel.fromJson(results['order']);
    }

    return reserve;
  }

  Future<ReserveModel?> loadReserveMenus(context, reserveId) async {
    String apiURL = apiBase + '/apireserves/loadReserveInfo';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL,
        {'reserve_id': reserveId}).then((value) => results = value);
    ReserveModel? reserve;
    if (results['isLoad']) {
      reserve = ReserveModel.fromJson(results['reserve']);
    }

    return reserve;
  }

  Future<bool> updateReserveCancel(context, String reserveId) async {
    dynamic data = {'id': reserveId, 'status': ORDER_STATUS_RESERVE_CANCEL};
    String apiUrl = apiBase + '/apiorders/updateOrder';
    await Webservice()
        .loadHttp(context, apiUrl, {'update_data': jsonEncode(data)});
    return true;
  }

  Future<bool> updateReceiptUserName(
      context, String reserveId, String updateUserName) async {
    dynamic data = {'id': reserveId, 'user_input_name': updateUserName};
    String apiUrl = apiBase + '/apiorders/updateOrder';
    await Webservice()
        .loadHttp(context, apiUrl, {'update_data': jsonEncode(data)});
    return true;
  }
}
