import 'package:flutter/material.dart';
import 'package:binarylabs/common/common.dart';
import 'package:binarylabs/common/components.dart';
import 'package:binarylabs/config/assets.dart';

class RegisterInputWidget extends StatefulWidget {
  final Function(String data) setData;
  final bool isNumber;
  final String title;
  const RegisterInputWidget( this.setData, this.isNumber, this.title, {super.key});

  @override
  State<RegisterInputWidget> createState() => RegisterInputWidgetState();
}

class RegisterInputWidgetState extends State<RegisterInputWidget> {

  TextEditingController controller = TextEditingController();
  FocusNode node = FocusNode();

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        child: input(
          controller, 
          node, 
          widget.title, 
          isNumber: widget.isNumber, 
          onChange: (d){
            widget.setData(controller.text.trim());
          },
          iconPathLeft: AppAssets.infoCircleSvg,
          leftIconSize: 14,
        ),
      ),
    );
  }
}