import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/constants/pageConstant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<dynamic> _menuList = [];
  List<dynamic> _searchList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      menuInfo(context, {}).then((data) => setState(() {
        _menuList = data;
      }));

      comCodeInfo(context, {"MASTER_CD": "SCAN_TYPE"}).then((data) {
        ZebraDataWedgeListener.scanType = data;
      });
    });
  }

  Future<void> _searchBizInfo() async {
    _searchList = [];

    Map<String, dynamic> param = {
      "CHK_SESS_BIZ_CD" : 'Y'
    };
    List<dynamic> rtnList =
    await transaction(context, "common/getUserBizInfo.do", param);

    if (CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    setState(() {});

    // 데이터 로딩 후 다이얼로그 표시
    _showBizDialog();
  }

  Future<void> _changeBizInfo(String bizCd) async {

    if (bizCd.isEmpty) {
      showInfoAlert_pda(context, "사업장을 선택해주세요.");
      return;
    }

    Map<String, dynamic> param = {
      "SYS_TYPE": 'M',
      "BIZ_CD": bizCd
    };

    await transaction(context, "common/changeBizInfo.do", param, (status, data) async {
      print("===== status: $status / data: $data");

      if (data != null && data[Constant.authTokenNm] != null) {
        final storage = FlutterSecureStorage();
        await storage.write(key: Constant.sotrageTokenKey, value: data[Constant.authTokenNm]);
        print("새 토큰 저장 완료");
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        PageConstant.routeNameMenu,
            (route) => false,
      );
    });
  }

  void _showBizDialog() {
    // 다이얼로그 내부에서 상태 관리를 위해 로컬 리스트 복사
    List<dynamic> dialogList = List.from(_searchList);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                "사업장 선택",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 테이블 헤더
                    Container(
                      color: Color.fromRGBO(34, 38, 41, 1),
                      child: Row(
                        children: [
                          _headerCell("사업장 코드", flex: 3),
                          _headerCell("사업장", flex: 4),
                          _headerCell("적용여부", flex: 2),
                        ],
                      ),
                    ),
                    // 테이블 바디
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: dialogList.isEmpty
                          ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("데이터가 없습니다."),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        itemCount: dialogList.length,
                        itemBuilder: (context, index) {
                          final item = dialogList[index];
                          final bool isChecked =
                              item['BIZ_CHK'].toString() == '1';

                          return Container(
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? Color.fromRGBO(254, 169, 21, 0.15)
                                  : Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              children: [
                                // 사업장 코드
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    child: Text(
                                      item['BIZ_CD']?.toString() ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isChecked
                                            ? Color.fromRGBO(
                                            254, 169, 21, 1)
                                            : Colors.black87,
                                        fontWeight: isChecked
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                // 구분선
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.shade200),
                                // 사업장명
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    child: Text(
                                      item['BIZ_NM']?.toString() ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                // 구분선
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.shade200),
                                // 체크박스
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Checkbox(
                                      value: isChecked,
                                      activeColor: Color.fromRGBO(
                                          254, 169, 21, 1),
                                      onChanged: (bool value) {
                                        setDialogState(() {
                                          // 기존 선택 해제 후 현재 항목만 선택 (단일 선택)
                                          for (var d in dialogList) {
                                            d['BIZ_CHK'] = 0;
                                          }
                                          dialogList[index]['BIZ_CHK'] =
                                          value == true ? 1 : 0;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("취소", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(254, 169, 21, 1),
                  ),
                  onPressed: () {
                    final selected = dialogList.firstWhere(
                          (item) => item['BIZ_CHK'].toString() == '1',
                      orElse: () => null,
                    );

                    Navigator.pop(dialogContext); // 다이얼로그 먼저 닫기

                    if (selected != null) {
                      print(selected);
                      _changeBizInfo(selected['BIZ_CD'].toString()); // 변경 API 호출
                    }
                  },
                  child: Text("확인",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 헤더 셀 위젯
  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: defaultAppBar(
          context,
          "menu",
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                _searchBizInfo(); // 데이터 조회 후 다이얼로그 자동 표시
              },
            ),
          ],
        ),
        body: GridView.count(
          childAspectRatio: 1.41,
          padding: EdgeInsets.all(15),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _menuList.map((data) {
            return Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(254, 169, 21, 1),
                  borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onHover: (value) {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(data['MENU_NM'],
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white)),
                  ],
                ),
                onTap: () {
                  pageMove(context, data['MENU_URL']);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}