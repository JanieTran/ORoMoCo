import 'package:flutter/material.dart';

class AppSizes {
  static const int splashScreenTitleFontSize = 48;
  static const int titleFontSize = 34;
  static const double sidePadding = 15;
  static const double widgetSidePadding = 20;
  static const double buttonRadius = 25;
  static const double imageRadius = 8;
  static const double linePadding = 4;
  static const double widgetBorderRadius = 34;
  static const double textFieldRadius = 4.0;
  static const EdgeInsets bottomSheetPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  static const app_bar_size = 56.0;
  static const app_bar_expanded_size = 180.0;
  static const tile_width = 148.0;
  static const tile_height = 276.0;
}

class AppColors {
  // static const blue = Color(0xFF083276);
  static const blue = Color(0xFF243665);
}

class AppConsts {
  static const page_size = 20;
}

class ORoMoCoTheme {
  static final theme = ThemeData(
    // primarySwatch: Colors.indigo,
    primaryColor: const Color(0xFF243665),
    accentColor: const Color(0xFF8BD8BD),
    errorColor: Colors.red,
    fontFamily: 'Livvic',
    textTheme: ThemeData.light().textTheme.copyWith(
          headline5: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.blue,
          ),
          headline6: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          ),
          subtitle1: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColors.blue,
          ),
          subtitle2: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: AppColors.blue,
          ),
          bodyText1: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColors.blue,
          ),
          caption: TextStyle(
            fontSize: 16,
            color: AppColors.blue,
          ),
        ),
  );
}
