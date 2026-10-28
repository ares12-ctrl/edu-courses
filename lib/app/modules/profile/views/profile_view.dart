import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universa/app/theme/app_theme.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الملف الشخصي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final user = controller.profile.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 60),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ في تحميل البيانات',
                  style: GoogleFonts.cairo(color: AppColors.textPrimary, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchProfile,
                  child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header with Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                        style: GoogleFonts.cairo(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.role == 'student' ? 'طالب' : user.role,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Stats
              InkWell(
                onTap: () => Get.toNamed(Routes.MY_ENROLLMENTS),
                borderRadius: BorderRadius.circular(16),
                child: _buildStatCard(
                  context,
                  'المواد النشطة',
                  user.activeSubjectsCount.toString(),
                  Icons.menu_book_rounded,
                ),
              ),
              const SizedBox(height: 16),
              
              // Actions
              const Divider(height: 40, color: AppColors.border),
              _buildActionButton(
                context,
                'التحميلات',
                Icons.download_done_rounded,
                AppColors.primaryLight,
                () => Get.toNamed('/downloaded-videos'),
              ),
              _buildActionButton(
                context,
                'تسجيل الخروج',
                Icons.logout_rounded,
                AppColors.secondary,
                controller.logout,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                context,
                'حذف الحساب',
                Icons.delete_forever_rounded,
                AppColors.danger,
                controller.deleteAccount,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight),
          const SizedBox(width: 16),
          Text(label, style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textPrimary)),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
