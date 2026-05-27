
class Constant {
  static const int resSuccessCode = 200;
  static const int tokenFailCode = 588;
  static const int resErrorCode = -999;
  static const int tokenValidFailCode = 688;
  static const String rtnStatus = "status";
  static const String rtnMssage = "msg";
  static const String rtnData = "data";
  static const String authTokenNm = "authToken";
  static const String refreshTokenNm = "refreshToken";
  static const String sysFlagNm = "MOBILE_FLAG";
  static const String sysType = "M";
  static const String serverUrl = "http://192.168.10.188:8081"; //local url
  //static const String serverUrl = "http://192.168.10.175:8080"; //local url
  //static const String serverUrl = "http://192.168.10.172:8080"; //손차장님 url
  //static const String serverUrl = "http://192.168.10.187:8081"; //local url
  //static const String serverUrl = "http://172.16.10.190:8080";
  //static const String serverUrl = "https://wms.lxmma.com";
  //static const String serverUrl = "http://52.78.172.230:8080/";
  static const String serverPrefix = "/restful/";
  static const String appUpdatePrefix = "/app/lxmma_wms.apk"; //update url
  static const String appUpdateName = "lxmma_wms.apk"; //update file name
  //static const String serverUrl = "http://10.52.31.168:8080"; //개발서버
  //static const String serverUrl = "http://10.56.80.26"; //운영서버
  static const String appTitle = "WMS SYSTEM";
  static const String copyRight = "Copyright＠2021 DOOTAIT Co., Ltd. All rights reserved.";
  static const String sotrageTokenKey = "AUTH_TOKEN";
  static const String sotrageRefreshTokenKey = "REFRESH_TOKEN";
  static const String sotrageAutoFlagKey = "LOGIN_AUTO";

  //로케이션 유형 상수
  static const String LOCATION_TYPE_W = "W";
  static const String LOCATION_TYPE_Z = "Z";
  static const String LOCATION_TYPE_L = "L";

  static const String BIN_BARCODE_DELIMIT = "*L*";
}