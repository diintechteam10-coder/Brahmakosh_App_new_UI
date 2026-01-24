import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'colors.dart';

class Utils {
  bool isSearchExpanded = false, isOpen = false;
  static late bool _dialogShown = false;

  static void showToast(String text, [Color? bgColor]) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade900,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void showLoaderDialogNew(TickerProvider tickerProvider) {
    if (_dialogShown || Get.isDialogOpen == true) return;

    _dialogShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.generalDialog(
        barrierDismissible: false,
        pageBuilder: (context, animation1, animation2) {
          return const SizedBox();
        },
        transitionBuilder: (context, a1, a2, widget) {
          return StatefulBuilder(
            builder: (context, setState) => Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: Container(
                  alignment: Alignment.center,
                  child: WillPopScope(
                    onWillPop: () async => false,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CustomColors.primaryColor,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  static void print(message) {
    if (!kReleaseMode) {
      debugPrint(message.toString());
    }
  }

  static Future<bool> isNetworkConnected({showToast = true}) async {
    try {
      await InternetAddress.lookup('google.com');
      return true;
    } on SocketException catch (_) {
      if (showToast) {
        Utils.showToast('No Internet Connection', Colors.red);
      }
      return false;
    } catch (e) {
      Utils.showToast('No Internet Connection', Colors.red);
      return false;
    }
  }

  static void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static showPopupDialog({
    text,
    onPressed,
    bool isCustom = false,
    Widget? widget,
    bool isDismissableOnBack = false,
  }) {
    showGeneralDialog(
      transitionBuilder: (context, a1, a2, wid) {
        return WillPopScope(
          onWillPop: () async {
            return isDismissableOnBack;
          },
          child: Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Container(
                alignment: Alignment.center,
                child: Dialog(
                  insetPadding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 30,
                    bottom: 30,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  backgroundColor: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: 20,
                        ),
                        child: isCustom
                            ? widget
                            : LayoutBuilder(
                                builder: (context, constraints) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Utils.textViewAlign(
                                      text,
                                      17,
                                      Colors.black,
                                      FontWeight.w600,
                                      TextAlign.center,
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      width: constraints.maxWidth * 0.3,
                                      margin: const EdgeInsets.only(
                                        right: 5,
                                        top: 10,
                                        left: 5,
                                      ),
                                      child: MaterialButton(
                                        elevation: 10,
                                        highlightElevation: 0,
                                        onPressed: onPressed,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            80.0,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(0.0),
                                        child: Ink(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: <Color>[
                                                CustomColors.gradientBueStart,
                                                CustomColors.gradientBueEnd,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(80.0),
                                            ),
                                          ),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              minHeight: 45.0,
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'OK',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: '',
      context: Get.context!,
      pageBuilder:
          (context, animation1, animation2) {
                return;
              }
              as Widget Function(
                BuildContext,
                Animation<double>,
                Animation<double>,
              ),
    );
  }

  static Future<DateTime> selectDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      helpText: 'Select Date',
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      return Future.value(picked);
    }

    return initialDate;
  }

  static void hideLoader() {
    if (_dialogShown && Get.isDialogOpen == true) {
      Get.back();
      _dialogShown = false;
    }
  }

  static Widget textView(
    String text,
    double fontSize,
    Color? textColor,
    FontWeight fontWeight,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Aileron',
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  static Widget textViewFont(
    String text,
    Color? textColor,
    FontWeight fontWeight,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Aileron',
        color: textColor,
        fontSize: Get.width * 0.038,
        fontWeight: fontWeight,
      ),
    );
  }

  static Widget primaryText({
    required String text,
    required Color textColor,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: fontSize.clamp(10.0, 20.0),
        fontWeight: fontWeight,
      ),
    );
  }

  static Widget textViewHeader(
    String text,
    Color? textColor,
    FontWeight fontWeight,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Aileron',
        color: textColor,
        fontSize: Get.width * 0.07,
        fontWeight: fontWeight,
      ),
    );
  }

  static Widget textViewsubHeader(
    String text,
    Color? textColor,
    FontWeight fontWeight,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Aileron',
        color: textColor,
        fontSize: Get.width * 0.05,
        fontWeight: fontWeight,
      ),
    );
  }

  static Widget textViewAlign(
    String text,
    double fontSize,
    Color? textColor,
    FontWeight fontWeight,
    TextAlign textAlign,
  ) {
    return Text(
      text,
      textAlign: textAlign,
      softWrap: true,
      style: TextStyle(
        fontFamily: 'Aileron',
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  // static Future<String> getDeviceId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isIOS) {
  //     var iosDeviceInfo = await deviceInfo.iosInfo;
  //     return iosDeviceInfo.identifierForVendor.toString();
  //   } else {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     return androidDeviceInfo.id;
  //   }
  // }

  static String formatCurrentMonth(DateTime dateTime) {
    DateFormat formatter = DateFormat('MMM');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  static bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  // static Future<String> getDeviceDetails() async {
  //  // var deviceInfo = DeviceInfoPlugin();
  //   final PackageInfo info = await PackageInfo.fromPlatform();
  //   if (Platform.isIOS) {
  //     var iosDeviceInfo = await deviceInfo.iosInfo;
  //     return iosDeviceInfo.identifierForVendor.toString();
  //   } else {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     String data =
  //         'AppVersion:${info.version}, sdkInt:${androidDeviceInfo.version.sdkInt},release:${androidDeviceInfo.version.release},manufacturer:${androidDeviceInfo.manufacturer},brand:${androidDeviceInfo.brand},device:${androidDeviceInfo.device}';
  //     return data;
  //   }
  // }

  static Widget elevatedButton({
    height = 50.0,
    marginLeft = 0.0,
    marginRight = 0.0,
    marginTop = 0.0,
    marginBottom = 0.0,
    required onPressed,
    isEnabled = true,
    text = 'OK',
    fontSize = 18.0,
    borderRadius = 40.0,
    textColor = Colors.white,
  }) {
    return Container(
      height: height,
      margin: EdgeInsets.fromLTRB(
        marginLeft,
        marginTop,
        marginRight,
        marginBottom,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? [CustomColors.gradientBueStart, CustomColors.gradientBueEnd]
                  : [Colors.grey, Colors.grey],
            ),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(
            CustomColors.primaryColorDark,
          ),
          elevation: MaterialStateProperty.resolveWith<double>((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.pressed)) {
              return 0.0;
            }
            return 5.0;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            ),
          ),
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  int get weekOfMonth {
    var wom = 0;
    var date = this;

    while (date.month == month) {
      wom++;
      date = date.subtract(const Duration(days: 7));
    }

    return wom;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
