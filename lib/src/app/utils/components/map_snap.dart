import 'package:flutter/material.dart';

// Renders a LocationModel's Static Maps snapshot — a URL on web (see
// LocationModel.snapshot), loaded via Image.network rather than
// Image.memory since there are no raw bytes to hold here anymore.
class MapSnapshotWidget extends StatelessWidget {
  final String snapshotUrl;
  final double height;
  final double width;

  const MapSnapshotWidget({
    super.key,
    required this.snapshotUrl,
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
        child: Image.network(
          snapshotUrl,
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
