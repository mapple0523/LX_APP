import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/out/OUT0001P01.dart';
import 'package:dtwms_app/pages/out/OUT0001P04.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/pages/out/OUT0001P03.dart';
import 'package:dtwms_app/models/commonDatePicker.dart';
import 'package:date_format/date_format.dart';

class OUT0001P03 extends StatefulWidget {
  const OUT0001P03({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUT0001P03 createState() => _OUT0001P03();
}

class _OUT0001P03 extends State<OUT0001P03>  {

  final TextEditingController _selLotVal    = TextEditingController();
  final TextEditingController _selLocVal    = TextEditingController();
  final TextEditingController _planQty    = TextEditingController();
  final TextEditingController _pickQty          = TextEditingController();
  final TextEditingController _selPackId    = TextEditingController();

  final TextEditingController _selOutQty    = TextEditingController();
  final TextEditingController _locaBarcode  = TextEditingController();
  final TextEditingController _itemBarcode  = TextEditingController();

  FocusNode fnOne;
  FocusNode fnTwo;
  FocusNode fnThree;
  List<dynamic> _targetList = [];

  @override
  void initState() {
    fnOne = FocusNode();
    fnTwo = FocusNode();
    fnThree = FocusNode();

    super.initState();

    ZebraDataWedgeListener.initFunc();

    _selLocVal.text = widget.param["LOCATION_CD"].toString();
    _selLotVal.text = widget.param["LOT_NO"].toString();
    _planQty.text = widget.param["PICK_INST_QTY"].toString();
    _pickQty.text = widget.param["PICK_QTY"].toString();

    Future.delayed(Duration.zero, () {
      if(!CommonUtil.isEmpty(widget.param))
        _searchStockInfo();
    });
  }

  @override
  void dispose() {
    fnOne.dispose();
    fnTwo.dispose();
    fnThree.dispose();
    super.dispose();
  }

  // Future<dynamic> savePage(BuildContext context, [dynamic param]) async {
  //
  //   final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0001P01(param: param)));
  // }

  Future<void> _saveInOrderInfo(BuildContext context, [dynamic param]) async {

    // if(_locaBarcode.text.toUpperCase() != widget.param['LOCATION_CD']) {
    //   showInfoAlert_pda(context, "chkDiffPickLoca");
    //   _fnOne.requestFocus();
    //   return;
    // }
    //
    // if(CommonUtil.isNull(_selOutQty.text)) {
    //   showInfoAlert_pda(context, "chkPickQty");
    //   return;
    // }

    // if(int.parse(_selOutQty.text) != widget.param['PICK_INST_QTY']) {
    //   showInfoAlert_pda(context, "chkDiffPickQty");
    //   _fnTwo.requestFocus();
    //   return;
    // }

    _locaBarcode.text = param['LOCATION_CD'];
    _selOutQty.text = param['STOCK_QTY'].toString();

    param['SCAN_LOCATION_CD'] = _locaBarcode.text.toUpperCase();
    param['SCAN_ITEM_BARCODE'] = _itemBarcode.text;
    param['VAL_OUT_QTY'] = double.tryParse(_selOutQty.text) ?? 0.0;
    param['PICK_QTY']    = double.tryParse(_selOutQty.text) ?? 0.0;

    print(param);

    dynamic resultStatus;

    //1. 트랜잭션 대기
    await transaction(context, "out/OUT0001/doPicking.do", param, (status, data) {
      resultStatus = status;
    });

    //2. 트랜잭션 성공후 재조회
    if (resultStatus == Constant.resSuccessCode) {
      await _searchPickInfo();
      await _searchStockInfo();
      showInfoAlert_pda(context, "alertPick");
    }
  }

  Future<dynamic> detailPage(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => OUT0001P04(param: widget.param)
        )
    );

    if (result == true) {
      await _searchPickInfo();
      await _searchStockInfo();
    }

    return result;
  }

  Future<void> _searchPickInfo() async {
    FocusScope.of(context).unfocus();

    Map<String, dynamic> param = {};
    param['PICK_ID']  = widget.param['PICK_ID'];
    //param['PLANT_VALUE']  = widget.param['PLANT'];
    param['S_LOC']  = widget.param['SLOC'];
    param['LOCATION_CD']  = widget.param['LOCATION_CD'];

    List<dynamic> rtnList = await transaction(context, "out/OUT0004/searchPickQty.do", param);

    if (rtnList != null && rtnList.isNotEmpty) {
      _pickQty.text = (rtnList[0]['PICK_QTY'] ?? 0).toString();
      setState(() {});
    }

    setState(() {});

  }

  Future<void> _searchStockInfo() async {
    FocusScope.of(context).unfocus();

    Map<String, dynamic> param = {};
    param['LOT_NO']  = widget.param['LOT_NO'];
    param['SHPR_ITEM_CD']  = widget.param['SHPR_ITEM_CD'];
    param['LOCATION_CD']  = widget.param['LOCATION_CD'];
    param['PLANT'] = widget.param['PLANT'];
    param['SLOC'] = widget.param['SLOC'];

    List<dynamic> rtnList = await transaction(context, "out/OUT0001/getPdaStockList.do", param);

    if(CommonUtil.isEmpty(rtnList))
      _targetList = [];
    else
      _targetList = rtnList;

    setState(() {});

  }

  Future<void> _handleCMScan(String scannedValue) async {
    FocusScope.of(context).unfocus();

    scannedValue = CommonUtil.parseLotNo(scannedValue);

    print("CM 타입 스캔 처리 시작: $scannedValue");
    _selPackId.text = scannedValue;
    setState(() {});

    // 그리드에서 PACK_ID가 동일한걸 찾기
    final matchedRow = _targetList.firstWhere(
          (row) => row['PACK_ID'].toString() == scannedValue,
      orElse: () => null,
    );

    // 그후에 Grid의 선택 이벤트와 동일하게 작동
    if (matchedRow != null) {
      Map combinedParam = Map.from(widget.param);
      combinedParam.addAll(matchedRow);
      
      // savePage(context, combinedParam).then((data) {
      //   _searchStockInfo();
      // });

      _saveInOrderInfo(context, combinedParam);

    } else {
      showInfoAlert(context, "해당 포장번호가 없습니다.");
    }

    print("CM 타입 스캔 처리 완료");


  }

  @override
  Widget build(BuildContext context) {
    //ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "pick"),
        body: Container(
            child: GestureDetector(
              onTap: (){
                CommonUtil.hideKeyboard();
              },
              child: Column(
                children: <Widget> [
                  _searchField(),
                  Row(
                    children: <Widget>[
                      CommonActionBtn("상세목록"
                          , fontSize: 20
                          , onPressed: () {
                        detailPage(context,widget.param);
                          }
                      )
                    ],
                  ),
                  Expanded(
                    child: CustomGrid(['포장번호','재고수량'],
                        ['PACK_ID','STOCK_QTY'], _targetList,
                        onTap : ([rowData]) {
                          Map<String, dynamic> combinedParam = Map<String, dynamic>.from(widget.param);
                          combinedParam.addAll(rowData ?? {});

                          // savePage(context, combinedParam).then((data)  {
                          //   _searchStockInfo();
                          // });

                          _saveInOrderInfo(context, combinedParam);
                        },
                        showCheckboxColumn: false,
                        onRefresh : () {
                          _searchStockInfo();
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
              CommonText("lotNo"),
              CommonTextField(_selLotVal,enabled: false)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("bin"),
              CommonTextField(_selLocVal,enabled: false)
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("지시수량"),
              CommonTextField(_planQty,
                enabled: false,
                width: MediaQuery.of(context).size.width * 0.22-12.5,
              ),
              CommonText("피킹수량"),
              CommonTextField(_pickQty,
                enabled: false,
                width: MediaQuery.of(context).size.width * 0.22-12.5,),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목명"),
              CommonTextField(widget.param['SHPR_ITEM_NM'],enabled: false)
            ],
          ),
          Visibility(
            visible: true,
            child: Row(
              children: <Widget>[
                CommonText("포장번호"),
                CommonScanTextField(_selPackId,
                  focusNode: fnOne,
                  scanType: "CM",
                  onTap: () {},
                  onEditingComplete: (scannedValue) async {
                    await _handleCMScan(scannedValue);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}