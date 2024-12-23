import 'package:flutter/material.dart';

// カラーパレット
const defaultBlack = Color.fromRGBO(25, 25, 25, 1);
const defaultWhite = Color.fromRGBO(230, 230, 230, 1);
const erDark = Color.fromRGBO(55, 55, 55, 1);
const erLight = Color.fromRGBO(200, 200, 200, 1);

// テーマ設定
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: defaultWhite, // bodyの背景色
  appBarTheme: AppBarTheme(
    backgroundColor: erLight, // header, footer
    foregroundColor: defaultBlack, // テキストの色
  ),
  dividerTheme: DividerThemeData(
    color: defaultBlack, // h3の下線やtableの枠線
    thickness: 1.0,
  ), // tableの枠線
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: defaultBlack, // bodyの背景色
  appBarTheme: AppBarTheme(
    backgroundColor: erDark, // header, footer
    foregroundColor: defaultWhite, // テキストの色
  ),
  dividerTheme: DividerThemeData(
    color: defaultWhite, // h3の下線やtableの枠線
    thickness: 1.0,
  ), // tableの枠線
);
