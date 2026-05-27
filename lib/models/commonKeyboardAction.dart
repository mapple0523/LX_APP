
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';

import 'commonTextField.dart';

class CommonKeyboardAction{

  static KeyboardActionsConfig BuildConfig(BuildContext context, List<String> name,List<FocusNode> focus,List<dynamic> function,[bool noBtnFlag]){

    List<KeyboardActionsItem> itemList = [] ;
    List<Widget Function(FocusNode)> buttonList = [];

    for(int i=0;i<name.length;i++){
      buttonList.add(
            (node){
          return GestureDetector(
            child: Container(
                child: CommonTextField(
                  name[i],
                  enabled: false,
                  width: MediaQuery.of(context).size.width / name.length,
                )
            ),
            onTap: (){
              function[i]();
            },
          );
        },
      );
    }

    for (int i = 0; i < focus.length; i++) {
      itemList.add(
          KeyboardActionsItem(
              focusNode: focus[i],
              displayArrows: false,
              toolbarButtons: buttonList
          )
      );
    };

    return KeyboardActionsConfig(
        keyboardActionsPlatform : KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        actions: itemList
    );
  }
}
