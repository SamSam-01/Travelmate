import 'package:front/commons.dart';

ThemeData get lightTheme {
  return ThemeData(
    fontFamily: Font.montserrat,
    primarySwatch: Colors.blue,
    useMaterial3: true,
    cardTheme: const CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(fontSize: 12.0),
      bodyLarge: TextStyle(fontSize: 12.0),
    ),
    appBarTheme: const AppBarTheme(
      // iconTheme: IconThemeData(color: Colors.black),
      iconTheme: IconThemeData(color: MyColors.greyDark),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontFamily: Font.montserrat,
        fontWeight: FontWeight.w600,
      ),
    ),
    scaffoldBackgroundColor: Colors.white,

    ///Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: kRadius30),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: Font.montserrat,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          /// disabled state shouldn't be RED :)
          if (states.contains(WidgetState.disabled)) {
            return MyColors.greyDark;
          }
          return MyColors.trekBlue;
        }),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        overlayColor: WidgetStateProperty.all<Color>(MyColors.grey),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.only(left: 35, right: 35, top: 15, bottom: 15),
        ),
      ),
    ),

    ///TextButton theme
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: Font.montserrat,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.all<Color>(MyColors.trekBlue),
    ),
  );
}

///Expand darkTheme to meet your needs
ThemeData get darkTheme {
  return ThemeData(
    fontFamily: Font.montserrat,
    primarySwatch: Colors.blue,
    useMaterial3: true,
    brightness: Brightness.dark,
    cardTheme: const CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(fontSize: 12.0, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 12.0, color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontFamily: Font.montserrat,
        fontWeight: FontWeight.w600,
      ),
    ),
    scaffoldBackgroundColor: Colors.black,

    ///Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: kRadius30),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: Font.montserrat,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey[800];
          }
          return MyColors.trekBlue.withValues(alpha: 0.8);
        }),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        overlayColor: WidgetStateProperty.all<Color>(Colors.grey[700]!),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.only(left: 35, right: 35, top: 15, bottom: 15),
        ),
      ),
    ),

    ///TextButton theme
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: Font.montserrat,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.all<Color>(
        MyColors.trekBlue.withValues(alpha: 0.8),
      ),
    ),
  );
}
