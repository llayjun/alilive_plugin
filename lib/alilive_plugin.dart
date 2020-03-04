import 'dart:async';

import 'package:flutter/services.dart';


class AlilivePlugin {
  static const MethodChannel _channel =
  const MethodChannel('com.czh.tvmerchantapp/plugin');


  static Future<dynamic> jumptoBoast(String liveUrl) async {
    return await _channel.invokeMethod('jumpToBoast', liveUrl);
  }

  static Future<dynamic> jumpToLivePlay(String liveUrl) async {
    return await _channel.invokeMethod('jumpToLivePlay', liveUrl);
  }

}