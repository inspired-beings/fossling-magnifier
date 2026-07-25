import 'package:flutter/material.dart';

/// Shared with the accessibility tests so contrast is checked against the shipped colors.
ThemeData buildAppTheme() => ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.amber,
      useMaterial3: true,
    );
