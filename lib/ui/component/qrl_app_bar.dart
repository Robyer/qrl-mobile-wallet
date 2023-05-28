import 'package:flutter/material.dart';

class QrlAppBar extends AppBar {
  QrlAppBar({super.key})
      : super(
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/qrl-logo.png',
                fit: BoxFit.contain,
                height: 60,
              )
            ],
          ),
        );
}

class QrlTitleAppBar extends AppBar {
  final String titleText;

  QrlTitleAppBar({required this.titleText, Key? key})
      : super(
    key: key,
    elevation: 0,
    centerTitle: true,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          titleText,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Image.asset(
          'assets/images/qrl-logo.png',
          fit: BoxFit.contain,
          height: 60,
        ),
      ),
    ],
  );
}
