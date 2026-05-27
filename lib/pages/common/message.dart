import 'package:another_flushbar/flushbar.dart';
import 'package:dtwms_app/pages/sys/Language_constants.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";

void showErrorAlert(BuildContext context, String content) {
  showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: <Widget>[
            Icon(Icons.error),
            SizedBox(
              width: 10,
            ),
            Text("Error Message"),
          ]),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}

Future<bool> showInfoAlert(BuildContext context, String content) async {

  //if(CommonUtil.flushbarOpenFlag) return false;

  CommonUtil.flushbarOpenFlag = true;

  showFlushbar(context, content);

  CommonUtil.flushbarOpenFlag = false;

  return true;
}

Future<bool> showInfoAlert_pda(BuildContext context, String content) async {

  //if(CommonUtil.flushbarOpenFlag) return false;

  String translatedContent = getTranslated(context, content);

  CommonUtil.flushbarOpenFlag = true;

  showFlushbar(context, translatedContent);

  CommonUtil.flushbarOpenFlag = false;

  return true;
}

Future<bool> showInfoAlertSync(BuildContext context, String content) async {

  if(CommonUtil.flushbarOpenFlag != null && CommonUtil.flushbarOpenFlag) return false;

  CommonUtil.flushbarOpenFlag = true;

  await showFlushbar(context, content);

  CommonUtil.flushbarOpenFlag = false;
  return true;
}

Future<dynamic> showFlushbar(BuildContext context, String content) async {
  return Flushbar(
    title: "Message",
    message: content,
    flushbarPosition: FlushbarPosition.TOP,
    duration: Duration(milliseconds: 2000),
    flushbarStyle: FlushbarStyle.FLOATING,
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    margin: EdgeInsets.all(8),
    isDismissible: true,
    icon: Icon(
      Icons.info_outline,
      size: 28.0,
      color: Color.fromRGBO(254, 169, 21, 1),
    ),
    leftBarIndicatorColor: Color.fromRGBO(254, 169, 21, 1),
    onStatusChanged: (status) {
      if(status == FlushbarStatus.DISMISSED) {
        CommonUtil.flushbarOpenFlag = false;
      }
    },
    onTap: (flushbar) {
      flushbar.dismiss();
    },
  ).show(context);
}

Future<bool> showInfoAlert_bak(BuildContext context, String content) async {
  bool rtnVal = false;
  await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: <Widget>[
            Icon(Icons.info),
            SizedBox(
              width: 10,
            ),
            Text("Information"),
          ]),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      }).then((val) {
          rtnVal = val;
      });
  return rtnVal;
}

showLoadingAlert(BuildContext context) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
                backgroundColor: Colors.black54,
                children: <Widget>[
                  Center(
                    child: Column(
                        children: [
                          CircularProgressIndicator(
                            backgroundColor: Color.fromRGBO(254, 169, 21, 1),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                          ),
                          Text(
                            "Please Wait....",
                            style: TextStyle(color: Color.fromRGBO(254, 169, 21, 1))
                            // style: TextStyle(color: Colors.blueAccent),
                          ),
                        ]),
                  )
                ]));
      });
}

void hideLoadingAlert(BuildContext context) {
  Navigator.pop(context); //close the dialoge
}

void showPushAlert(BuildContext context, String title, String content) {
  showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: <Widget>[
            Icon(Icons.info),
            SizedBox(
              width: 10,
            ),
            Text(title),
          ]),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK",
                style: TextStyle(
                  color: Color.fromRGBO(254, 169, 21, 1)
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      });
}
Future<bool> confirmDialog(BuildContext context, String title, String content) async {
  bool rtnVal = false;
  if(title == null || title.length == 0) title = "Confirm Popup";
  await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("OK",
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            CupertinoDialogAction(
              child: Text("CANCEL",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      }).then((val) {
    rtnVal = val;
  });
  return rtnVal;
}

Future<bool> confirmDialogList(BuildContext context, String title, String content, List<dynamic> list) async {
  bool rtnVal = false;
  if(title == null || title.length == 0) title = "Confirm Popup";
  await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Container(
            child: Column(
              children: [
                Text(content, textAlign: TextAlign.left,),
                Column(
                  children: list.map<Widget>((value) {
                    return Text(
                      value["PACK_ID"],
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.visible,
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("OK",
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            CupertinoDialogAction(
              child: Text("CANCEL",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      }).then((val) {
    rtnVal = val;
  });
  return rtnVal;
}

/*
Future<bool> confirmDialog(BuildContext context, String title, String content) async {
  bool rtnVal = false;
  if(title == null || title.length == 0) title = "Confirm Popup";
  await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: <Widget>[
            Icon(Icons.info),
            SizedBox(
              width: 10,
            ),
            Text(title),
          ]),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            ElevatedButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      }).then((val) {
    rtnVal = val;
  });
  return rtnVal;
}
*/