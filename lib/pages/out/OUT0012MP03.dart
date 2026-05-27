import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonCar.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonMaterial.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/popup.dart';
import 'package:dtwms_app/pages/out/OUT0005MP05.dart';
import 'package:dtwms_app/pages/out/OUT0005MP06.dart';
import 'package:dtwms_app/pages/out/OUT0005MP07.dart';
import 'package:dtwms_app/pages/out/OUT0012MP02.dart';
import 'package:dtwms_app/pages/out/OUT0012MP04.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0012MP03 extends StatefulWidget {
  const OUT0012MP03({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0012MP03 createState() => _OUT0012MP03();
}

class _OUT0012MP03 extends State<OUT0012MP03> {
  final TextEditingController _selOutNoVal = TextEditingController();
  final TextEditingController _selPickVal = TextEditingController();
  final TextEditingController _carNo = TextEditingController();
  final TextEditingController _carCd = TextEditingController();
  final TextEditingController _driverNm = TextEditingController();
  final TextEditingController _driverCall = TextEditingController();
  final TextEditingController _materialVal = TextEditingController();
  final TextEditingController _containerNo = TextEditingController();
  final TextEditingController _carryingQty = TextEditingController();
  final TextEditingController _selPickDtFrom = TextEditingController();
  final TextEditingController _selInDtTo = TextEditingController();

  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  DateTime _schPickDt = DateTime.now();

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  String _fileId = "";
  int _selectedIndex = -1;
  String _packId;
  String _dispatchNo;
  String _cntrCd;

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    Map<String, dynamic> param = {};
    _searchList = [];

    param = {
      "OUT_NO": widget.param["OUT_NO"],
      "DISPATCH_NO" : widget.param["DISPATCH_NO"]
    };

    List<dynamic> rtnList = await transaction(context, "out/OUT0005/searchOutPickItemList.do", param);

    for(int i=0; i < rtnList.length; i++){
      dynamic item = rtnList[i];

      double instQty = double.tryParse(item['PICK_INST_QTY']?.toString() ?? '0') ?? 0;
      double carQty  = double.tryParse(item['CAR_INPUT_QTY']?.toString()  ?? '0') ?? 0;

      if (carQty > instQty) {
        item['ROW_COLOR'] = Colors.red[100];  // 수량 초과 → 연빨간색
      } else if (carQty > 0 && carQty == instQty) {
        item['ROW_COLOR'] = Colors.yellow;    // 수량 동일 → 노란색
      }

      _searchList.add(item);
    }

    print('$_searchList');

    _carryingQty.text = _searchList.isNotEmpty ? (_searchList[0]['TOTAL_CAR_INPUT_QTY'] ?? 0).toString() : '0';

    if (_searchList.isNotEmpty && _selectedIndex >= 0 && _selectedIndex < _searchList.length) {
      _searchList[_selectedIndex]['ROW_COLOR'] = Colors.orange;
    }

    setState(() {});
  }

  Future<void> callInNavi(BuildContext context, [dynamic param]) async {
    param["DISPATCH_NO"] = widget.param["DISPATCH_NO"];
    param["driverNm"] = _driverNm.text;
    param["driverCall"] = _driverCall.text;

    print(param);

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0012MP04(param: param)));

    _search();

    setState(() {});
  }

  Future<void>  _finish() async {

    dynamic paramRow = ConvertUtil.removeColumnOne(_searchList[0], ["ROW_COLOR"]);
    paramRow["DISPATCH_NO"] = widget.param["DISPATCH_NO"];

    await transaction(context, "out/OUT0005/finishDispatchPlan.do", paramRow, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "상차완료 되었습니다.");
        _search();
      }
    });
  }

  Future<void> _updateDispatch() async {
    Map<String, dynamic> newItem = <String, dynamic>{};

    // 차량정보 추가
    newItem["DISPATCH_NO"] = widget.param["DISPATCH_NO"];
    newItem["OUT_NO"] = _selOutNoVal.text;
    newItem["VEHICLE_NO"] = _carNo.text;
    newItem["VEHICLE_CD"] = _carCd.text;
    newItem["OUT_DRIVER_NM"] = _driverNm.text;
    newItem["OUT_DRIVER_TEL"] = _driverCall.text;

    await transaction(context, "out/OUT0005/updateDispatchList.do", newItem, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "차량정보가 저장되었습니다.");

        widget.param["VEHICLE_NO"] = _carNo.text;
        widget.param["VEHICLE_CD"] = _carCd.text;
        widget.param["OUT_DRIVER_NM"] = _driverNm.text;
        widget.param["OUT_DRIVER_TEL"] = _driverCall.text;
      }
    });
  }

  Future<dynamic> callPallet(BuildContext context, [dynamic param]) async {

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005MP06(param: widget.param)));

    return result;
  }

  bool _checkCarInfoChanged(){
    if(widget.param["VEHICLE_NO"] != _carNo.text
        || widget.param["VEHICLE_CD"] != _carCd.text
        || widget.param["OUT_DRIVER_NM"] != _driverNm.text
        || widget.param["OUT_DRIVER_TEL"] != _driverCall.text){
      return true;
    }else{
      return false;
    }
  }

  Future<void> _updatePickingCar(dynamic param) async {
    print(param);

    // 차량정보 추가
    List<dynamic> resultList = [];

    Map<String, dynamic> newItem = {
      "PLANT"         : param["PLANT"],
      "SLOC"          : param["SLOC"],
      "LOT_NO"        : param["LOT_NO"],
      "DISPATCH_NO"   : widget.param["DISPATCH_NO"],
      "SHPR_ITEM_CD"  : param["SHPR_ITEM_CD"],
      "LOCATION_CD"   : param["LOCATION_CD"],
      "STOCK_SEQ"     : param["STOCK_SEQ"],
    };

    print("newItem: $newItem");

    resultList.add(newItem);

    print("result $resultList");

    await transaction(context, "out/OUT0005/saveDirectItemDispatch.do", resultList, (status, responseData) {
      if (status == Constant.resSuccessCode) {
        showInfoAlert_pda(context, "차량정보가 저장되었습니다.");
        _search();
      }
    });
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    scannedValue = CommonUtil.parseLotNo(scannedValue);
    //_materialVal.text = scannedValue;
    _packId = scannedValue;

    widget.param['PACK_ID'] = scannedValue;
    widget.param['SHPR_ITEM_CD'] = _searchList[0]['SHPR_ITEM_CD'];

    List<dynamic> woNoList = await transaction(context, "/out/OUT0005/searchStockList.do", widget.param);

    if (woNoList.isEmpty) {
      showInfoAlert_pda(context, "재고를 확인해주십시오.");
      return;
    }

    dynamic selectedItem;

    if (woNoList.length > 1) {
      final result = await showSmallPopup(
        context, woNoList, ["SHPR_ITEM_CD", "LOCATION_CD", "STATUS", "STOCK_QTY"],
      );
      if (result == null) return;
      selectedItem = result;
    } else {
      selectedItem = woNoList[0];
    }

    for (var item in _searchList) {
      item['ROW_COLOR'] = Colors.white;
    }

    // 매칭되는 row 찾아서 색상 변경
    int matchIndex = _searchList.indexWhere((item) =>
    item['SHPR_ITEM_CD'] == selectedItem['SHPR_ITEM_CD'] && item['LOT_NO'] == selectedItem['LOT_NO']);

    if (matchIndex != -1) {
      setState(() {
        _searchList[matchIndex]['ROW_COLOR'] = Colors.orange;
        _selectedIndex = matchIndex;
      });
    } else {
      //showInfoAlert_pda(context, "해당 항목을 찾을 수 없습니다.");
    }

    _updatePickingCar(selectedItem);

    print("CM 타입 스캔 처리 완료");
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {

    Map<String, dynamic> newParam = {
      "OUT_NO": widget.param["OUT_NO"],
      "VEHICLE_NO": _carNo.text,
      "OUR_DRIVER_NM": _driverNm.text,
      "OUR_DRIVER_TEL": _driverCall.text,
      "CNTR_CD": widget.param["CNTR_CD"],
      "CNTR_NO": _containerNo.text,
      "SEAL_NO": widget.param["SEAL_NO"],
      "DISPATCH_NO": widget.param["DISPATCH_NO"],
      "COMPANY_CD": widget.param["COMPANY_CD"],
      "BIZ_CD": widget.param["BIZ_CD"],
    };

    print("callNavi 호출됨 - scanType: $newParam");
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005MP05(param: newParam)));

    _search();
  }

  @override
  void initState() {
    super.initState();

    print("************************* \nOUT0012MP03 paramater ${widget.param}");

    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
    _selInDtTo.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    if (!CommonUtil.isEmpty(widget.param)) {
      _dispatchNo = widget.param["DISPATCH_NO"];
      _cntrCd = widget.param["CNTR_CD"];

      if (!CommonUtil.isEmpty(widget.param["VEHICLE_NO"])) {
        _carNo.text = widget.param["VEHICLE_NO"];
      }

      if (!CommonUtil.isEmpty(widget.param["VEHICLE_CD"])) {
        if(widget.param["INCO1"] == "Z01")
          _carCd.text = "X0001";
        else
          _carCd.text = widget.param["VEHICLE_CD"];
      }

      if (!CommonUtil.isEmpty(widget.param["OUT_DRIVER_NM"])) {
        _driverNm.text = widget.param["OUT_DRIVER_NM"];
      }

      if (!CommonUtil.isEmpty(widget.param["OUT_DRIVER_TEL"])) {
        _driverCall.text = widget.param["OUT_DRIVER_TEL"];
      }

      if (!CommonUtil.isEmpty(widget.param["OUT_NO"])) {
        _selOutNoVal.text = widget.param["OUT_NO"];
      }

      if (!CommonUtil.isEmpty(widget.param["CNTR_NO"])) {
        _containerNo.text = widget.param["CNTR_NO"];
      }

      if (!CommonUtil.isEmpty(widget.param["REF_FILE_ID"])) {
        _fileId = widget.param["REF_FILE_ID"];
      }

    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!CommonUtil.isEmpty(widget.param))
        await _search();
    });
  }

  Future<void> _inspectionCheck() async {
    dynamic argParam = {
      "COMPANY_CD" :  widget.param["COMPANY_CD"],
      "BIZ_CD" :  widget.param["BIZ_CD"],
      "OUT_NO" :  widget.param["OUT_NO"],
      "DISPATCH_NO" :  widget.param["DISPATCH_NO"],
      "REF_FILE_ID" :  _fileId,
      "CNTR_CD" :  widget.param["CNTR_CD"],
      "INSPECTION_TYPE" : "D"
    };

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005MP07(param: argParam)));

    _fileId = result["FILE_ID"];
  }


  @override
  void dispose() {
    fnOne.dispose();
    fnTwo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: pageAppBar(context, "상차출고(수출)", false),
        body: FooterLayout(
          footer: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    CommonText("carryingQty"),
                    CommonTextField(
                      _carryingQty,
                      width: MediaQuery.of(context).size.width * 0.72 - 100,
                      enabled: false,
                      onEditingComplete: ([result]) {
                      },
                    ),
                    CommonActionBtn(
                      "plt",
                      width: 80,
                      height: MediaQuery.of(context).size.height * 0.06,
                      onPressed: () => callPallet(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: Container(
                //height : CommonUtil.pageMaxHeight(context,(55 * (_searchList.length - 7)).toDouble()),
                child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      CommonUtil.hideKeyboard();
                    },
                    child: Column(children: <Widget>[
                      _searchField(),
                      Row(
                        children: [
                          CommonActionBtn(
                            "inspectionCheck",
                            width: screenWidth * 0.5 - 10,
                            onPressed: (){
                              _inspectionCheck();
                            },
                          ),
                          CommonActionBtn(
                            "상차완료",
                            width: screenWidth * 0.5 - 10,
                            onPressed: _finish,
                          ),
                        ],
                      ),
                      Expanded(
                        child: CustomGrid([['GRADE','lotNo'],'지시량','상차량'],
                          [['ZZGRADE','LOT_NO'], "PICK_INST_QTY", 'CAR_INPUT_QTY'],
                          _searchList,
                          focusIndex: _selectedIndex,
                          onTap: (rowData) {

                            setState(() {
                              callInNavi(context, rowData).then((data) {});
                            });
                          },
                        ),
                      ),
                    ]))),
        ));
  }

  Widget _searchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("carNo"),
              CommonCar(
                selCarVal: _carNo,
                focusNode: fnTwo,
                param: {
                  'VEHICLE_NO' : _carNo.text,
                  'LIFNR_SP' : widget.param['LIFNR_SP']
                },
                onEditingComplete: (result) {
                  fnOne.requestFocus();

                  if (!mounted) return;

                  if (result is String) {

                    if(widget.param["INCO1"] == "Z01")
                      _carCd.text = "X0001";
                    else
                      _carCd.text = "";

                    _carNo.text = result;
                  } else if (result is Map) {
                    _driverNm.text = result["DRIVER_NM"];
                    _driverCall.text = result["TEL"];

                    if(widget.param["INCO1"] == "Z01")
                      _carCd.text = "X0001";
                    else
                      _carCd.text = result["VEHICLE_CD"];
                  }
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("container"),
              CommonTextField(
                _containerNo,
                enabled: false,
                width: MediaQuery.of(context).size.width * 0.7 - 45,
              ),
              IconButton(padding:EdgeInsets.only(left: 5), constraints: BoxConstraints(), icon: Icon(Icons.search)
                  , onPressed: () {
                    callNavi(context);
                  }
              )
            ],
          ),
          // Row(
          //   children: <Widget>[
          //     CommonText("carCd"),
          //     CommonTextField(
          //       _carCd,
          //       width: MediaQuery.of(context).size.width * 0.72 - 100,
          //       enabled: false,
          //     ),
          //     CommonActionBtn(
          //       "btnSave",
          //       width: 80,
          //       height: MediaQuery.of(context).size.height * 0.06,
          //       onPressed: _updateDispatch,
          //     ),
          //   ],
          // ),
          // Row(
          //   children: <Widget>[
          //     CommonText("driverNm"),
          //     CommonTextField(
          //       _driverNm,
          //     )
          //   ],
          // ),
          // Row(
          //   children: <Widget>[
          //     CommonText("phoneNo"),
          //     CommonTextField(
          //       _driverCall,
          //     )
          //   ],
          // ),
          Row(
            children: <Widget>[
              Offstage(
                offstage: true, // false로 바꾸면 다시 보임
                child: CommonScanTextField(
                  _materialVal,
                  focusNode: fnOne,
                  autofocus: true,
                  scanType: "CM",
                  onEditingComplete: (scannedValue) async {
                    await _handleCMScan(scannedValue);
                  },
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("납품문서 번호"),
              CommonTextField(
                TextEditingController(text: widget.param.isNotEmpty
                    ? (widget.param['REAL_IF_OUT_NO'] ?? '').toString()
                    : ''),
                enabled: false,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("배차중량", width: MediaQuery.of(context).size.width * 0.19),
              CommonTextField(
                  TextEditingController(text: _searchList.isNotEmpty
                      ? (_searchList[0]['CAR_QTY'] ?? '0').toString()
                      : '0'),
                  enabled: false,
                  width: MediaQuery.of(context).size.width * 0.31-12.5
              ),
              CommonText("총상차량", width: MediaQuery.of(context).size.width * 0.19),
              CommonTextField(
                  TextEditingController(text: _searchList.isNotEmpty
                      ? (_searchList[0]['TOTAL_CAR_INPUT_QTY_SUM'] ?? '0').toString()
                      : '0'),
                  enabled: false,
                  width: MediaQuery.of(context).size.width * 0.31-12.5
              )
            ],
          ),
        ],
      ),
    );
  }
}