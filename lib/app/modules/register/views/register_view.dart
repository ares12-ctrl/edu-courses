import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universa/app/modules/register/controllers/register_controller.dart';
import 'package:universa/app/theme/app_theme.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Center(
                  child: Column(
                    children: [
                    
                      const SizedBox(height: 16),
                      Text(
                        'إنشاء حساب جديد',
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'انضم إلى EduCourses وابدأ رحلتك',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form Fields
                _buildStyledField(
                  controller: controller.usernameController,
                  label: 'اسم المستخدم',
                  icon: Icons.alternate_email_rounded,
                  errorKey: 'username',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStyledField(
                        controller: controller.firstNameController,
                        label: 'الاسم الأول',
                        icon: Icons.person_outline_rounded,
                        errorKey: 'first_name',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStyledField(
                        controller: controller.lastNameController,
                        label: 'اسم العائلة',
                        icon: Icons.person_outline_rounded,
                        errorKey: 'last_name',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStyledField(
                  controller: controller.emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorKey: 'email',
                ),
                const SizedBox(height: 16),
                _buildStyledField(
                  controller: controller.passwordController,
                  label: 'كلمة المرور',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  errorKey: 'password',
                ),
                const SizedBox(height: 16),
                _buildStyledField(
                  controller: controller.password2Controller,
                  label: 'تأكيد كلمة المرور',
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                  errorKey: 'password2',
                ),
                
                const SizedBox(height: 40),
                
                // Register Button
                Obx(() {
                  return controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
                      : Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controller.register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'إنشاء الحساب',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                }),
                
                const SizedBox(height: 24),
                
                // Login Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Pop back to the existing login page when possible so
                      // GetX doesn't recreate and then dispose LoginController.
                      final navigator = Get.key.currentState;
                      if (navigator != null && navigator.canPop()) {
                        Get.back();
                      } else {
                        Get.offAllNamed('/login');
                      }
                    },
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.cairo(fontSize: 14),
                        children: [
                          const TextSpan(
                            text: 'لديك حساب بالفعل؟ ',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const TextSpan(
                            text: 'تسجيل الدخول',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String errorKey,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final errorText = this.controller.errors[errorKey];
          final hasError = errorText != null && errorText.isNotEmpty;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: hasError 
                        ? AppColors.danger 
                        : AppColors.border,
                    width: hasError ? 1.5 : 1.0,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: GoogleFonts.cairo(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      icon, 
                      color: hasError 
                          ? AppColors.danger.withOpacity(0.8) 
                          : AppColors.primaryLight, 
                      size: 22
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: 'أدخل $label',
                    hintStyle: GoogleFonts.cairo(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, right: 8.0),
                  child: Text(
                    errorText,
                    style: GoogleFonts.cairo(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
