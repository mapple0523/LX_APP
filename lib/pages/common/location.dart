
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/commonTextField.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/textMaker.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _LocationPage createState() => _LocationPage();
}

class _LocationPage extends State<LocationPage>  {
  dynamic _wSelLocVal  = "";
  dynamic _zSelLocVal  = "";
  dynamic _selLocVal   = "";
  dynamic _selLocNm   = "";
  List<dynamic> _wlocationList = [];    //창고 목록
  List<dynamic> _zlocationList = [];    //zone 목록
  List<dynamic> _locationList  = [];     //location 목록
  List<dynamic> _locDetailInfo  = [{}];     //location 상세정보
  List<dynamic> _locShprInfo    = [{}];     //location 화주정보

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_W) {
      _wSelLocVal = code;
      _zlocationList = [];
      _locationList = [];
      comboLocation(Constant.LOCATION_TYPE_Z, {'LOCATION_TYPE' : Constant.LOCATION_TYPE_Z, 'UP_LOCATION_CD' : CommonUtil.isNull(_wSelLocVal) ? "-" : _wSelLocVal , 'LOCATION_KIND' : CommonUtil.findValueFromMap(widget.param, "LOCATION_KIND")});
    }
    else if(id == Constant.LOCATION_TYPE_Z) {
      _zSelLocVal = code;
      _locationList = [];
      comboLocation(Constant.LOCATION_TYPE_L, {'LOCATION_TYPE' : Constant.LOCATION_TYPE_L, 'UP_LOCATION_CD' : CommonUtil.isNull(_zSelLocVal) ? "-" : _zSelLocVal, 'LOCATION_KIND' : CommonUtil.findValueFromMap(widget.param, "LOCATION_KIND")});
    }
    else if(id == Constant.LOCATION_TYPE_L) {
      _selLocVal = code;
      _selLocNm  = name;
      //await schLocationDetailInfo();

      comboLocation(null, null);
    }
  }

  void comboLocation(String type, dynamic param) {
    if(!CommonUtil.isNull(type)) {
      comboLocationList(context, param).then((data) {
        data = CommonUtil.emptyListDef(data);

        if(type == Constant.LOCATION_TYPE_W) {
          _wlocationList = data;
          if(CommonUtil.isEmpty(_wlocationList)) _wSelLocVal = "";
          else _wSelLocVal = _wlocationList[0]["CODE"];

          comboCallback(Constant.LOCATION_TYPE_W, _wSelLocVal, null);
        }
        else if(type == Constant.LOCATION_TYPE_Z) {
          _zlocationList = data;
          if(CommonUtil.isEmpty(_zlocationList)) _zSelLocVal = "";
          else _zSelLocVal = _zlocationList[0]["CODE"];

          comboCallback(Constant.LOCATION_TYPE_Z, _zSelLocVal, null);
        }
        else if(type == Constant.LOCATION_TYPE_L) {
          _locationList = data;
          if(CommonUtil.isEmpty(_locationList)) {
            _selLocVal = "";
            _selLocNm = "";
          }
          else {
            _selLocVal = _locationList[0]["CODE"];
            _selLocNm = _locationList[0]["NAME"];
          }

          comboCallback(Constant.LOCATION_TYPE_L, _selLocVal, _selLocNm);
        }
      });
    }

    setState(() {});
  }

  void schLocationDetailInfo() async{
    if(CommonUtil.isNull(_selLocVal)) {
      _locDetailInfo = [{}];
      _locShprInfo = [{}];
    } else {
      await locationDetailInfo(context, {'LOCATION_CD' : _selLocVal}).then((data) {
        if(CommonUtil.isEmpty(data)) {
          _locDetailInfo = [{}];
          _locShprInfo = [{}];
        } else {
          _locDetailInfo = CommonUtil.emptyListDef(data['LOC_DEATIL']);
          _locShprInfo = CommonUtil.emptyListDef(data['LOC_SHPR']);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //창고 조회.
      comboLocation(Constant.LOCATION_TYPE_W, {'LOCATION_TYPE' : Constant.LOCATION_TYPE_W, 'UP_LOCATION_CD' : 'root'});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "selectLocation"),
        body: Container(
          child: Column(
            children: <Widget> [
              _searchField(),
              /*
              Expanded(
                  child: CustomGrid( ['화주', '품목', ['유효기간', '패킹ID']], ['SHPR_NM', 'SHPR_ITEM_NM', ['EXPIRE_DATE', 'PACK_ID']], _locShprInfo)
              ),
               */
              CommonActionBtn("btnSelect",
                onPressed: () {
                  Navigator.pop(context, {'LOCATION_CD' : _selLocVal, 'LOCATION_NM' : _selLocNm});
                }
              ),
              widgetCopyRight(),
            ],
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
              CommonText("warehouse"),
              CommonDropdown("W", _wSelLocVal, _wlocationList, comboCallback, width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("zone"),
              CommonDropdown("Z", _zSelLocVal, _zlocationList, comboCallback, width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("location"),
              CommonDropdown("L", _selLocVal, _locationList, comboCallback, width : 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("type"),
              CommonTextField(_locDetailInfo[0]['LOCATION_TYPE_NM'],enabled : false, width: 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("stockType"),
              CommonTextField(_locDetailInfo[0]['LOCATION_ATTR_NM'],enabled : false, width: 225),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("stockTypeProperty"),
              CommonTextField(_locDetailInfo[0]['LOCATION_ATTR_RMK'],enabled : false, width: 225 ),
            ],
          ),
          Row(
            children: <Widget>[
              CommonText("priority"),
              CommonTextField(CommonUtil.nullStrDef(_locDetailInfo[0]['ORDER_NUM'].toString()), enabled : false, width: 225 ),
            ],
          ),
        ],
      ),
    );
  }
}