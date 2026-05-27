import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonLocation.dart';
import 'package:dtwms_app/models/commonScanTextField.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/pages/stk/STK0003MP02.dart';

class STK0003MP01 extends StatefulWidget {

  const STK0003MP01({Key key, this.param}) : super(key: key);
  final dynamic param;
  @override
  _STK0003MP01 createState() => _STK0003MP01();
}

class _STK0003MP01 extends State<STK0003MP01> {
  //LOCATION_CD
  final TextEditingController _selLocVal         = TextEditingController();
  //BARCODE_CD
  final TextEditingController _selItemBarcode    = TextEditingController();


  //detail search list
  List<dynamic> _dtlSearch = [];

  //shpr_item list
  List<dynamic> _ItemList = [];
  dynamic _selItemId;

  //SHPR LIST
  List<dynamic> _ShprList = [];
  dynamic _selShprId;

  List<dynamic> _searchHeaderList = ['로케이션',['화주','품목'],['재고수량','실사수량'],['저장유무','반영유무'],['유통기한','패킹번호']];
  List<dynamic> _searchHeaderList2 =  ['LOCATION_NM',['SHPR_NM','SHPR_ITEM_NM'],['STOCK_QTY','CHECK_QTY'],['CHECK_STATUS','RESULT_STATUS'],['EXPIRE_DATE','PACK_ID']];

  //포커스 노드
  FocusNode fnOne;
  FocusNode fnTwo;

  _dtlsearch() async {
    Map<String, dynamic> paramMap = {
      "STOCK_CHECK_ID" : widget.param["STOCK_CHECK_ID"],
      "SHPR_CD" : _selShprId,
      "SHPR_ITEM_CD" : _selItemId,
      "LOCATION_CD"  : _selLocVal.text,
      "ITEM_BARCODE" : _selItemBarcode.text
    };
    _dtlSearch =  await transaction(context, "/stk0003/dtlsearch.do", paramMap);

    return _dtlSearch;
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    List<dynamic> rtnList =
    await transaction(context, "/stk0003/dtlsearch.do", param);

    if(CommonUtil.isEmpty(rtnList)){
      showInfoAlert(context, "재고조사가 완료되었습니다.확인하세요");
    }
    else {
      final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true,builder: (context) => STK0003MP02(param: param)));
      if (result != null && result) {
        _dtlsearch().then((data) =>
            setState(() {
              _dtlSearch = data;
              if (CommonUtil.isEmpty(_dtlSearch))
                _dtlSearch = [];
              else
                _dtlSearch = data;
            }));
      }
    }
  }

  @override
  void initState() {

    fnOne = FocusNode();
    fnTwo = FocusNode();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        shprItemInfo(context,  {'ALL_FLAG' : 'Y','SHPR_CD' : _selShprId}).then((data) =>  setState(() {
          _ItemList = data;
          if(CommonUtil.isEmpty(_ItemList))
            _selItemId = "";
          else
            _selItemId = _ItemList[0]['CODE'];
        }))
    );

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        shprInfo(context, {'ALL_FLAG' : 'Y'}).then((data) =>  setState(() {
          _ShprList = data;
          if(CommonUtil.isEmpty(_ShprList))
            _selShprId = "";
          else
            _selShprId = _ShprList[0]['CODE'];
        }))
    );

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _dtlsearch().then((data) =>  setState(() {
          _dtlSearch = data;
          if(CommonUtil.isEmpty(_dtlSearch))
            _dtlSearch = [];
          else
            _dtlSearch = data;
        }))
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
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "재고상세", true),
        body: Container(
          child: GestureDetector(
          onTap: (){
          CommonUtil.hideKeyboard();
          },
          child: Column(
            children: <Widget> [
              _searchField(),
              Expanded(child: CustomGrid(_searchHeaderList,_searchHeaderList2, _dtlSearch,
                onTap :  ([rowData, colVal]){
                  callNavi(context, rowData).then((data)  {
                    _dtlsearch();
                  });
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
              CommonText("로케이션"),
              CommonLocation(focusNode: fnOne, selLocVal: _selLocVal, onEditingComplete : (result) {
                fnOne.unfocus();
                _selItemBarcode.text = "";
                FocusScope.of(context).requestFocus(fnTwo);
                _dtlsearch();
              }, )
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("화주"),
              CommonDropdown(null,_selShprId, _ShprList, (id, code, name){
                setState(() {
                  _selShprId = code;
                  shprItemInfo(context, {'ALL_FLAG' : 'Y','SHPR_CD' : _selShprId}).then((value){
                    _selItemId = '';
                    _ItemList = value;
                    _dtlsearch();
                  });
                });
              }, width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목"),
              CommonDropdown(null,_selItemId, _ItemList, (id, code, name){
                setState(() {
                  _selItemId = code;
                  _dtlsearch();
                });
              }, width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("품목바코드"),
              CommonScanTextField(_selItemBarcode,
                    focusNode : fnTwo
                    , scanType: "PD"
                    , onEditingComplete : (result) {
                     _dtlsearch().then((data)  {
                      if(_dtlSearch.length == 1){

                        Map<String, dynamic> paramMap = {
                          "STOCK_CHECK_ID" : _dtlSearch[0]["STOCK_CHECK_ID"],
                          "SHPR_CD"        : _dtlSearch[0]["SHPR_CD"],
                          "SHPR_ITEM_CD"   : _dtlSearch[0]["SHPR_ITEM_CD"],
                          "LOCATION_CD"    : _dtlSearch[0]["LOCATION_CD"],
                          "ITEM_BARCODE"   : _selItemBarcode.text,
                          "BIZ_CD"         : _dtlSearch[0]["BIZ_CD"],
                          "STOCK_SEQ"      : _dtlSearch[0]["STOCK_SEQ"]
                        };

                        callNavi(context, paramMap).then((data)  {
                          _dtlsearch().then((data){
                            setState(() {});
                          });
                        });
                      }
                      else{
                        _dtlsearch().then((data){
                          setState(() {});
                        });
                      }
                    });
                  }

              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                width: 350,
                child: ElevatedButton(
                  child: Text("조회"),
                  onPressed: () {
                    _dtlsearch();
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}