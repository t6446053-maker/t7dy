import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  final String imageQuery;
  bool isSelected;

  CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    this.color = const Color(0xFFD4AF37),
    this.description = '',
    this.imageQuery = '',
    this.isSelected = false,
  });
}
