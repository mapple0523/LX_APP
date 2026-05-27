
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/commonGrid.dart';
import 'package:dtwms_app/models/commonText.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _ZonePage createState() => _ZonePage();
}

class _ZonePage extends State<ZonePage>  {
  dynamic _wSelLocVal  = "";
  dynamic _zSelLocVal  = "";
  dynamic _zSelLocNm  = "";
  List<dynamic> _wlocationList = [];    //창고 목록
  List<dynamic> _zlocationList = [];    //zone 목록
  List<dynamic> _locationList  = [];     //location 목록

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    if(id == Constant.LOCATION_TYPE_W) {
      _wSelLocVal = code;
      _zlocationList = [];
      comboLocation(Constant.LOCATION_TYPE_Z, {'LOCATION_TYPE' : Constant.LOCATION_TYPE_Z, 'UP_LOCATION_CD' : _wSelLocVal, 'LOCATION_KIND' : CommonUtil.findValueFromMap(widget.param, "LOCATION_KIND")});
    }
    else if(id == Constant.LOCATION_TYPE_Z) {
      _zSelLocVal = code;
      _zSelLocNm = name;
      await schLocationList();

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
          if(CommonUtil.isEmpty(_zlocationList)) {
            _zSelLocVal = "";
            _zSelLocNm = "";
          }
          else {
            _zSelLocVal = _zlocationList[0]["CODE"];
            _zSelLocNm = _zlocationList[0]["NAME"];

            comboCallback(Constant.LOCATION_TYPE_Z, _zSelLocVal, _zSelLocNm);
          }
        }
      });
    }

    setState(() {});
  }

  void schLocationList() async {
    if(CommonUtil.isNull(_zSelLocVal)) {
      _locationList = [];
    } else {
      dynamic param = {'LOCATION_TYPE' : Constant.LOCATION_TYPE_L, 'UP_LOCATION_CD' : _zSelLocVal, 'LOCATION_KIND' : CommonUtil.findValueFromMap(widget.param, "LOCATION_KIND")};
      await comboLocationList(context, param).then((data) {
        if(CommonUtil.isEmpty(data)) {
          _locationList = [];
        } else {
          _locationList = data;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
              Expanded(
                  child: CommonGrid( ['LOCATION'], ['NAME'], _locationList)
              ),
              Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: 150,
                          width: MediaQuery.of(context).size.width - 10,
                          child: ElevatedButton(
                            child: Text("선 택", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),),
                            onPressed: () {
                              Navigator.pop(context, {'LOCATION_CD' : _zSelLocVal, 'LOCATION_NM' : _zSelLocNm});
                            },
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ],
          ),
        )
    );
  }
}