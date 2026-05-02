import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  final Widget child;
  const MyContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: child);
  }
}
