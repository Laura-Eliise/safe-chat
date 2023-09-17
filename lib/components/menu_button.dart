import 'package:flutter/material.dart';

import '../utils/colors.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({
    super.key,
    required this.title,
    required this.pressed,
    required this.switchButtons,
  });

  final String title;
  final bool pressed;
  final void Function(String) switchButtons;
  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  void initState() {
    super.initState();
  }

  void onPressed() {
    widget.switchButtons(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: const ButtonStyle(
          overlayColor: MaterialStatePropertyAll(Colors.transparent),
        ),
        onPressed: onPressed,
        child: Container(
          alignment: Alignment.center,
          width: 130,
          decoration: !widget.pressed
              ? BoxDecoration(
                  color: primeColorTrans,
                  borderRadius: BorderRadius.circular(12.0))
              : BoxDecoration(
                  gradient: primeGradient,
                  borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 13.5),
            child: Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
          ),
        ));
  }
}
