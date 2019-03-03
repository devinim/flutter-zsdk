import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_zsdk/flutter_zsdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String FLUTTER_LOGO_ZPL = "^XA^CI28^PON^PW560^MNN^LL460^LH0,0^LT60" +
      "^GFA,6150,6150,25,,gP01XFCgP03XF8gP07XF,gP0XFE,gO01XFC,gO03XF8,gO07XF,gO0XFE,gN01XFC,gN03XF8,gN0YF,gN0XFE,gM01XFC,gM03XF8,gM0YF,gL01XFE"
      ",gL01XFC,gL07XF8,gL0YF,gK01XFE,gK03XFC,gK07XF8,gK0YF,gJ01XFE,gJ03XFC,gJ07XF8,gJ0YF,gI01XFE,gI03XFC,gI07XF8,gI0YF,gH01XFE,gH03XFC,gH07XF8"
      ",gH0YF,gG01XFE,gG03XFC,gG07XF8,gG0YF,g01XFE,g03XFC,g07XF8,g0YF,Y01XFE,Y03XFC,Y07XF8,Y0YF,X01XFE,X03XFC,X07XF8,X0YF,W01XFE,W03XFC,W07XF8"
      ",W0YF,V01XFE,V03XFC,V07XF8,V0YF,U01XFE,U03XFC,U07XF8,U0YF,T01XFE,T03XFC,T07XF8,T0YF,S01XFE,S03XFC,S07XF8,S0YF,R01XFE,R03XFC,R07XF8"
      ",R0YF,Q01XFE,Q03XFC,Q07XF8,Q0YF,P01XFE,P03XFC,P07XF8,P0YF,O01XFE,O03XFC,O07XF8,O0YF,N01XFE,N03XFC,N07XF8,N0YF,M01XFE,M03XFC,M07XF8"
      ",M0YF,L01XFE,L03XFC,L07XF8,L0YF,K01XFE,K03XFC,K07XF8,K0YF,J01XFE,J03XFC,J07XF8,J0YF,I01XFE,I03XFC,I07XF8,I0XFE,001XFE,003XFCN03XF"
      ",007XF8N07XF,00XFEO0XFE,01XFCN01XFC,03XFCN03XF8,07XF8N07XF,0XFEO0XFE,1XFCN01XFC,3XF8N03XF8,7XF8N07XF,3WFEO0XFE,1WFCN01XFC,0WF8N03XF8"
      ",07VFO07XF,03UFEO0XFE,01UFCN01XFC,00UF8N03XF8,007TFO07XF,003SFEO0XFE,001SFCN01XFC,I0SF8N03XF8,I07RFO07XF,I03QFEO0XFE,I01QFCN01XFC,J0QF8N03XF8"
      ",J07PFO07XF,J03OFEO0XFE,J01OFCN01XFC,K0OF8N03XF8,K07NFO07XF,K03MFEO0XFE,K01MFCN01XFC,L0MF8N03XF8,L07LFO07XF,L03KFEO0XFE,L01KFCN01XFC,M0KF8N03XF8"
      ",M07JFO07XF,M03IFEO0XFE,M01IFCN01XFC,N0IF8N03XF8,N07FFO07XF,N03FEO0XFE,N01FCN01XFC,O0F8N03XF8,O07O07XF,O02O0XFE,X01XFC,X03XF8,X07XF,X0XFE,W01XFC"
      ",W03XF8,W07XF,W0XFE,V01XFC,V03XF8,V07XF,V0XFE,U01XFC,U03XF8,U07XF,U0XFE,T01XFC,T07XF8,T07XF,T03XF8,T01XFC,U0XFE,U07XF,U03XF8,U01XFC,V0XFE,V07XF"
      ",V03XF8,V01XFC,W0XFE,W07XF,W07XF8,W03XFC,X0XFE,X07XF,X07XF8,X03XFC,X01XFE,Y07XF,Y07XF8,Y03XFC,Y01XFE,g0YF,g07XF8,g03XFC,g01XFE,gG0YF,gG07XF8,gG03XFC"
      ",gG01XFE,gH0YF,gH07XF8,gH03XFC,gH01XFE,gI0YF,gI07XF8,gI03XFC,gI01XFC,gJ0XFE,gJ07XF,gJ03XF8,gJ01XFC,gK0XFE,gK07XF,gK03XF8,gK01XFC,gL0XFE,gL07XF,gL03XF8"
      ",gL01XFC,gM0XFE,gM07XF,gM03XF8,gM01XFC,gN0XFE,gN07XF,gN03XF8,gN01XFC,gO0XFE,gO07XF,gO03XF8,gO01XFC,gP0XFE,gP07XF,gR01VF8"
      ",^FS ^XZ";

  List<ZebraBluetoothDevice> _devices = List();

  @override
  void initState() {
    super.initState();
    __init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> __init() async {
    List<ZebraBluetoothDevice> devices = List();

    try {
      devices = await FlutterZsdk.discoverBluetoothDevices();
      devices.forEach((d) {
        print('Device: ${d.friendlyName} [${d.mac}]');
      });
    } catch (e) {
      showDialog(context: context, child: Text(e));
      //throw e;
      print('Error' + e);
    }

    if (!mounted) return;

    setState(() {
      _devices = devices;
    });
  }

  String levelText = "Querying...";

  _level(ZebraBluetoothDevice d) {
    d.batteryLevel().then((t) {
      setState(() {
        levelText = t;
      });
    });
  }

  Widget _listPrinters() {
    List<Widget> items = List();

    if (_devices.length < 1) {
      items.add(ListTile(
        title: Text("Not found any or still searching"),
      ));
    } else {
      items.addAll([
        ListTile(
          title: Text("Found ${_devices.length} device(s)"),
        ),
        SizedBox(height: 50),
      ]);
      _devices.forEach((d) {
        _level(d);
        items.add(
          ListTile(
            title: Text(d.friendlyName),
            subtitle: Text(d.mac + "[%${levelText}]"),
            leading: IconButton(icon: Icon(Icons.list), onPressed: () => d.properties()),
            trailing: IconButton(
              icon: Icon(Icons.print),
              onPressed: () => d.sendZplOverBluetooth(FLUTTER_LOGO_ZPL),
            ),
          ),
        );
      });
    }

    return ListView(
      padding: EdgeInsets.all(24),
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zebra Plugin Example App'),
        ),
        body: _listPrinters(),
      ),
    );
  }
}
