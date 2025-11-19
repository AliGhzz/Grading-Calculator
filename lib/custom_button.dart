import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final color;
  final label;
  final textColor;
  final onTapped;
  final fontSize;
  const CustomButton({super.key, this.color,this.label,this.textColor,this.onTapped,this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          
        ),
        child: TextButton(
          onPressed: onTapped,
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Text(label,style: TextStyle(color: textColor,fontSize: fontSize),),
        ),
      ),
    );
  }
}