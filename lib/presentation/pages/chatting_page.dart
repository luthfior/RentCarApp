import 'package:flutter/material.dart';

import '../../data/models/car.dart';

class ChattingPage extends StatelessWidget {
  const ChattingPage({
    super.key,
    required this.car,
    required this.uid,
    required this.username,
  });
  final Car car;
  final String uid;
  final String username;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
