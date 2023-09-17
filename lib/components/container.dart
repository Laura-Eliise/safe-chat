import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RoundedGradientContainer extends StatelessWidget {
  final Widget? _child;
  final LinearGradient _gradient;
  final Color _backgroundColor;
  final double _borderSize;
  final double _outerBorderRadius;
  final double _innerBorderRadius;

  const RoundedGradientContainer(
      {super.key,
      double borderSize = 5,
      double outerBorderRadius = 6.0 + 3,
      double innerBorderRadius = 6.0,
      LinearGradient? gradient,
      Color? backgroundColor,
      Widget? child})
      : _child = child,
        _borderSize = borderSize,
        _outerBorderRadius = outerBorderRadius,
        _innerBorderRadius = innerBorderRadius,
        _gradient = gradient ?? primeGradient,
        _backgroundColor = backgroundColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(_outerBorderRadius)),
          gradient: _gradient),
      child: Padding(
        padding: EdgeInsets.all(_borderSize),
        child: Container(
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(_innerBorderRadius)),
                color: _backgroundColor),
            child: _child),
      ),
    );
  }
}
