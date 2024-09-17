import 'package:flutter/material.dart';

class Pixel extends StatelessWidget {
  final Color color;
  final int? child;

  const Pixel({
    super.key,
    required this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.all(1),
      // Center
    ); // Container
  } // build
} // Pixel
