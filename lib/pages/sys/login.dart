
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/constants/imageConstant.dart';
import 'package:dtwms_app/commons/constants/pageConstant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/textMaker.dart';
import 'package:dtwms_app/pages/sys/function.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dtwms_app/models/commonDropdown.dart';
import 'package:dtwms_app/models/restfulReq.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import 'Language_constants.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage>  {
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final Color fillColor = Color.fromARGB(030, 255,255,255);
  final Color textColor = Colors.white;
  final EdgeInsets teextPadding = EdgeInsets.only(left: 20, right: 20);
  final FocusNode _node = FocusNode();

  final _storage = FlutterSecureStorage();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loginAuto = false;    //자동 로그인

  dynamic _bizVal  = "";
  dynamic _language  = "";
  List<dynamic> _bizList = [];
  List<dynamic> _languageList = [{"CODE" : "ko", "NAME" : "한국어"},{"CODE" : "en", "NAME" : "영어"},{"CODE" : "zh", "NAME" : "중국어"}];
  Map<String, dynamic> _deviceMap = {};

  Future<void> comboCallback(String id, dynamic code, dynamic name) async {
    _bizVal = code;
    comboBiz(null);
  }
  Future<void> languageCallback(String id, dynamic code, dynamic name) async {
    _language = code;
    Locale _locale = await setLocale(_language);
    MyApp.setLocale(context, _locale);
    comboLanguage(null);
  }

  Future<void> _getLoginUserBizList() async {
    Map<String, dynamic> paramMap = {
      "LOGIN_ID": _usernameController.text,
      "SYS_TYPE": Constant.sysType,
    };

    print(paramMap);

    List<dynamic> rtnList = await transaction(context, "getLoginUserBizList.do", paramMap);
    _bizList = CommonUtil.emptyListDef(rtnList);
    print(_bizList);
    _bizVal = _bizList[0]['CODE'];

    setState(() {});
  }

  void comboBiz(String type) {
    if(!CommonUtil.isNull(type)) {
      comBizInfo(context).then((data) {
        data = CommonUtil.emptyListDef(data);
        _bizList = data;
        _bizVal = _bizList[0]['CODE'];

        comboCallback(type, _bizVal, null);
      });
    }
    setState(() {});
  }
  void comboLanguage(String type) {
    if(!CommonUtil.isNull(type)) {
        _language = _languageList[0]['CODE'];
        languageCallback(type, _language, null);
    }
    setState(() {});
  }

  void _value1Changed(bool value) => setState(() => _loginAuto = value);

  _login() async {

    Map<String, dynamic> paramMap = {
      "LOGIN_ID": _usernameController.text,
      "LOGIN_PW": _passwordController.text,
      "SYS_TYPE": Constant.sysType,
      "BIZ_CD": _bizVal,
    };
    paramMap.addAll(_deviceMap);

    print("***************** paramMap ${paramMap}");

    await transaction(context, "checkLoginM.do", paramMap, (status, data) async {
      if(status == Constant.resSuccessCode) {
        _storage.write(key: Constant.sotrageTokenKey, value: data[Constant.authTokenNm]);

        // ID/PW 저장 추가
        _storage.write(key: "LOGIN_ID", value: _usernameController.text);
        _storage.write(key: "LOGIN_PW", value: _passwordController.text);

        if(_loginAuto)
          _storage.write(key: Constant.sotrageAutoFlagKey, value: _loginAuto.toString());
        else
          _storage.write(key: Constant.sotrageAutoFlagKey, value: _loginAuto.toString());
        App_Function.LOGIN_USER_INFO = data;
        Navigator.pushNamed(context, PageConstant.routeNameMenu);
      }else if (status == -100) {
        bool result = await confirmDialog(context, "확인", "등록되지 않은 디바이스입니다. 디바이스를 등록하시겠습니까?");
        if (result) {
          await transaction(context, "mobileRegisterDevice.do", paramMap, (status, responseData) {
            print("================= responseData ${responseData}");
            if (status == Constant.resSuccessCode) {
              showInfoAlert_pda(context, "디바이스가 등록되었습니다. 관리자 승인 완료 후 사용 가능합니다.");
            }
          });
        }
      }
      else {
        _storage.delete(key: Constant.sotrageTokenKey);
      }
    });
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    CommonUtil.appVersion = packageInfo.version; // 버전정보 저장
    Map<String, dynamic> data = {};

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;

      print(android.androidId); // Android ID
      print(android.host);
      data = {
        "PLATFORM": "android",
        "DEVICE": android.model,
        "BRAND": android.brand,
        "SYSTEM_VERSION": android.version.release,
        "SDK_INT": android.version.sdkInt,
        "APP_VERSION": packageInfo.version,
        "BUILD_NUMBER": packageInfo.buildNumber,
        "DEVICE_ID" : android.androidId,
      };
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      data = {
        "PLATFORM": "ios",
        "DEVICE": ios.utsname.machine,
        "SYSTEM_VERSION": ios.systemVersion,
        "APP_VERSION": packageInfo.version,
        "BUILD_NUMBER": packageInfo.buildNumber,
      };
    }

    return data;
  }


  /*void firebaseCloudMessagingListeners()  {

    _firebaseMessaging.getToken().then((token){
      print('token:'+token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }*/

  @override
  void initState() {
    print("login");
    super.initState();
    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) => _asyncMethod());

    //firebaseCloudMessagingListeners();
    _node.addListener(() async {
      if(!_node.hasFocus){
       print("focus out");
       await _getLoginUserBizList();
      }

      setState(() {});
    });
  }

  _asyncMethod() async {
    comboBiz('BIZ');
    comboLanguage('LAN');
    _deviceMap = await getDeviceInfo();
    print(_deviceMap);
    _loginAuto = ConvertUtil.convertBoolean(await _storage.read(key: Constant.sotrageAutoFlagKey));

    String savedId = await _storage.read(key: "LOGIN_ID");
    String savedPw = await _storage.read(key: "LOGIN_PW");

    if (!CommonUtil.isNull(savedId)) {

      _usernameController.text = savedId;
      _passwordController.text = savedPw ?? '';

      await _getLoginUserBizList();

      setState(() {

      });
    }

    if (_loginAuto) _login();
    else {
      _storage.delete(key: Constant.sotrageTokenKey);
    }
  }

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("device_id");

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString("device_id", id);
    }

    return id;
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstant.loginBgImg),
            fit: BoxFit.cover,
          )
        ),
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //logo
              widgetAppTitleAndLogo(),
              //id,pw edit box
              Column(
                children: [
                  Padding(
                    padding: this.teextPadding,
                    child: TextField(
                      cursorColor: Colors.white,
                      controller: _usernameController,
                      focusNode: _node,
                      decoration: InputDecoration(
                          filled: true
                          , labelText: "User ID"
                          , fillColor: this.fillColor
                          , labelStyle: TextStyle(color: this.textColor)
                          , focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                          )
                      ),
                      style: TextStyle(
                          color: this.textColor
                      ),
                    ),
                  ),
                  Padding(
                    padding: this.teextPadding,
                    child:  TextField(
                      cursorColor: Colors.white,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          filled: true
                          , labelText: "Password"
                          , fillColor: this.fillColor
                          , labelStyle: TextStyle(color: this.textColor)
                          , focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          )
                      ),
                      style: TextStyle(
                          color: this.textColor
                      ),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: this.teextPadding,
                    child: CommonDropdown("BIZ", _bizVal, _bizList, comboCallback, width : 350, decoColor: this.fillColor, textColor: Colors.white
                      , dropdownColor: Color.fromARGB(100, 255,255,255),
                    ),
                  ),
                  Padding(
                    padding: this.teextPadding,
                    child: CommonDropdown("LAN", _language, _languageList, languageCallback, width : 350, decoColor: this.fillColor, textColor: Colors.white
                      , dropdownColor: Color.fromARGB(100, 255,255,255),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 5, left: 20)
                      , child: Row(
                            children: [
                              Text('자동로그인'
                                , style: TextStyle(
                                    color: this.textColor
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2)
                                  //color: Colors.white
                                ),
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                    value: _loginAuto
                                    , onChanged: _value1Changed
                                    , checkColor: Color.fromARGB(255, 254, 169, 21)
                                    , activeColor: this.fillColor,
                                ),
                              ),
                            ],
                      )
                  ),
                ],
              ),
              //로그인 버튼
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 100,
                child: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(this.teextPadding),
                      backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 254, 169, 21))
                  ),
                  child: Text("로그인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                  onPressed: () {
                    _login();
                  },
                ),
              ),
              Column(children: [
                Text("Ver.${_deviceMap["APP_VERSION"]}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                widgetCopyRight(),
              ],)

            ],
          ),
        ),
      ),
    );
  }
}