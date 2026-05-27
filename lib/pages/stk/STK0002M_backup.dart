import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonGroup.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/pages/stk/STK0002MP01.dart';

class STK0002M extends StatefulWidget {

  @override
  _STK0002M createState() => _STK0002M();
}

class _STK0002M extends State<STK0002M> {
  final TextEditingController _selLoc          = TextEditingController();  // 재고조정 수량
  final TextEditingController _selBarCode      = TextEditingController();  // 재고조정 사유

  final TextEditingController _plantValue = TextEditingController();
  final TextEditingController _sLoc = TextEditingController();
  final TextEditingController _binValue = TextEditingController();

  //detail search list
  List<dynamic> _Search = [];
  List<dynamic> _searchHeaderList = ['품목', '수량', '입고일자', 'Lot No'];
  List<dynamic> _searchHeaderList2 =  [['SHPR_NM','SHPR_ITEM_NM'],['STOCK_QTY','HOLD_QTY'],['EXPIRE_DATE_FM','PACK_ID'],'LOTNO'];

  Map<String, dynamic> param;
  //포커스 노드
  FocusNode fnOne;
  FocusNode fnTwo;
  FocusNode fnThree;

  _search() async {
    Map<String, dynamic> paramMap = {
      "LOCATION_CD" : _selLoc.text,
      "ITEM_BARCODE" : _selBarCode.text,
    };
    if(CommonUtil.isNull(_selLoc.text))
      showInfoAlert(context,'로케이션을 입력하세요');
    else {
      _Search = await transaction(context, "/stk0002/search.do", paramMap);
      setState(() {});
    }
  }


  Future<dynamic> _callNavi(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0002MP01(param: param)));

    if(result != null && result){
      _search();
    }
  }


  @override
  void initState() {

    fnOne = FocusNode();
    fnTwo = FocusNode();
    fnThree = FocusNode();

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
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "재고이동"),
        body: Container(
          child: GestureDetector(
          onTap: (){
          CommonUtil.hideKeyboard();
          },
          child: Column(
            children: <Widget> [
              _searchField(),
              CommonActionBtn(
                "조회",
                height: 50,
                fontSize: 20
                , onPressed: () {
                _search();
                //수량 update controller
                //다시 서치
              },
              ),
              Expanded(child : CustomGrid(_searchHeaderList,_searchHeaderList2, _Search,
                  onTap :  ([rowData, colVal]){
                    Map<String, dynamic> paramMap = {
                      "LOCATION_CD"    : rowData["LOCATION_CD"],
                      "ITEM_BARCODE"   : rowData["ITEM_BARCODE"],
                      "STOCK_SEQ"      :rowData["STOCK_SEQ"],
                    };
                    _callNavi(context, paramMap).then((data)  {
                      _search();
                    });
                  },
                  onRefresh:(){
                    _search();
                  },
              )),
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
                CommonText("로케이션"),
                CommonLocation(focusNode: fnOne, selLocVal: _selLoc, onEditingComplete : (result) {
                  fnOne.unfocus();
                  FocusScope.of(context).requestFocus(fnTwo);
                  _selBarCode.text = "";
                  _search();
                }),
              ],
            ),
            Row(
              children: <Widget>[
                CommonText("품목 바코드"),
                CommonScanTextField(_selBarCode,
                  width : 225,
                  refresh : () {setState(() {});},
                  autofocus : false,
                  focusNode : fnTwo,
                  scanType: "PD",
                  onEditingComplete : (nodeObj) {
                    _selBarCode.selection = TextSelection(baseOffset: 0,extentOffset: _selBarCode.text.length,);
                    _search().then((data)  {
                      Map<String, dynamic> paramMap = {
                        "LOCATION_CD"    : _Search[0]["LOCATION_CD"],
                        "ITEM_BARCODE"   : _selBarCode.text,
                        "STOCK_SEQ"      :_Search[0]["STOCK_SEQ"],
                      };
                      if(_Search.length == 1){
                        _callNavi(context, paramMap).then((data)  {
                          _search();
                        });
                      }
                      else{
                        _search();
                      }
                  });
                }),
              ],
            ),
          /*Row(
            children: <Widget>[
              CommonGroup(
                labelText: "PLANT",
                controller: _plantValue,
                focusNode: fnOne,
                onEditingComplete: ([result]) {
                  fnOne.unfocus();
                  FocusScope.of(context).requestFocus(fnTwo);
                },
              ),
              CommonGroup(
                labelText: "S.Loc",
                controller: _sLoc,
                focusNode: fnTwo,
                onEditingComplete: ([result]) {
                  fnTwo.unfocus();
                  FocusScope.of(context).requestFocus(fnThree);
                },
              ),

            ],
          ),
          Row(
            children: <Widget>[
              CommonText("Bin"),
              CommonLocation(
                selLocVal: _binValue,
                focusNode: fnThree,
                param: {'LOCATION_KIND': 'I'},
                onEditingComplete: ([result]) {
                },
              ),
            ],
          ),*/
        ],
      ),
    );
  }

}