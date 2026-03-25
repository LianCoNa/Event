import 'package:flutter/material.dart';
import '../app/constants.dart';

class CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;

  const CategoryChip({
    super.key,
    required this.text,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}