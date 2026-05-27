import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/out/OUT0001P03.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/pages/out/OUT0001P01.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:date_format/date_format.dart';

class OUT0001M extends StatefulWidget {
  @override
  _OUT0001M createState() => _OUT0001M();
}

class _OUT0001M extends State<OUT0001M>  {

  DateTime _schPickDt = DateTime.now();
  final TextEditingController _selBarcode    = TextEditingController();
  final TextEditingController _selPickDtFrom = TextEditingController();
  final TextEditingController _selPickDtTo   = TextEditingController();

  List<dynamic> _plantList = [];
  List<dynamic> _slocList = [];
  dynamic _plantValue  = null;
  dynamic _selLocVal = null;
  final FocusNode _scanFocus = FocusNode();
  final TextEditingController _scanValue = TextEditingController();
  List<dynamic> _targetList = [];

  @override
  void initState() {
    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
    _selPickDtTo.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);

    Future.delayed(Duration.zero, () async {
      await _plantSearch();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_W) {
      _plantValue = code;

      await _sLocSearch(code);
    }
    else if(id == Constant.LOCATION_TYPE_Z) {
      _selLocVal = code;
    }

    setState(() {});
  }

  Future<void> _plantSearch() async {
    Map<String, dynamic> param = {"ALL_FLAG" : "Y"};
    _plantList = [];

    List<dynamic> rtnList = await transaction(context, "common/getCommonPlantList.do", param);
    if (CommonUtil.isEmpty(rtnList)) {
      _plantList = [];
      _plantValue = null; // 리스트가 비어있으면 null로 설정
    } else {
      _plantList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_plantList.isNotEmpty) {
        _plantValue = _plantList[0]["CODE"];

        _sLocSearch(_plantValue);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _sLocSearch(String code) async {
    Map<String, dynamic> param = {};
    _slocList = [];

    param = {
      "PLANT": code,
    };

    List<dynamic> rtnList = await transaction(context, "common/getCommonSlocList.do", param);

    if (CommonUtil.isEmpty(rtnList)) {
      _slocList = [];
      _selLocVal = null; // 리스트가 비어있으면 null로 설정
    } else {
      _slocList = rtnList;
      // 첫 번째 항목을 기본값으로 설정
      if (_slocList.isNotEmpty) {
        _selLocVal = _slocList[0]["CODE"];
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<dynamic> savePage(BuildContext context, [dynamic param]) async {

    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0001P03(param: param)));

    if(!CommonUtil.isEmpty(result) && result == true) {
      _searchPickInfo(true);
    }
  }

  Future<void> _searchPickInfo(bool isCallback) async {
    _scanFocus.requestFocus();

    if(!CommonUtil.isNull((_selBarcode.text).trim())){
      _selPickDtFrom.text = "";
      _selPickDtTo.text = "";
    }

    Map<String, dynamic> param = {};
    param['PICK_ID']  = (_selBarcode.text).trim();
    param['PLANT_VALUE']  = _plantValue;
    param['S_LOC']  = _selLocVal;
    param['SCH_PICK_DATE_FROM']  = CommonUtil.removeDash(_selPickDtFrom.text);
    param['SCH_PICK_DATE_TO']  = CommonUtil.removeDash(_selPickDtTo.text);

    List<dynamic> rtnList = await transaction(context, "out/OUT0001/getPdaPickList.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _targetList = [];
    else
      _targetList = rtnList;

    if(!CommonUtil.isNull((_selBarcode.text).trim()) && _targetList.isNotEmpty) {
      String plantValue = rtnList[0]['PLANT'];
      String sLocValue = rtnList[0]['SLOC'];
      _plantValue = plantValue;
      _selLocVal = sLocValue;
    }

    setState(() {});

  }

  Future<void> _handleCMScan(String scannedValue) async {

    print("CM 타입 스캔 처리 시작: $scannedValue");
    _selBarcode.text = scannedValue;
    setState(() {
      _searchPickInfo(false);
    });

    print("CM 타입 스캔 처리 완료");
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "pick"),
        body: Container(
            child: GestureDetector(
              onTap: (){
                CommonUtil.hideKeyboard();
                _scanFocus.requestFocus();
              },
              child: Column(
                children: <Widget> [
                  _searchField(),
                  Expanded(
                    child: CustomGrid([['납품번호','pickId'],['plant','sloc'], ['itemCd','packId'],'bin', ['MEHQ','AO30'], ['pickInstQty','피킹수량']],
                        [['PICK_OUT_NO','PICK_ID'],
                        ['PLANT','SLOC'],
                        ['SHPR_ITEM_NM','LOT_NO'],
                          'LOCATION_CD',
                          ['MEHQ','AO30'],
                          ['PICK_INST_QTY', 'PICK_QTY'],
                        ],
                        _targetList,
                        onTap : ([rowData]) {
                          savePage(context, rowData).then((data)  {
                            _searchPickInfo(true);
                          });
                        },
                        showCheckboxColumn: false,
                        onRefresh : () {
                          _searchPickInfo(true);
                        }
                    ),
                  ),
                ],
              ),

            )
        )
    );
  }

  Widget _searchField() {
    return Container (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText("plant", width: MediaQuery.of(context).size.width * 0.25),
              CommonDropdown("W", _plantValue, _plantList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
              CommonText("sloc", width: MediaQuery.of(context).size.width * 0.25),
              CommonDropdown("Z", _selLocVal, _slocList, comboCallback, width : MediaQuery.of(context).size.width * 0.25-12.5, viewType: "CN",),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("pickInstDt", height: 82, width: MediaQuery.of(context).size.width * 0.25,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonDatePicker(
                    selConroller: _selPickDtFrom,
                    clearEnabled: false,
                    width: MediaQuery.of(context).size.width * 0.75,
                    onEditingComplete: ([result]) {
                      _searchPickInfo(false);
                    },
                  ),
                  CommonDatePicker(
                    selConroller: _selPickDtTo,
                    clearEnabled: false,
                    width: MediaQuery.of(context).size.width * 0.75,
                    onEditingComplete: ([result]) {
                      _searchPickInfo(false);
                    },
                  ),
                ],
              ),
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
              CommonText("pickId",width: MediaQuery.of(context).size.width * 0.25,),
              CommonTextField(_selBarcode,
                width: MediaQuery.of(context).size.width * 0.75-15,
                onEditingComplete: (scannedValue) async {
                  CommonUtil.hideKeyboard();
                  _scanFocus.requestFocus();
                },
                onSubmitted: (value){
                  if(CommonUtil.isNull(value)){
                    _selPickDtFrom.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
                    _selPickDtTo.text = formatDate(_schPickDt, [yyyy, '-', mm, '-', dd]);
                  }
                  setState(() {
                    _handleCMScan(value);
                  });
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonActionBtn("btnSearch"
                  , fontSize: 20
                  , onPressed: () {
                    _searchPickInfo(false);
                  }
              )
            ],
          ),
        ],
      ),
    );
  }
}