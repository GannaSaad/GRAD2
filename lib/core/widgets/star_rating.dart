import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? Colors.amber;
    final inactive = inactiveColor ?? Colors.grey.shade300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;

        return GestureDetector(
          onTap: onRatingChanged != null ? () => onRatingChanged!(starIndex) : null,
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? active : inactive,
            size: size.r,
          ),
        );
      }),
    );
  }
}
