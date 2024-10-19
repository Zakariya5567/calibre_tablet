//WIDGET EXTENSION
import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  // OnPress
  Widget onPress(VoidCallback onTap) => InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: this);

  // CENTER
  Widget get center => Center(
        child: this,
      );

  // CENTER RIGHT
  Widget get centerRight => Align(
        alignment: Alignment.centerRight,
        child: this,
      );
  
  // CENTER LEFT
  Widget get centerLeft => Align(
        alignment: Alignment.centerLeft,
        child: this,
      );

  // EXPANDED
  Widget get expanded => Expanded(
        child: this,
      );

  //ALIGN
  Widget align(Alignment alignment) => Align(alignment: alignment, child: this);

  //BASELINE

  Widget baseline(double width) => Baseline(
        baseline: width,
        baselineType: TextBaseline.alphabetic,
        child: this,
      );

  //BASELINE

  Widget rotate(int degree) => RotatedBox(
        quarterTurns: degree,
        child: this,
      );

}
