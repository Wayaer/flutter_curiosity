import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_curiosity/flutter_curiosity.dart';
import 'package:flutter_waya/flutter_waya.dart';

class NetworkPage extends StatefulWidget {
  @override
  _NetworkPageState createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  StreamSubscription<NetworkResult> subscription;
  String networkType;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback((Duration duration) async {
      final Network network = Network();
      final NetworkResult type = await network.checkNetwork;
      networkType = type.toString();
      log(networkType);
      setState(() {});
      subscription = network.onChanged.listen((NetworkResult result) {
        networkType = result.toString();
        log(networkType);
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayScaffold(
        appBar: AppBar(title: const Text('Network')),
        body: Universal(children: <Widget>[
          const SizedBox(height: 80),
          const Text('网络状态'),
          const SizedBox(height: 20),
          Text(networkType ?? 'none'),
        ]));
  }
}
