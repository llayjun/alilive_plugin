import 'package:flutter/material.dart';
import 'package:alilive_plugin/alilive_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String pushUrl = 'rtmp://push.tv.9daye.cn/broadcast/0001?auth_key=1582883906-0-0-a52043fcdcdf8e26c0f768df95fc8b2b';
  String playUrl = 'http://pull.tv.9daye.cn/broadcast/0001.flv?auth_key=1582883906-0-0-2bb5dd9d44061fa825e48734bca298fc';

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
               Text('Running on: $_platformVersion\n'),
               RaisedButton(onPressed: jumpToReactive, child: Text("gotoTestLive")),
               Divider(height: 100,),
               RaisedButton(onPressed: jumpToBoast, child: Text("gotoTestBoast")),
            ],
          ),
        ),
      ),
    );
  }
  
  void jumpToReactive() {
    AlilivePlugin.jumpToLivePlay(pushUrl);
  }

  void jumpToBoast() {
    AlilivePlugin.jumptoBoast(playUrl);
  }

}
