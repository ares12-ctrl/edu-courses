import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universa/app/data/services/auth_service.dart';
import 'package:universa/app/data/services/logger_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  Future<void> login() async {
    isLoading.value = true;
    errors.clear();

    final username = usernameController.text.trim();
    final password = passwordController.text;

    // Basic client-side validation
    if (username.isEmpty) errors['username'] = 'هذا الحقل مطلوب';
    if (password.isEmpty) errors['password'] = 'هذا الحقل مطلوب';

    if (errors.isNotEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      final result = await _authService.login(
        username: username,
        password: password,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        final data = result['data'];
        final access = data['access'];
        final refresh = data['refresh'];

        await _authService.saveTokens(access, refresh);
        await _authService.saveUsername(username);

        LoggerService().success('تم تسجيل الدخول بنجاح', title: 'نجاح');

        Get.offAllNamed('/dashboard');
      } else {
        // Handle server-side errors
        final errorData = result['errors'];
        if (errorData is Map) {
          errorData.forEach((key, value) {
            final msg = value is List ? value.first.toString() : value.toString();

            if (key == 'username' || key == 'password') {
              errors[key] = _translateError(msg);
            } else if (key == 'device_id') {
              LoggerService().warning(
                'تعذر التحقق من الجهاز، حاول إغلاق التطبيق وفتحه مرة أخرى',
                title: 'تنبيه',
              );
            } else if (key == 'detail' && msg.toLowerCase().contains('invalid credentials')) {
              LoggerService().warning(
                'اسم المستخدم أو كلمة المرور غير صحيحة',
                title: 'تنبيه',
              );
            } else {
              LoggerService().warning(_translateError(msg), title: 'تنبيه');
            }
          });
        } else {
          LoggerService().error('حدث خطأ غير معروف', title: 'خطأ');
        }
      }
    } catch (e) {
      isLoading.value = false;
      LoggerService().error('حدث خطأ غير متوقع', title: 'خطأ');
    }
  }

  String _translateError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid credentials') ||
        lower.contains('no active account')) {
      return 'اسم المستخدم أو كلمة المرور غير صحيحة';
    }
    if (lower.contains('blank') || lower.contains('required')) {
      return 'هذا الحقل مطلوب';
    }
    return message;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
