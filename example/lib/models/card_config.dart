import 'package:flutter/material.dart';
import 'package:flutter_folderview/flutter_folderview.dart';

class CardConfig {
  final String title;
  final ViewMode mode;
  final LineStyle lineStyle;
  final Color primaryColor;
  final List<Node<String>> data;

  CardConfig({
    required this.title,
    required this.mode,
    required this.lineStyle,
    required this.primaryColor,
    required this.data,
  });

  CardConfig copyWith({
    String? title,
    ViewMode? mode,
    LineStyle? lineStyle,
    Color? primaryColor,
    List<Node<String>>? data,
  }) {
    return CardConfig(
      title: title ?? this.title,
      mode: mode ?? this.mode,
      lineStyle: lineStyle ?? this.lineStyle,
      primaryColor: primaryColor ?? this.primaryColor,
      data: data ?? this.data,
    );
  }
}
