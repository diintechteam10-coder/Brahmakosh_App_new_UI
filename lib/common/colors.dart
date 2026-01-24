import 'package:flutter/material.dart';

class CustomColors {
  static const bgColor = Color(0xfffffcef);

  static const bgColor1 = Color(0xffffffff);

  static const black = Color(0xff000000);
  static const white = Color(0xffffffff);
  static const primaryColor = Color(0xffe64d53);
  static const primaryColorLight = Color(0xffffa883);
  //static const primaryColorDark = Color(0xff5f37c2);
  static const primaryColorDark = Color(0xffe64d53);
  static const lightYellowColor = Color(0xfff4e9e0);
  static const baseColor = Color(0xfff7f7f7);
  static const redColor = Color(0xfffb1607);
  static const greenColor = Color(0xff22a08c);
  static const yellowColor = Color(0xffffbb38);
  static const lightPinkColor = Color(0xfff4e9e0);
  static const buttonColor = Color(0xffff7438);
  static const shape1Color = Color(0xff009cff);
  static const shape2Color = Color(0xff0479d4);
  static const shape3Color = Color(0xfffeda87);
  static const shape4Color = Color(0xfffff3c4);
  static const shape5Color = Color(0xfffef7dc);
  static const headerColor = Color(0xffeeeeee);
  static const transparentHeaderColor = Color(0x95fef7dc);
  static const transparentWhite = Color(0xffffffff);
  static const gradientBueStart = Color(0xffe64d53);
  static const gradientBueEnd = Color(0xffffa883);
  static const orange = Color(0xffFEDA87);
  static const olive = Color(0xff705A13);
  static const orangeDark = Color(0xffFCA016);
  static const textColor = Color(0xffdd5c3b);
  static const sliderButtonBackground = Color(0xfff4f7f8);
  static const dayEnd = Color(0xff5f37c2);
  static const meeting = Color(0xffe11e53);
  static const retailing = Color(0xff00c4b7);
  static const dayStart = Color(0xfffca800);
  static const textColor1 = Color(0xff94896b);
  static const toolbarColor = Color(0xff3F5998);
  static const calenderHeaderBackgroundColor = Color(0xfffbfbfb);
  static const calenderHeaderColor = Color(0xff1f6ee5);
  static const lightGreen = Color(0xff8AB354);
  static const absentRed = Color(0xffF65E06);
  static const leaveYellow = Color(0xffe3c300);
  static const dateHeaderColor = Color(0xffA6A6A6);
  static const timeColor = Color(0xff222B45);
  static const outsideDaysColor = Color(0xffB1B9CA);
  static const textColor2 = Color(0xff7e6900);
  static const magenta = Color(0xffe216df);
  static const grey = const Color(0xff757575);
  static const gradient2 = const Color(0xffCFD2DA);
  static const drawerIconColor = const Color(0xff03467D);
  static const darkGrey = Color(0xff4a4a4a);
  static const mediumGrey = Color(0xff9e9e9e);
  static const lightGrey = Color(0xffe0e0e0);
  static const blueGrey = Color(0xff607d8b);
  static const softBlue = Color(0xffcce5ff);
  static const lightBlueAccent = Color(0xff82b1ff);
  static const tealAccent = Color(0xff64ffda);
  static const softGreen = Color(0xffd0f0c0);
  static const softRed = Color(0xffffcdd2);
  static const softOrange = Color(0xffffe0b2);
  static const softYellow = Color(0xfffff9c4);
  static const navyBlue = Color(0xff001f3f);
  static const palePurple = Color(0xffe0bbff);
  static const errorRed = Color(0xffd32f2f);
  static const successGreen = Color(0xff388e3c);
  static const infoBlue = Color(0xff1976d2);
  static const warningAmber = Color(0xffffc107);
  static const disabledColor = Color(0xffbdbdbd);
  static const borderColor = Color(0xffcccccc);
  static const dividerColor = Color(0xffe0e0e0);
  static const cardShadow = Color(0x29000000);

  static const gradientBlueStart1 = Color.fromARGB(255, 14, 158, 184);

  static const gradientBlueStart = Color(0xFF44E4FF);
  static const gradientBlueEnd = Color.fromARGB(255, 45, 36, 199);

  static const gradientBlueEnd1 = Color.fromARGB(255, 37, 28, 199);

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch as Map<int, Color>);
  }
}
