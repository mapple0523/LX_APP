import 'dart:async';
import 'dart:typed_data';

import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/services.dart';
import 'package:cp949/cp949.dart' as cp949;

class OUT0011M extends StatefulWidget {
  @override
  _OUT0011M createState() => _OUT0011M();
}

class _OUT0011M extends State<OUT0011M> {
  static const _btChannel = MethodChannel('com.dootait.dtwms_app/bluetooth');

  final TextEditingController _lotValue    = TextEditingController();
  final TextEditingController _selPrintQty = TextEditingController();
  final TextEditingController _selPrintUpMargin = TextEditingController();
  final TextEditingController _selPrintDownMargin = TextEditingController();

  final FocusNode fnOne   = FocusNode();
  final FocusNode fnTwo   = FocusNode();
  final FocusNode fnThree = FocusNode();

  // ZPL 생성
  String buildZplCode({String lotNo, int printCount, int printUpMargin, int printDownMargin}) {
    return '''
^XA
^PR2
^LH$printUpMargin,$printDownMargin
^FO30,20^A0N,55,75^FD$lotNo^FS
^FO80,90^BQR,2,11^FDLA,$lotNo^FS
^PQ$printCount
^XZ
''' ;
  }


  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");

    FocusScope.of(context).unfocus();

    _lotValue.text = scannedValue;
    setState(() {
    });

    print("CM 타입 스캔 처리 완료");
  }

  // 기기 선택 다이얼로그
  Future<BluetoothDevice> _selectDevice(List<BluetoothDevice> devices) async {
    return await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("프린터 선택"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devices[index].name ?? "Unknown"),
                  subtitle: Text(devices[index].address),
                  onTap: () => Navigator.pop(context, devices[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  // 블루투스 출력
  Future<void> _printLabelByBluetooth() async {
    if (CommonUtil.isNull(_lotValue.text)) {
      showInfoAlert_pda(context, "LOT NO를 입력해주세요.");
      return;
    }

    // 권한 요청
    bool granted = false;
    try {
      granted = await _btChannel.invokeMethod('requestBluetoothPermission');
    } catch (e) {
      granted = false;
    }

    if (!granted) {
      showInfoAlert_pda(context, "블루투스 권한이 필요합니다.\n설정 > 앱 > 권한에서 허용해주세요.");
      return;
    }

    try {
      List<BluetoothDevice> devices =
      await FlutterBluetoothSerial.instance.getBondedDevices();

      if (devices.isEmpty) {
        showInfoAlert_pda(context, "페어링된 블루투스 기기가 없습니다.");
        return;
      }

      // 기기 선택 다이얼로그
      BluetoothDevice targetDevice;
      if (devices.length == 1) {
        targetDevice = devices[0];
      } else {
        targetDevice = await _selectDevice(devices);
      }

      if (targetDevice == null) {
        showInfoAlert_pda(context, "프린터를 선택해주세요.");
        return;
      }

      // 연결
      BluetoothConnection connection =
      await BluetoothConnection.toAddress(targetDevice.address);

      String lotNo   = _lotValue.text;
      int printCount = int.tryParse(_selPrintQty.text) ?? 1;
      int printUpMargin = int.tryParse(_selPrintUpMargin.text) ?? 1;
      int printDownMargin = int.tryParse(_selPrintDownMargin.text) ?? 1;

      // ZPL 전송
      final zpl   = buildZplCode(lotNo: lotNo, printCount: printCount, printUpMargin:printUpMargin ,printDownMargin:printDownMargin );
      final bytes = cp949.encode(zpl);
      connection.output.add(Uint8List.fromList(bytes));
      await connection.output.allSent;

      await Future.delayed(Duration(seconds: 2));
      await connection.close();

      showInfoAlert_pda(context, "라벨이 정상적으로 출력되었습니다.");
    } catch (e) {
      showInfoAlert_pda(context, "프린터 연결 실패\n$e");
    }
  }

  @override
  void initState() {
    super.initState();
    _selPrintQty.text = '1';
    _selPrintUpMargin.text = '20';
    _selPrintDownMargin.text = '30';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: pageAppBar(context, "라벨출력"),
      body: FooterLayout(
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CommonActionBtn(
                  "라벨발행",
                  onPressed: () => _printLabelByBluetooth(),
                ),
              ],
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => CommonUtil.hideKeyboard(),
          child: SingleChildScrollView(
            child: Column(
              children: [_searchField()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    final screenWidth = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(children: <Widget>[
          CommonText("lotNo" , height: screenWidth * 0.1),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 2.6),
            child: CommonScanTextField(
              _lotValue,
              focusNode: fnTwo,
              height: screenWidth * 0.1,
              scanType: "CM",
              onEditingComplete: (scannedValue) async {
                await _handleCMScan(scannedValue);
              },
            ),
          )
        ]),
        Row(children: <Widget>[
          CommonText("매수", height: screenWidth * 0.1),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 2.6),
            child: CommonTextField(_selPrintQty, height: screenWidth * 0.1, keyboardType: TextInputType.number),
          ),
        ]),
        Row(children: <Widget>[
          CommonText("프린터 좌우 이동", height: screenWidth * 0.1),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 2.6),
            child: CommonTextField(_selPrintUpMargin, height: screenWidth * 0.1, keyboardType: TextInputType.number),
          ),
        ]),
        Row(children: <Widget>[
          CommonText("프린터 상하 이동", height: screenWidth * 0.1),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 2.6),
            child: CommonTextField(_selPrintDownMargin, height: screenWidth * 0.1, keyboardType: TextInputType.number),
          ),
        ]),
      ],
    );
  }
}