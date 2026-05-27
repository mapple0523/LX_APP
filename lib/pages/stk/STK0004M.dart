
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import '../common/message.dart';
import 'STK0004MP01.dart';

class STK0004M extends StatefulWidget {

  const STK0004M({Key key, this.param}) : super(key: key);

  final dynamic param;
  @override
  _STK0004M createState() => _STK0004M();
}

class _STK0004M extends State<STK0004M> {

  final TextEditingController _selInPalletId   = TextEditingController();  // 재고조정 수량
  final TextEditingController _selExpReason    = TextEditingController();  // 재고조정 사유

  //detail search list
  List<dynamic> _dtlSearch = [];
  List<dynamic> _searchHeaderList = ['팔렛트 ID'];
  List<dynamic> _searchHeaderList2 =  ['PALLET_ID'];

  Map<String, dynamic> param;
  //포커스 노드
  FocusNode fnOne;
  FocusNode fnTwo;

  _InsertList(dynamic PalartId) async {
    Map<String, dynamic> paramMap = {
      "PALLET_ID": _selInPalletId.text
    };

    List<dynamic> check = await transaction(
        context, "/stk0004/check.do", paramMap);

    if (check.length > 0) {
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
    }
    else{
      showInfoAlert(context, '반출된 팔렛트만 사용 가능합니다.');
      _selInPalletId.text = "";
    }
    setState(() {});
  }

  _UpdateInQty() async {

    if(_dtlSearch.length>0) {
      for (var i = 0; i < _dtlSearch.length; i++) {
        _dtlSearch[i]['rmk'] = _selExpReason.text;
      }
      await transaction(context, "/stk0004/savePalletInInfo.do", _dtlSearch, (status, data) {
        if (status == Constant.resSuccessCode) {
          showInfoAlert(context, '팔렛트 반입 완료.');
          _dtlSearch = [];
        }
      });
    }
    else{
      showInfoAlert(context, "처리할 내역이 없습니다.");
    }
    _selInPalletId.selection = TextSelection(baseOffset: 0,extentOffset: _selInPalletId.text.length,);

    setState(() {
    });
  }

  _deleteItemInfo(dynamic data) async {
    _dtlSearch.remove(data);
    setState(() {});
  }

  Future<dynamic> _callNavi() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0004MP01()));
  }


  @override
  void initState() {

    fnOne = FocusNode();
    fnTwo = FocusNode();
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
        appBar: pageAppBar(context, "팔렛트 반입"),
        body: FooterLayout(
            footer: SizedBox(
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CommonActionBtn("반입",
                      onPressed : _UpdateInQty
                  ),
                  CommonActionBtn("반출내역",
                    onPressed: _callNavi,
                  ),
                ],
              ),
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
                    refresh : () {setState(() {});},
                    focusNode : fnOne,
                    scanType: "PT",
                    onEditingComplete : (nodeObj) {
                      _InsertList(_selInPalletId.text);
                    },
              ),
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