import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universa/app/data/services/auth_service.dart';
import 'package:universa/app/data/services/logger_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();

  final isLoading = false.obs;
  final errors = <String, String>{}.obs;

  Future<void> register() async {
    isLoading.value = true;
    errors.clear();

    final username = usernameController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final password2Val = password2Controller.text;

    // Basic client-side validation
    if (username.isEmpty) errors['username'] = 'هذا الحقل مطلوب';
    if (firstName.isEmpty) errors['first_name'] = 'هذا الحقل مطلوب';
    if (lastName.isEmpty) errors['last_name'] = 'هذا الحقل مطلوب';
    if (email.isEmpty) errors['email'] = 'هذا الحقل مطلوب';
    if (password.isEmpty) errors['password'] = 'هذا الحقل مطلوب';
    if (password2Val.isEmpty) errors['password2'] = 'هذا الحقل مطلوب';

    if (errors.isNotEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      final result = await _authService.register(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        password2: password2Val,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        final data = result['data'];
        final access = data['access'];
        final refresh = data['refresh'];

        await _authService.saveTokens(access, refresh);
        await _authService.saveUsername(username);

        if (isClosed) return;

        LoggerService().success('تم إنشاء الحساب بنجاح', title: 'نجاح');
        _goToLogin();
      } else {
        // Handle server-side errors
        final errorData = result['errors'];
        if (errorData is Map) {
          errorData.forEach((key, value) {
            // Check for general errors
            if (key == 'detail' || key == 'general' || key == 'non_field_errors') {
               String msg = value is List ? value.first.toString() : value.toString();
               LoggerService().warning(_translateError(msg), title: 'تنبيه');
            } else {
              if (value is List) {
                errors[key] = _translateError(value.first.toString());
              } else {
                errors[key] = _translateError(value.toString());
              }
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

  /// Returns to the existing login page instead of pushing a new one.
  /// Pushing a new `/login` over the old one causes GetX to dispose the newly
  /// created LoginController while the old login route is being removed.
  void _goToLogin() {
    if (isClosed) return;
    final navigator = Get.key.currentState;
    if (navigator != null && navigator.canPop()) {
      Get.back();
    } else {
      Get.offAllNamed('/login');
    }
  }

  String _translateError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('email already used') ||
        (lower.contains('already exists') && lower.contains('email'))) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    }
    if (lower.contains('username') && lower.contains('already exists')) {
      return 'اسم المستخدم مستخدم بالفعل';
    }
    if (lower.contains('enter a valid email')) {
      return 'البريد الإلكتروني غير صالح';
    }
    if (lower.contains('passwords do not match') ||
        lower.contains('do not match')) {
      return 'كلمتا المرور غير متطابقتين';
    }
    if (lower.contains('too short') ||
        lower.contains('too common') ||
        lower.contains('too similar') ||
        lower.contains('entirely numeric')) {
      return 'كلمة المرور ضعيفة، اختر كلمة مرور أقوى';
    }
    if (lower.contains('blank') || lower.contains('required')) {
      return 'هذا الحقل مطلوب';
    }
    return message;
  }

  @override
  void onClose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    super.onClose();
  }
}
