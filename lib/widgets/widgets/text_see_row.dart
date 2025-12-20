import 'dart:ffi';

import 'package:flutter/material.dart';

import '../../core/core/utils/app_textstyles.dart';


class TextSeeRow extends StatelessWidget {
  String firstText;
  VoidCallback onPressed;

  TextSeeRow({super.key, required this.firstText,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          firstText,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Spacer(),
        TextButton(
          onPressed:onPressed,
          child: Text("See All", style: AppTextStyles.medium14LightPrimary),
        ),
      ],
    );
  }
}
