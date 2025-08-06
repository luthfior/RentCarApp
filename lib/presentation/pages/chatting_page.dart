import 'package:flutter/material.dart';

import '../../data/models/car.dart';

class ChattingPage extends StatelessWidget {
  const ChattingPage({
    super.key,
    required this.product,
    required this.uid,
    required this.username,
  });
  final Car product;
  final String uid;
  final String username;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
