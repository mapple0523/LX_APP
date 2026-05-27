import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commBoxInfo.dart';
import 'package:dtwms_app/pages/common/commOutNo.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/stk/STK0006MP05.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

class STK0006MP02 extends StatefulWidget {

  const STK0006MP02({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _STK0006MP02 createState() => _STK0006MP02();
}

class _STK0006MP02 extends State<STK0006MP02>  {
  final TextEditingController _selOutNoVal = TextEditingController();
  final TextEditingController _selCustCD = TextEditingController();
  final TextEditingController _plantValue = TextEditingController();
  final TextEditingController _selLocVal  = TextEditingController();
  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();
  final FocusNode fnThree = FocusNode();
  final FocusNode fnFour = FocusNode();

  List<dynamic> _searchList = [];
  List<dynamic> _seletedRecords = [];
  List<dynamic> _searchCustOutList = [];
  dynamic popUpYn = "N";

  Future<void> _search() async {
    if(!CommonUtil.isEmpty(widget.param) && popUpYn == "N"){
      if(CommonUtil.isEmpty(widget.param["_searchCustOutList"])){
        _selOutNoVal.text = widget.param["OUT_NO"];
      }
      else{
        _searchCustOutList = widget.param["_searchCustOutList"];
        _selCustCD.text = widget.param["CUST_CD"];
      }
      popUpYn = "Y";
    }
    if(CommonUtil.isNull(_selOutNoVal.text) && CommonUtil.isNull((_selCustCD.text))) {
      showInfoAlert_pda(context, "chkScanYN");
      setState(() {
        _searchList = [];
        _seletedRecords = [];
        _searchCustOutList = [];
      });
      return;
    }

    Map<String, dynamic> param = {
      "OUT_NO"        : _selOutNoVal.text,
      "custList"      : _searchCustOutList,
      "CUST_CD"       : _selCustCD.text,
      "PLANT_VALUE"   : _plantValue.text,
      "S_LOC"         : _selLocVal.text,
    };

    List<dynamic> rtnList = await transaction(context, "stk0006/searchPalletPack.do", param);
    if(CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    setState(() {
    });
  }

  Future<void> _insertPackId() async {
    List<dynamic> resultList = CommonUtil.findRegExpRtnList(_seletedRecords, 'EDIT_QTY', '[1-9]');
    resultList = ConvertUtil.removeColumn(_seletedRecords, ["ROW_COLOR"]);
    if(resultList.isEmpty) {
      showInfoAlert_pda(context, "chkSelectedPack");
      _seletedRecords = [];
      return;
    }
    for(dynamic i=0;i<resultList.length;i++){
      dynamic param = resultList[i];
      if(param['EDIT_QTY'] == null || param['EDIT_QTY'].toString().isEmpty ||
          !param['EDIT_QTY'].toString().contains(RegExp(r'[1-9]'))){
        showInfoAlert_pda(context, "chkValidQty");
        _seletedRecords = [];
        return;
      }
      if((param['SHPR_ITEM_CD'] == null || param['SHPR_ITEM_CD'].toString().isEmpty) &&
          int.parse(param['EDIT_QTY']) > 1) {
        showInfoAlert_pda(context, "chkBoxAvailQty");
        return;
      }
    }

    //1. EDIT_QTY 체크. => 패킹 버튼 눌렀을떄 체크.
    //2. 그리드에서 숫자 안넣거나 0넣으면 색깔 빼기
    //3. 그리드 리플래쉬 빼주기.

    await transaction(context, "stk0006/insertPalletPack.do", resultList, (status, data) {
       if (status == Constant.resSuccessCode) {
         showInfoAlert_pda(context, "alertBoxPack");
         _seletedRecords = [];
         _searchList = [];
         _search();
       }
    });
    setState(() {});
  }

  Future<int> _searchOutCnt() async {

    Map<String, dynamic> param = {
      "CUST_CD": _selCustCD.text
    };
    dynamic outCnt = await transaction(context, "stk0006/searchOutCnt.do", param);

    return outCnt;
  }

  Future<dynamic> _movePageSelection(BuildContext context, [dynamic param]) async {
    _searchList = [];
    _searchCustOutList = [];
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OutNoPage(param: param)));
    if(!CommonUtil.isEmpty(result) && result is List) {
      return result;
    }
  }

  Future<dynamic> _movePageBoxInfo(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OutBoxInfoPage(param: param)));
    if(!CommonUtil.isEmpty(result)) {
      return result;
    }
  }

  Future<dynamic> _movePage(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0006MP05(param: param)));

    return result;
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if(!CommonUtil.isEmpty(widget.param))
        _search();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : true,
        appBar: pageAppBar(context, "palletPacking",false),
        body: FooterLayout(
          footer: CommonActionBtn(
            "btnPack",
            onPressed: _insertPackId,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                height : CommonUtil.pageMaxHeight(context,(55 * (_searchList.length - 7)).toDouble()),
                child: GestureDetector(
                  onTap: (){
                    CommonUtil.hideKeyboard();
                  },
                child: Column(
                    children: <Widget> [
                      Row(children: <Widget>[_searchField()]),
                      CommonActionBtn("btnSearch",
                        height: 50,
                        fontSize: 20
                        , onPressed: () {
                          _searchCustOutList = [];
                          Map<String, dynamic> paramMap = {
                            "CUST_CD": _selCustCD.text
                          };
                          if(CommonUtil.isNull(_selOutNoVal.text) && CommonUtil.isNull((_selCustCD.text))) {
                            showInfoAlert_pda(context, "chkScanYN");
                            setState(() {
                              _searchList = [];
                            });
                            return;
                          }
                          //배송처를 조회를 하여 배송처의 포함된 출고번호 갯수를 체크
                          if(CommonUtil.isNull(_selOutNoVal.text.trim())){
                            _searchOutCnt().then((value){
                              if(value == 1) {
                                _search();
                                fnFour.unfocus();
                              }
                              else if(value > 0){
                                _movePageSelection(context,paramMap).then((data){
                                  _searchCustOutList = data;
                                  _search();
                                });
                              }
                              else{
                                _search();
                              }
                            });
                          }
                          else{
                            _search();
                          }
                          fnOne.unfocus();
                          fnTwo.unfocus();
                          fnThree.unfocus();
                          fnFour.unfocus();
                        },
                      ),
                      Expanded(
                        child: CustomGrid(['item', 'packAvailQty', 'packQty'],
                          ['PLT_NM','BOX_AVAIL_QTY','EDIT_QTY'],
                          _searchList,
                          enableRefresh: false,
                          seletedRecords: _seletedRecords,
                          onFieldSubmitted: (rowData) {
                            _searchList.forEach((e) {
                              CommonUtil.changeValueFromList(
                                  _searchList,
                                  'UNIQUE_KEY',
                                  rowData['UNIQUE_KEY'],
                                  'EDIT_QTY',
                                  rowData['EDIT_QTY']);
                              if (rowData['EDIT_QTY'].toString().contains(RegExp(r'[1-9]')) &&
                                  e["UNIQUE_KEY"] == rowData['UNIQUE_KEY']) {
                                e["ROW_COLOR"] = Colors.orange;
                                _seletedRecords.remove(e);
                                _seletedRecords.add(e);
                              }
                              if (!rowData['EDIT_QTY'].toString().contains(RegExp(r'[1-9]')) &&
                                  e["UNIQUE_KEY"] == rowData['UNIQUE_KEY']) {
                                e["ROW_COLOR"] = Colors.transparent;
                                _seletedRecords.remove(e);
                              }
                            });
                            setState(() {});
                          },
                          onTap: (rowData){
                            if(!CommonUtil.isNull(rowData["BOX_NO"])){
                              Map<String, dynamic> paramMap = {
                                "BOX_NO": rowData["BOX_NO"]
                              };
                              _movePageBoxInfo(context, paramMap);
                            }
                          },
                        ),
                      ),
                    ]
                )
            )
            ),
          ),
        )
    );
  }

  Widget _searchField() {
    return Expanded (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              CommonText(
                "plant",
                width: 78,
              ),
              CommonTextField(
                _plantValue,
                focusNode: fnOne,
                width: 90,
                onEditingComplete: (nodeObj) {
                  fnOne.unfocus();
                  FocusScope.of(context).requestFocus(fnTwo);
                },
              ),
              CommonText(
                "sloc",
                width: 78,
              ),
              CommonTextField(_selLocVal, focusNode: fnTwo, width: 90,
                  onEditingComplete: (nodeObj) {
                    fnTwo.unfocus();
                    FocusScope.of(context).requestFocus(fnThree);
                  }),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("outNo"),
              CommonScanTextField(
                _selOutNoVal,
                focusNode: fnThree,
                scanType: "OT",
                onEditingComplete: ([result]) {
                  _searchCustOutList = [];
                  _search();
                },
              )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("deliveryLocation"),
              CommonScanTextField(_selCustCD,
                  focusNode: fnFour, scanType: "PI",
                  onEditingComplete: ([result]) {
                    _searchCustOutList = [];
                    fnFour.unfocus();
                    //해당 배송처를 기준으로 조회를 다시 한다.(카운트를 체크한다.)
                    Map<String, dynamic> paramMap = {
                      "CUST_CD": _selCustCD.text
                    };
                    _searchOutCnt().then((value){
                      if(value == 1) {
                        _search();
                        fnFour.unfocus();
                      }
                      else if(value > 0){
                        _movePageSelection(context,paramMap).then((data){
                          _searchCustOutList = data;
                          _search();
                        });
                      }
                      else{
                        _search();
                      }
                    });
                    /*_search();
                    _selCustCD.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _selCustCD.text.length,
                    );*/
                  })
            ],
          ),
        ],
      ),
    );
  }
}