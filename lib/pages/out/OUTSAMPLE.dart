import 'dart:convert';
import 'dart:io';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:http_parser/http_parser.dart';

class OUTSAMPLE extends StatefulWidget {
  // 호출하는 화면에서 사진이미지 불러올수 있는 key 받아야 함
  const OUTSAMPLE({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _OUTSAMPLE createState() => _OUTSAMPLE();
}

class _OUTSAMPLE extends State<OUTSAMPLE> {

  File imageFile;
  List<dynamic> _fileList = [];

  final ImagePicker _picker = ImagePicker();

  int selectedIndex = -1;

  @override
  void initState() {
    print("initState");
    // 화면에서 사용할 요소 정의
    // file Id
    // DISPATCH_NO
    // OUT_NO

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _search();
      setState(() {

      });
    });

    super.initState();
  }

  Future<void> _search() async {
    debugPrint("_search start");
    Map<String, dynamic> paramMap = {
      // 임시 파라메터, 이미지 조회용 key입력받을것!!!
      "FILE_ID": "",
      "DISPATCH_NO" : "",
      "OUT_NO" : "",
      "SYS_TYPE": Constant.sysType,
    };

    List<dynamic> rtnList = await transaction(context, "common/getImageFileM.do", paramMap);
    _fileList.clear();
    for(int i= 0 ; i < rtnList.length; i++){
      dynamic fileInfo = {
        "URL" : "${Constant.serverUrl}/resources/img_temp/${rtnList[i]["FILE_MAME"]}",
        "FILE_ID" : rtnList[i]["FILE_ID"],
        "FILE_MAME" : rtnList[i]["FILE_MAME"],
        "FILE_SEQ" : rtnList[i]["FILE_SEQ"],
        "FILE_PATH" : rtnList[i]["FILE_PATH"],
        "INDEX" : i
      };
      _fileList.add(fileInfo);
    }

    selectedIndex = -1;
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
      resizeToAvoidBottomInset: false,
      appBar: pageAppBar(context, "사진촬영 테스트"),
      body: FooterLayout(
        footer: Row(
          children: [
            CommonActionBtn("사진촬영"
                , fontSize: 20
                , width: MediaQuery.of(context).size.width * 0.5 - 10
                , onPressed: () {
                  takePicture();
                }
            ),
            CommonActionBtn("삭제"
                , fontSize: 20
                , width: MediaQuery.of(context).size.width * 0.5 - 10
                , onPressed: () {
                  imageDelete();
                }
            )
          ],
        ),
        child: Container(
          child: GestureDetector(
            onTap: () {
              CommonUtil.hideKeyboard();
            },
            child: GridView.count(
              scrollDirection: Axis.vertical,
              crossAxisCount: 3,
              children: buildGridChildren(), //createGallery(),
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
            )
          ),
        ),
      ),
    );
  }

  List<Widget> buildGridChildren() {
    int numImg = _fileList.length;

    return List.generate(numImg, (index) {
      final bool isSelected = selectedIndex == index;

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
            print(selectedIndex);
          });
        },
        onLongPress: () {
          print('Container long press! ${index}');
        },
        onDoubleTap: (){
          print('Container double tap! ${index}');
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Color.fromRGBO(254, 169, 21, 1) : Colors.grey,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: SizedBox.expand(
            child: Image.network(
              _fileList[index]["URL"],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.hide_image),
            ),
          ),
        ),
      );
    });
  }

  Future<void> takePicture() async {
    final XFile pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // Zebra
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });

      uploadImage(imageFile);
    }
  }

  Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> uploadImage(File imageFile) async {

    String base64Image = await imageToBase64(imageFile);

    var uri = Uri.parse(Constant.serverUrl + Constant.serverPrefix + "common/uploadFileM.do"); // Tomcat URL

    Map<String, dynamic> param = {
      "fileName": imageFile.path.split('/').last,
      "contentType": "image/jpeg",
      "imageBase64": base64Image,
    };

    dynamic result = await imageTransaction(context, "common/uploadFileM.do", param);

    print("uploadImage result ************* \n${result} ");
    // 업로드 결과 받아서 처리할 것
    await _search();
    setState(() {});
  }

  Future<void> imageDelete() async {
    // 선택된 이미지가 없을 경우 삭제 불가
    if(selectedIndex == -1){
      showPushAlert(context, "파일삭제", "선택된 이미지가 없습니다.");
      return;
    }

    bool result = await confirmDialog(context, "파일삭제", "선택된 이미지를 삭제 하시겠습니까?");

    if (result == true) {
      Map<String, dynamic> paramMap = {
        // 임시 파라메터, 이미지 조회용 key입력받을것!!!
        "FILE_ID": _fileList[selectedIndex]["FILE_ID"],
        "FILE_MAME": _fileList[selectedIndex]["FILE_MAME"],
        "FILE_SEQ" : _fileList[selectedIndex]["FILE_SEQ"],
        "FILE_PATH" : _fileList[selectedIndex]["FILE_PATH"],
        "GROUP_ID" : "",
        "SYS_TYPE": Constant.sysType,
      };

      dynamic returnVal = await transaction(context, "common/deleteImageFileM.do", paramMap);

      String result = returnVal["RESULT"];
      if(result == "SUCCESS") {
        showPushAlert(context, "파일삭제", "선택한 파일이 삭제되었습니다. ");
        await _search();
        setState(() {});
      }else{
        showPushAlert(context, "파일삭제", "파일삭제 실패하였습니다.\n${returnVal["MESSAGE"]}");
      }
    }
  }
}
