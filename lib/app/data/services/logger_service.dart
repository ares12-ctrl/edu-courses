import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void info(String message, {String? title}) {
    _logger.i('$title: $message');
    _showToast(message, Colors.blue);
  }

  void success(String message, {String? title}) {
    _logger.i('SUCCESS: $title - $message');
    _showToast(message, Colors.green);
  }

  void warning(String message, {String? title}) {
    _logger.w('$title: $message');
    _showToast(message, Colors.orange);
  }

  void error(String message, {String? title, dynamic error, StackTrace? stackTrace}) {
    _logger.e('$title: $message', error: error, stackTrace: stackTrace);
    _showToast(message, Colors.red);
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
