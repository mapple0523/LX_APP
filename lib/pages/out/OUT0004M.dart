import 'package:date_format/date_format.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/popup.dart';
import 'package:dtwms_app/pages/out/OUT0005MP06.dart';
import 'package:dtwms_app/pages/sys/function.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class OUT0004M extends StatefulWidget {
  const OUT0004M({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0004M createState() => _OUT0004M();
}

class _OUT0004M extends State<OUT0004M> {
  final TextEditingController _selCustCD = TextEditingController();
  final TextEditingController _carNo = TextEditingController();
  dynamic _plantValue  = null;
  dynamic _selLocVal = null;

  dynamic _selOutNo = null;
  dynamic _selDispatchNo = null;
  final TextEditingController _selMatlVal = TextEditingController();
  final TextEditingController _selBinVal = TextEditingController();
  final FocusNode fnThree = FocusNode();
  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();
  final TextEditingController _selSumQty = TextEditingController();

  bool outNumbering = true;

  void initStatus() {
    super.initState();
  }

  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];
  List<dynamic> _searchCustOutList = [];
  //List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];

  // Future<void> _plantSearch() async {
  //   Map<String, dynamic> param = {"ALL_FLAG" : "Y"};
  //   _plantList = [];
  //
  //   List<dynamic> rtnList =
  //   await transaction(context, "common/getCommonPlantList.do", param);
  //
  //   if (CommonUtil.isEmpty(rtnList)) {
  //     _plantList = [];
  //     _plantValue = null; // 리스트가 비어있으면 null로 설정
  //   } else {
  //     _plantList = rtnList;
  //     // 첫 번째 항목을 기본값으로 설정
  //     if (_plantList.isNotEmpty) {
  //       _plantValue = _plantList[0]["CODE"];
  //
  //       _sLocSearch(_plantValue);
  //     }
  //   }
  //
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  Future<void> _sLocSearch(String code) async {
    Map<String, dynamic> param = {
      "PLANT": code,
    };
    _slocList = [];

    //List<dynamic> rtnList = await transaction(context, "common/getCommonSlocList.do", param);
    List<dynamic> rtnList = await transaction(context, "out/OUT0004/searchSLoc.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _slocList = [];
      _selLocVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _slocList = rtnList;
      //_selLocVal = rtnList[0]['CODE'];
      _selLocVal = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  String getLot(String packId){
    String returnVal = "";
    List<String> arrTmp = packId.split("-");
    returnVal = arrTmp[0];
    return returnVal;
  }

  Future<void> _matlSearch() async {
    Map<String, dynamic> param = {};
    _seletedRecords = [];
    String lotNo = _selMatlVal.text;
    param = {
      "MATL_CD": _selMatlVal.text,
      "LOT_NO": getLot(_selMatlVal.text),
      "LOCATION_CD" : _selBinVal.text,
    };

    List<dynamic> rtnList = await transaction(context, "/out/OUT0004/matlSearch.do", param);

    if (!CommonUtil.isEmpty(rtnList)) {
      // rtnList가 1건 이상일 경우
      if(rtnList.length > 1){
        final result = await showSmallPopup(context, rtnList, ["PACK_ID","GRADE","STOCK_QTY","LOCATION_NM"]);
        // 선택을 하지 않을 경우 종료
        if(result == null){
          return;
        }
        // 그리드에 중복데이터가 있는지 체크
        bool isDuplicated = _searchList.any((selectedItem) => selectedItem['PACK_ID'] == result['PACK_ID']);
        if(isDuplicated){
          showInfoAlert_pda(context, "동일한 Lot No.가 등록되어 있습니다. ");
          return;
        }

        rtnList.clear();
        rtnList.add(result);
      }

      // plant 고정
      _plantValue = rtnList[0]["STOCK_PLANT"];
      _sLocSearch(_plantValue);

      // 처음조회시 OUT_NO, DISPATCH_NO를 채번하여 들어오는 List에 값을 넣어준다.
      if(outNumbering) {
        List<dynamic> outList = await transaction(context, "/out/OUT0004/searchOutNoList.do", param);

        _selOutNo = outList[0]['OUT_NO'];
        _selDispatchNo = outList[0]['DISPATCH_NO'];

        for (var item in rtnList) {
          item['OUT_NO'] = _selOutNo;
          item['DISPATCH_NO'] = _selDispatchNo;
        }

        _searchList.insertAll(0,rtnList);

        _searchList.sort((a, b) {
          int aNum = int.tryParse(a['PACK_ID'].toString().split('-').last) ?? 0;
          int bNum = int.tryParse(b['PACK_ID'].toString().split('-').last) ?? 0;
          print("aNum,bNum $aNum $bNum");
          return aNum.compareTo(bNum);
        });

        for (int i = 0; i < _searchList.length; i++) {
          _searchList[i]['NUM'] = i + 1;
        }

        outNumbering = false;
      } else {
        // 조회된 값에 OUT_NO, DISPATCH_NO를 넣어 값을 넣어준다.
        for (var item in rtnList) {
          item['OUT_NO'] = _selOutNo;
          item['DISPATCH_NO'] = _selDispatchNo;
        }

        _searchList.insertAll(0,rtnList);

        _searchList.sort((a, b) {
          int aNum = int.tryParse(a['PACK_ID'].toString().split('-').last) ?? 0;
          int bNum = int.tryParse(b['PACK_ID'].toString().split('-').last) ?? 0;
          return aNum.compareTo(bNum);
        });

        print('searchList $_searchList');

        for (int i = 0; i < _searchList.length; i++) {
          _searchList[i]['NUM'] = i + 1;
        }
      }
    }
    else{
      //showInfoAlert_pda(context, "chkItemCdCheck");
    }

    _updateSumQty();
    setState(() {
      _selMatlVal.text = "";
    });
  }

  Future<void> _matlReset() async {
    List<String> selectedPackIds = _seletedRecords.map((record) => record['PACK_ID'].toString()).toList();

    _searchList.removeWhere((item) => selectedPackIds.contains(item['PACK_ID'].toString()));

    for (int i = 0; i < _searchList.length; i++) {
      _searchList[i]['NUM'] = _searchList.length - i;
    }

    _seletedRecords = [];

    _updateSumQty();
    setState(() {});
  }

  Future<void> _insertPackId() async {
    if (_searchList.length <= 0) {
      showInfoAlert_pda(context, "chkShuttleOutCheck");
      return;
    }

    if (CommonUtil.isEmpty(_selLocVal)) {
      showInfoAlert_pda(context, "이송 할 S.Loc을 선택하세요.");
      return;
    }

    bool result = await confirmDialog(context, "확인", "셔틀출고 하시겠습니까?");

    if (result) {
      CommonUtil.findRegExpRtnList(_searchList, 'EDIT_QTY', '[1-9]');

      List<dynamic> resultList = _searchList.map((record) {
        Map<String, dynamic> updatedRecord = Map<String, dynamic>.from(record);
        updatedRecord['PLANT'] = _plantValue;
        updatedRecord['SLOC'] = _selLocVal;
        updatedRecord['CAR_NO'] = _carNo.text;
        updatedRecord['STOCK_QTY'] = updatedRecord['EDIT_QTY'];
        updatedRecord.remove('ROW_COLOR');
        return updatedRecord;
      }).toList();

      print("resultList + $resultList");

      // Map으로 감싸지 말고 직접 List 전송
      await transaction(
          context, "/out/OUT0004/insertShuttleOutList.do", resultList, (status,
          data) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert_pda(context, "alertShuttleOut");
          _searchList = [];
          outNumbering = true;
          _selOutNo = null;
          _selDispatchNo = null;
          _selSumQty.text = "";
          _carNo.text = "";
        }
      });
      setState(() {});
    }
  }

  Future<int> _searchOutCnt() async {

    Map<String, dynamic> param = {
      "CUST_CD": _selCustCD.text
    };
    dynamic outCnt = await transaction(context, "INN0004/searchOutCnt.do", param);

    return outCnt;
  }

  Future<dynamic> _movePageSelection(BuildContext context, [dynamic param]) async {
    _searchList = [];
    _searchCustOutList = [];
    dynamic result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OutNoPage(param: param)));
    if(!CommonUtil.isEmpty(result) && result is List) {
      return result;
    }
  }

  Future<dynamic> callPallet(BuildContext context, [dynamic param]) async {
    _scanFocus.requestFocus();
    if (param == null) {
      param = <String, dynamic>{};
    }

    param['OUT_NO'] = _selOutNo;
    param['DISPATCH_NO'] = _selDispatchNo;
    param['VEHICLE_NO'] = _carNo.text;

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0005MP06(param: param)));

    return result;
  }

  Future<void> _handleCMScan(String scannedValue) async {
    print("CM 타입 스캔 처리 시작: $scannedValue");
    scannedValue = CommonUtil.parseLotNo(scannedValue);

    // BIN NO scan
    if (scannedValue.startsWith(Constant.BIN_BARCODE_DELIMIT)) {
      scannedValue = scannedValue.replaceAll(Constant.BIN_BARCODE_DELIMIT, "");
      _selBinVal.text = scannedValue;
    }
    else{
      _selMatlVal.text = scannedValue;

      bool isDuplicate = _searchList.any((item) => item['PACK_ID'] == _selMatlVal.text);

      if (isDuplicate) {
        confirmDialog(context, "동일 바코드", "이미 목록에 추가된 항목입니다, 목록에서 제외하시겠습니까?").then((value) {
          if(value) {
            _searchList.removeWhere((item) => item['PACK_ID'] == _selMatlVal.text);


          }
        });
        setState(() {
          _selMatlVal.text="";
        });
      } else {
        _matlSearch();
      }
    }
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    _scanFocus.requestFocus();

    if(id == Constant.LOCATION_TYPE_W) {
      _plantValue = code;

      await _sLocSearch(code);
    }
    else if(id == Constant.LOCATION_TYPE_Z) {
      _selLocVal = code;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState(); // 먼저 호출

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _selBinVal.text = await App_Function.GetLocation(context,"P");
      await _sLocSearch(_plantValue);
    });

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateSumQty() {
    double sum = _searchList.fold(0, (prev, item) {
      return prev + (double.tryParse(item['STOCK_QTY'].toString()) ?? 0);
    });
    _selSumQty.text = sum % 1 == 0 ? sum.toInt().toString() : sum.toString();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "shuttleOutSearch", false),
        body: FooterLayout(
          footer: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CommonActionBtn(
                      "btnDelete",
                      width: screenWidth * 0.5 - 10,
                      onPressed: _matlReset,
                    ),
                    CommonActionBtn(
                      "btnMove",
                      width: screenWidth * 0.5 - 10,
                      onPressed: _insertPackId,
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: GestureDetector(
              onTap: () {
                CommonUtil.hideKeyboard();
                _scanFocus.requestFocus();
              },
              child: Column(
                  children: <Widget>[
                    _searchField(),
                    Expanded(
                      child: CustomGrid(
                        ['No', ['lotNo','품목명'], 'weight','GRADE','bin'],
                        ['NUM', ['PACK_ID','ITEM_DESC'], 'EDIT_QTY','GRADE','LOCATION_CD'],
                        _searchList,
                        onTap: (e) {
                          _scanFocus.requestFocus();
                          _selectItem(e);
                        },
                        showSort: true,
                        sortCol: [{"CODE" : "GRADE", "NAME" : "GRADE"},
                          {"CODE" : "PACK_ID", "NAME" : "Lot No."},//PACK_ID
                          {"CODE" : "EDIT_QTY", "NAME" : "중량"}],
                      ),
                    ),
                  ]
              )
          ),
        ));
  }

  void _selectItem(Map<String, dynamic> item) {
    if(CommonUtil.isNull(CommonUtil.findValFromList(_seletedRecords, 'PACK_ID', item['PACK_ID'], 'PACK_ID'))) {
      item["ROW_COLOR"] = Colors.orange;
      _seletedRecords.add(item);
    }
    else{
      item["ROW_COLOR"] = Colors.transparent;
      _seletedRecords.remove(item);
    }
    setState(() {});
  }

  Widget _searchField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("carNo", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField(_carNo,
                width: MediaQuery.of(context).size.width * 0.5 - 8,
                clearEnabled: false,
                onEditingComplete: (nodeObj) {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
              ),
              CommonActionBtn(
                "plt",
                width: MediaQuery.of(context).size.width * 0.3 - 15,
                height: MediaQuery.of(context).size.height * 0.06,
                onPressed: () => callPallet(context),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("plant", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField( _plantValue,
                width : MediaQuery.of(context).size.width * 0.3-12.5,
                enabled: false,
                onTap: (){
                  _scanFocus.requestFocus();
                },
              ),
              // CommonDropdown("W"
              //   , _plantValue
              //   , _plantList
              //   , comboCallback, width : MediaQuery.of(context).size.width * 0.3-12.5
              //   , viewType: "CN"
              // ),
              CommonText("sloc", width: MediaQuery.of(context).size.width * 0.2),
              CommonDropdown("Z",
                _selLocVal,
                _slocList,
                comboCallback,
                width : MediaQuery.of(context).size.width * 0.3-12.5,
                viewType: "CN",
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin", width: MediaQuery.of(context).size.width * 0.2),
              CommonLocation(
                  selLocVal: _selBinVal,
                  width: MediaQuery.of(context).size.width * 0.8,
                  onEditingComplete: (result) {
                    CommonUtil.hideKeyboard();
                    _scanFocus.requestFocus();
                  })
            ],
          ),
          Row(
            children: <Widget>[
              Offstage(
                offstage: true, // false로 바꾸면 다시 보임
                child: CommonScanTextField(
                  _scanValue,
                  focusNode: _scanFocus, 
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
              CommonText("lotNo", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField(_selMatlVal,
                width: MediaQuery.of(context).size.width * 0.3-12.5,
                onEditingComplete: (result)  {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
                onSubmitted: (value){
                  _handleCMScan(value);
                },
              ),
              CommonText("출고수량", width: MediaQuery.of(context).size.width * 0.2),
              CommonTextField(_selSumQty,
                enabled: false,
                width: MediaQuery.of(context).size.width * 0.3-12.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}