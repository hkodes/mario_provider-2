import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final setLightTheme = _buildLightTheme();

ThemeData _buildLightTheme() {
  const base_gray = const Color(0xff85878b);
  const primary_color = const Color(0xff6454de);
  const primary_light_color = const Color(0xff9a81ff);
  const primary_error_red = Colors.red;
  return ThemeData(
    primaryColor: primary_color,
    brightness: Brightness.light,
    accentColor: primary_light_color,
    iconTheme: IconThemeData(color: base_gray),
    textTheme: TextTheme(
      subtitle1: TextStyle(
        fontWeight: FontWeight.w400,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Metropolis',
        fontSize: 14,
      ),
      filled: true,
      disabledBorder: new OutlineInputBorder(
        borderSide: BorderSide(
          color: primary_color,
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(25.0),
        ),
      ),
      enabledBorder: new OutlineInputBorder(
        borderSide: BorderSide(
          color: primary_color,
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(25.0),
        ),
      ),
      errorBorder: new OutlineInputBorder(
        borderSide: BorderSide(
          color: primary_error_red,
        ),
        borderRadius: const BorderRadius.all(
          const Radius.circular(25.0),
        ),
      ),
      focusedBorder: new OutlineInputBorder(
        borderSide: BorderSide(color: primary_color),
        borderRadius: const BorderRadius.all(
          const Radius.circular(25.0),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) return Colors.grey;
            return primary_color;
          },
        ),
        minimumSize: MaterialStateProperty.resolveWith<Size>(
          (states) => Size(50, 50),
        ),
        // elevation: MaterialStateProperty.resolveWith<double>(
        //   (Set<MaterialState> states) {
        //     return 0.0;
        //   },
        // ),
        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
          (Set<MaterialState> states) {
            return const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0);
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return base_gray;
          },
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: base_gray, size: 8),
        textTheme: TextTheme(
          headline6: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: false),
  );
}
