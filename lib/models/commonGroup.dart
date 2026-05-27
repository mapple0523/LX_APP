import 'package:dtwms_app/models/commonTextField.dart';
import 'package:flutter/material.dart';

// import 'commonInputBox.dart';
// import 'commonSmallText.dart';
import 'commonText.dart';

class CommonGroup extends StatelessWidget {
  final String labelText;
  final TextEditingController textValue = TextEditingController();
  final TextEditingController controller;
  final bool enabled;
  final FocusNode focusNode;
  final Function() onEditingComplete;

  CommonGroup({
    this.labelText,
    this.controller,
    this.focusNode,
    this.onEditingComplete,
    this.enabled = true
  });

  @override
  void dispose() {
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
           // flex:0.4,
            child: CommonText(labelText),
          ),
          Expanded(
           // flex:0.4
            child: CommonTextField(textValue,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
            ),
          ),

          // Container(
          //   child: CommonText(labelText, width: 78,),
          // ),
          // Container(
          //   child: CommonTextField(controller,
          //     // enabled: false,
          //     width: 93,
          //     focusNode: focusNode,
          //     onEditingComplete: onEditingComplete,
          //   ),
          // ),

        ],
      ),
    );
  }
}
