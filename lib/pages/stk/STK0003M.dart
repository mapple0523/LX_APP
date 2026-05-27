import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/commWidget.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:date_format/date_format.dart';
import 'package:dtwms_app/pages/stk/STK0003MP01.dart';

import 'STK0003MP01.dart';

class STK0003M extends StatefulWidget {

  @override
  _STK0003M createState() => _STK0003M();
}

class _STK0003M extends State<STK0003M>  {

  DateTime _schInDt = DateTime.now();
  final TextEditingController _selInDt    = TextEditingController();

  //포커스 노드
  FocusNode fnOne;
  FocusNode fnTwo;

  //SHPR LIST
  List<dynamic> _ShprList = [];
  dynamic _selShprId;

  //창고 LIST
  List<dynamic> _WarehouseList = [];
  dynamic _selWarehouseId ="";

  //ZONE LIST
  List<dynamic> _ZoneList = [];
  dynamic _selZoneId = "";


  List<dynamic> _searchHeaderList = ['화주',['재고조사유형','스케쥴'],['창고','ZONE']];
  List<dynamic> _searchHeaderList2 =  ['SHPR_NM',['CHECK_CATE_NM','SCH_INFO'],['WAREHOUSE_NM','ZONE_NM']];
  List<dynamic> _searchList = [];

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_W) {
      _selWarehouseId = code;
      _ZoneList = [];
      comboLocation(Constant.LOCATION_TYPE_Z, {'ALL_FLAG':'Y','LOCATION_TYPE' : Constant.LOCATION_TYPE_Z, 'UP_LOCATION_CD' : _selWarehouseId});

    }
    else if(id == Constant.LOCATION_TYPE_Z) {
      _selZoneId = code;
      comboLocation(Constant.LOCATION_TYPE_L, {'ALL_FLAG':'Y','LOCATION_TYPE' : Constant.LOCATION_TYPE_L, 'UP_LOCATION_CD' : _selZoneId});
    }
    else{
      shprInfo(context, {'ALL_FLAG' : 'Y'}).then((data) =>  setState(() {
        _ShprList = data;
        if(CommonUtil.isEmpty(_ShprList))
          _selShprId = "";
        else
          _selShprId = _ShprList[0]['CODE'];
      }));
      _search();
    }
  }

  void comboLocation(String type, dynamic param) {
    if(!CommonUtil.isNull(type)) {
      comboLocationList(context, param).then((data) {
        data = CommonUtil.emptyListDef(data);

        if(type == Constant.LOCATION_TYPE_W) {
          _WarehouseList = data;
          if (CommonUtil.isEmpty(_WarehouseList))
            _selWarehouseId = "";
          else
            _selWarehouseId = _WarehouseList[0]["CODE"];

          comboCallback(Constant.LOCATION_TYPE_W, _selWarehouseId, null);
        }
        else if(type == Constant.LOCATION_TYPE_Z) {
          _ZoneList = data;
          if(CommonUtil.isEmpty(_ZoneList))
            _selZoneId = "";
          else
            _selZoneId = _ZoneList[0]["CODE"];

          comboCallback(Constant.LOCATION_TYPE_Z, _selZoneId, null);
        }
        else{
          shprInfo(context, {'ALL_FLAG' : 'Y'}).then((data) =>  setState(() {
            _ShprList = data;
            if(CommonUtil.isEmpty(_ShprList))
              _selShprId = "";
            else
              _selShprId = _ShprList[0]['CODE'];
          }));
          _search();
        }
      });
    }

    setState(() {});
  }

  _search() async {

    Map<String, dynamic> paramMap = {
      "SHPR_CD" : _selShprId,
      "WAREHOUSE_CD" : _selWarehouseId,
      "ZONE_CD" : _selZoneId,
      "PLAN_DT" : CommonUtil.removeDash(_selInDt.text)
    };
      _searchList = await transaction(context, "/stk0003/search.do", paramMap, (status, data){
        _searchList = data;
      });

    setState(() {
    });
  }

  Future<dynamic> callNavi(BuildContext context, [dynamic param]) async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0003MP01(param: param)));

    if(result != null && result){
      _search();
    }
  }

  @override
  void initState() {
    //포커스 인스턴스 저장
    fnOne = FocusNode();
    fnTwo = FocusNode();

    _selInDt.text = formatDate(_schInDt, [yyyy, '-', mm, '-', dd]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //창고 조회.
      comboLocation(Constant.LOCATION_TYPE_W, {'LOCATION_TYPE' : Constant.LOCATION_TYPE_W, 'UP_LOCATION_CD' : 'root'});
    });


    //비동기로 flutter secure storage 정보를 불러오는 작업. 화주
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
        FocusScope.of(context).requestFocus(fnOne)
    );
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _search()
    );

    super.initState();
  }

  @override
  void dispose() {
    //포커스 dispose
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    var color = 0xff453658;
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "재고조사"),
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
              Expanded(child: CustomGrid(_searchHeaderList,_searchHeaderList2, _searchList,
                  onTap :  ([rowData, colVal]){
                  callNavi(context, rowData).then((data)  {
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
              CommonText("재고조사일자"),
              CommonTextField(_selInDt,
                  enabled : false,
                  width : 190),
              IconButton(padding:EdgeInsets.only(left: 5), constraints: BoxConstraints(), icon: Icon(Icons.calendar_today), onPressed: (){
                Future<DateTime> selectedDate = commonDatePicker(context, _schInDt);
                selectedDate.then((dateTime) {
                  setState(() {
                    _selInDt.text = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                  });
                });
              })
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("창고"),
              CommonDropdown("W", _selWarehouseId, _WarehouseList, comboCallback,
                  width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("ZONE"),
              CommonDropdown("Z", _selZoneId, _ZoneList, comboCallback,
                  width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("화주"),
              CommonDropdown(null,_selShprId, _ShprList, (id, code, name){
                setState(() {
                  _selShprId = code;
                  _search();
                });
              }, width : 225),
            ],
          ),
        ],
      ),
    );
  }
}
