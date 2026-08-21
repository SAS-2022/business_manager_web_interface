import 'dart:typed_data';

import 'package:flutter/material.dart';

class MapSnapshotWidget extends StatelessWidget {
  final Uint8List snapshotData;
  final double height;
  final double width;

  const MapSnapshotWidget({
    super.key,
    required this.snapshotData,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          snapshotData,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
