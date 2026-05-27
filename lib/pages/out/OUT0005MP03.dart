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
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0005MP03 extends StatefulWidget {
  const OUT0005MP03({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0005MP03 createState() => _OUT0005MP03();
}

class _OUT0005MP03 extends State<OUT0005MP03> {
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
  //final FocusNode fnThree = FocusNode();
  //final FocusNode fnFour = FocusNode();

  DateTime _schPickDt = DateTime.now();

  dynamic popUpYn = "N";

  List<dynamic> _searchList = [];
  String _fileId = "";
  int _selectedIndex = 0;
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

    List<dynamic> rtnList = await transaction(context, "out/OUT0005/searchOutItemDetailList.do", param);
    for(int i=0; i < rtnList.length; i++){
      _searchList.add(rtnList[i]);
      _searchList[i]["index"] = i;
      _searchList[i]["ROW_COLOR"] = _searchList[i]["CHECK_YN"]=="Y"? Colors.orange.shade100 : Colors.transparent;
    }

    _carryingQty.text = _searchList[0]['CHECK_RATIO'].toString();

    setState(() {
    });
  }

  Future<void> _insertPackId(dynamic pRowData) async {
    dynamic resultList = ConvertUtil.removeColumnOne(pRowData, ["ROW_COLOR"]);
    resultList["DISPATCH_NO"] = widget.param["DISPATCH_NO"];
    resultList["driverNm"] = _driverNm.text;
    resultList["driverCall"] = _driverCall.text;

    bool hasCheckY = resultList['CHECK_YN'] == 'Y'?true:false;

    if (hasCheckY) {
      bool result = await confirmDialog(context, "확인취소", "확인취소 하시겠습니까?");

      if (result == true) {
        await transaction(context, "out/OUT0005/updateOutItemDetailList.do", resultList, (status, responseData) {
          if (status == Constant.resSuccessCode) {
            showInfoAlert_pda(context, "alertBoxPackCancel");
            _search();
          }
        });
      }
    }
    else {
      await transaction(context, "out/OUT0005/updateOutItemDetailList.do", resultList, (status, responseData) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "alertBoxPack");
          _search();
        }
      });
    }

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

  // Future<void>  _addPackList() async {
  //
  //   Map<String, dynamic> selParam = <String, dynamic>{};
  //
  //   // 차량정보 추가
  //   selParam["PACK_ID"] = _packId;
  //   selParam["OUT_NO"] = _selOutNoVal.text;
  //
  //   List<dynamic> rtnList = await transaction(context, "out/OUT0005/selectOutItemPackId.do", selParam);
  //   if(rtnList.length == 0){
  //     // DETAIL이 조회되지 않으면
  //     showInfoAlert_pda(context, "할당된 재고가 아닙니다.");
  //     return;
  //   }
  //   else{
  //     // rtnList가 1건 이상일 경우
  //     if(rtnList.length > 1){
  //       final result = await showSmallPopup(context, rtnList, ["PACK_ID","ZZGRADE"]);
  //
  //       // 선택을 하지 않을 경우 종료
  //       if(result == null){
  //         return;
  //       }
  //
  //       rtnList.clear();
  //       rtnList.add(result);
  //     }
  //
  //     if(CommonUtil.isNull(rtnList[0]["CNTR_CD"])){
  //       // DETAIL이 조회되는데 CNTR_CD 가 없는경우, DISPATCH_NO, CHECK_YN = 'Y' 업데이트
  //       selParam["DISPATCH_NO"] = _dispatchNo;
  //       selParam["CNTR_CD"] = _cntrCd;
  //       await transaction(context, "out/OUT0005/updateOutItemPackId.do", selParam, (status, responseData) {
  //         if (status == Constant.resSuccessCode) {
  //           showInfoAlert_pda(context, "alertBoxPack");
  //           _search();
  //         }
  //       });
  //     }
  //     else if(rtnList[0]["CNTR_CD"] != _cntrCd){ // DISPATCH_NO가 현재 작업중인 내용과 동일하지 않은 경우
  //       if(rtnList[0]["CHECK_YN"] == "Y"){
  //         // 적재여부가 Y (상차) 이면
  //         showInfoAlert_pda(context, "다른 차량에 상차완료된 LOT 입니다.");
  //         return;
  //       }else{
  //         // 적재여부가 N (계획) 이면
  //         bool result = await confirmDialog(context, "확인", "다른 차량에 계획된 LOT 입니다. 상차하시겠습니까?");
  //         if(result){
  //           // DISPATCH_NO, CHECK_YN = 'Y' 업데이트
  //           selParam["DISPATCH_NO"] = _dispatchNo;
  //           selParam["CNTR_CD"] = _cntrCd;
  //           await transaction(context, "out/OUT0005/updateOutItemPackId.do", selParam, (status, responseData) {
  //             if (status == Constant.resSuccessCode) {
  //               showInfoAlert_pda(context, "alertBoxPack");
  //               _search();
  //             }
  //           });
  //         }else{
  //           return;
  //         }
  //       }
  //     }
  //   }
  // }

  Future<void>  _delPackList(dynamic pRowData) async {
    bool result = await confirmDialog(context, "계획취소", "계획에서 삭제하시겠습니까?");
    if (result)
    {
      Map<String, dynamic> delParam = <String, dynamic>{};

      // 차량정보 추가
      delParam["PACK_ID"] = pRowData["PACK_ID"];
      delParam["OUT_NO"] = pRowData["OUT_NO"];

      await transaction(context, "out/OUT0005/deleteOutItemDispatchPlan.do", delParam, (status, responseData) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "계획에서 삭제되었습니다.");
          _search();
        }
      });
    }
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

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    scannedValue = CommonUtil.parseLotNo(scannedValue);
    //_materialVal.text = scannedValue;
    _packId = scannedValue;
    dynamic rowData = CommonUtil.findMapFromList(_searchList, "PACK_ID", scannedValue);

    if(CommonUtil.isEmpty(rowData)){
      //_addPackList();
      showInfoAlert_pda(context, "할당된 재고가 아닙니다.");
    }
    else {
      List<dynamic> _dupList = [];
      for (var item in _searchList) {
        if (item['PACK_ID'] == scannedValue) {
          _dupList.add(item);
        }
      }

      if(_dupList.length > 1){
        final result = await showSmallPopup(context, _dupList, ["PACK_ID","ZZGRADE"]);
        // 선택을 하지 않을 경우 종료
        if(result == null){
          return;
        }

        rowData = result;
      }

      rowData["ROW_COLOR"] = Colors.orange;
      _selectedIndex = rowData["index"];

      setState(() {
        _insertPackId(rowData);
      });
    }

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

    print("************************* \nOUT0005MP03 paramater ${widget.param}");

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
        appBar: pageAppBar(context, "outDetailOut", false),
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
                        child: CustomGrid([['품목','lotNo'],'상차중량','MEHQ','AO30','checkYn'],
                          [['SHPR_ITEM_CD','PACK_ID'], "REAL_STOCK_QTY",'MEHQ','AO30', 'CHECK_YN'],
                          _searchList,
                          focusIndex: _selectedIndex,
                          onTap: (rowData) {
                            // 이전에 선택된 항목들의 색상을 모두 투명하게 변경
                            for (var item in _searchList) {
                              item["ROW_COLOR"] = item["CHECK_YN"]=="Y"? Colors.orange.shade100 : Colors.transparent;
                            }
                            rowData["ROW_COLOR"] = Colors.orange;
                            _selectedIndex = rowData["index"];

                            // if (rowData != null && rowData is Map && rowData['SHPR_ITEM_CD'] != null) {
                            //   _materialVal.text = rowData['SHPR_ITEM_CD'].toString();
                            // }

                            setState(() {
                              _insertPackId(rowData);
                            });
                          },
                          onLongPress: (rowData) {
                            _delPackList(rowData);
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
              CommonText("carCd"),
              CommonTextField(
                _carCd,
                width: MediaQuery.of(context).size.width * 0.72 - 100,
                enabled: false,
              ),
              CommonActionBtn(
                "btnSave",
                width: 80,
                height: MediaQuery.of(context).size.height * 0.06,
                onPressed: _updateDispatch,
              ),
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
          Row(
            children: <Widget>[
              CommonText("driverNm"),
              CommonTextField(
                _driverNm,
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("phoneNo"),
              CommonTextField(
                _driverCall,
              )
            ],
          ),
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
              CommonText("배차중량"),
              CommonTextField(
                TextEditingController(text: _searchList.isNotEmpty
                    ? (_searchList[0]['CAR_QTY'] ?? '0').toString()
                    : '0'),
                enabled: false,
              )
            ],
          ),
        ],
      ),
    );
  }
}