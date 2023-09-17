import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RoundScaffold extends StatelessWidget {
  final Widget? child;
  final String? title;
  final double rounding;


  const RoundScaffold(
      {Key? key, this.title, required this.rounding, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBar ?? CustomAppBar(title: title),
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
            width: MediaQuery.of(context).size.width + 200,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [primeColor, secondaryColor])),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(rounding),
                      topRight: Radius.circular(rounding)),
                  color: Colors.white),
              child: child,
            )),
      ),
    );
  }
}
