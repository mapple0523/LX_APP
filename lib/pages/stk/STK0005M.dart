import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import '../common/message.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:date_format/date_format.dart';

class STK0005M extends StatefulWidget {

  @override
  _STK0005M createState() => _STK0005M();
}

class _STK0005M extends State<STK0005M> {
  final TextEditingController _selInPalletId   = TextEditingController();  // 재고조정 수량
  final TextEditingController _selExpReason    = TextEditingController();  // 재고조정 사유

  DateTime _schOutDt = DateTime.now();
  final TextEditingController _selOutDt    = TextEditingController();

  //detail search list
  List<dynamic> _dtlSearch = [];
  List<dynamic> _searchHeaderList = ['팔렛트 ID','팔렛트 유형'];
  List<dynamic> _searchHeaderList2 =  ['PALLET_ID','PALLET_TYPE_NM'];

  Map<String, dynamic> param;
  //포커스 노드
  FocusNode fnOne;
  FocusNode fnTwo;

  int checkCount = 0;
  //SHPR LIST
  List<dynamic> _CompDtList = [];
  dynamic _selCompDtId;

  //SHPR LIST
  List<dynamic> _CompList = [{"NAME" : "화주","CODE" : 1},{"NAME" : "고객","CODE" : 2}];
  dynamic _selCompCd;


  _deleteItemInfo(dynamic data) async {
    _dtlSearch.remove(data);
    setState(() {});
  }

  Future<void> _check() async{

    Map<String, dynamic> paramMap = {
      "PALLET_ID" : _selInPalletId.text
    };

    List<dynamic> check = await transaction(context, "stk0005/selectOutTargetPalletList.do", paramMap);
    List<dynamic> PalletCheck = await transaction(context,"stk0005/check.do",paramMap);

    for(var i=0;i<check.length;i++){
      if(_selInPalletId.text == check[i]['CODE']) {
        checkCount = 1;
        break;
      }
      else
        checkCount = 0;
    }
    if(checkCount == 0 && PalletCheck.length>0){
      showInfoAlert(context, '이미 반출된 팔렛트 입니다.');
    }
    else if(PalletCheck.length == 0)
      showInfoAlert(context, "팔렛트 정보를 다시 확인하세요");

    setState(() {});
  }

  Future<void> _searchCompInfo(dynamic code) async {
    if(code == 1){
      _CompDtList = await transaction(context, "common/shpr.do", param);
        _selCompDtId = _CompDtList[0]['CODE'];
    }
    else{
      _CompDtList = await transaction(context, "common/cust.do", param);
        _selCompDtId = _CompDtList[0]['CODE'];
    }

    setState(() {});
  }

  _InsertList(dynamic PalartId) async {

    Map<String,dynamic> paramMapcheck = {
      "PALLET_ID" : _selInPalletId.text,
      "rmk"       : _selExpReason.text
    };

    List<dynamic> check = await transaction(context, "stk0005/check.do",paramMapcheck);

    Map<String, dynamic> paramMap = {
      "PALLET_ID": _selInPalletId.text,
      "PALLET_TYPE_NM" : check[0]['PALLET_TYPE_NM']
    };
      if (_dtlSearch.length == 0) {
        _dtlSearch.add(paramMap);
      }
      else {
        for(int i=0;i<_dtlSearch.length;i++) {
          if(!CommonUtil.isNull(CommonUtil.findValFromList(_dtlSearch, 'PALLET_ID',PalartId,'PALLET_ID'))){
            showInfoAlert(context, '중복된 팔렛트입니다.');
            break;
          }
          else{
            _dtlSearch.add(paramMap);
            break;
          }
        }
      }
      _selInPalletId.selection = TextSelection(
        baseOffset: 0, extentOffset: _selInPalletId.text.length,);
      setState(() {});
  }

  _savePalletOutInfo() async {

    if(_dtlSearch.length>0) {
      Map<String, dynamic> paramMap = {
        "compCd": _selCompDtId,
        "rmk": _selExpReason.text,
        "palletOutList": _dtlSearch,
      };

      await transaction(
          context, "/stk0005/savePalletOutInfo.do", paramMap, (status, data) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert(context, '팔렛트 반출 완료.');
        }
      });
      _selInPalletId.selection = TextSelection(
        baseOffset: 0, extentOffset: _selInPalletId.text.length,);
      _dtlSearch = [];
    }
    else{
      showInfoAlert(context, "처리할 내역이 없습니다.");
    }
    setState(() {
    });
  }



  @override
  void initState() {

    fnOne = FocusNode();
    fnTwo = FocusNode();

    _selOutDt.text = formatDate(_schOutDt, [yyyy, '-', mm, '-', dd,'-',HH]);

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        shprInfo(context,null).then((data) =>  setState(() {
          _CompDtList = data;
          if(CommonUtil.isEmpty(_CompDtList))
            _selCompDtId = "";
          else
            _selCompDtId = _CompDtList[0]['CODE'];
        }))
    );

    WidgetsBinding.instance.addPostFrameCallback((_) =>
    _selCompCd = _CompList[0]['CODE']
    );
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        FocusScope.of(context).requestFocus(fnOne)
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    var color = 0xff453658;
    return Scaffold(
        resizeToAvoidBottomInset : true,
        appBar: pageAppBar(context, "팔렛트 반출"),
        body: FooterLayout(
          footer: CommonActionBtn("반출",
            onPressed: _savePalletOutInfo,
          ),
        child: SingleChildScrollView(
          child: GestureDetector(
          onTap: (){
          CommonUtil.hideKeyboard();
          },
          child: Column(
            children: <Widget> [
              _searchField(),
              CustomGrid(_searchHeaderList,_searchHeaderList2, _dtlSearch,
                // height: 250,
                onLongPress: ([rowData]) {
                  confirmDialog(context, "삭제", "[팔렛트 : " +  rowData['PALLET_ID'] + "] 삭제하시겠습니까?").then((value) {
                    if(value) {
                      _deleteItemInfo(rowData);
                    }
                  });
                },),
            ],
          ),
        )
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
              CommonText("팔렛트 ID"),
              CommonScanTextField(_selInPalletId,
                  focusNode : fnOne
                  ,scanType: "PT"
                  , onEditingComplete : (nodeObj) {
                    _check().then((data){
                      if(checkCount == 1) {
                        _InsertList(_selInPalletId.text);
                        checkCount = 0;
                      }
                    });
                  },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("반출처유형"),
              CommonDropdown(null,_selCompCd, _CompList, (id, code, name){
                setState(() {
                  _selCompCd = code;
                  _searchCompInfo(_selCompCd);
                });
              }, width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("반출처"),
              CommonDropdown(null,_selCompDtId, _CompDtList, (id, code, name){
                setState(() {
                  _selCompDtId = code;
                });
              }, width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("비고"),
              CommonTextField(_selExpReason,
                focusNode : fnTwo,
                onEditingComplete : (nodeObj) {
                  fnTwo.unfocus();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

}

//common.selectComCodeInfo