import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universa/app/data/services/auth_service.dart';
import 'package:universa/app/theme/app_theme.dart';
import 'package:universa/app/data/services/content_service.dart';
import 'package:universa/app/data/models/subject_model.dart';
import 'package:universa/app/data/models/category_model.dart';
import 'package:universa/app/data/models/instructor_model.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ContentService _contentService = Get.find<ContentService>();
  
  final isLoading = false.obs;
  final subjects = <Subject>[].obs;
  final categories = <Category>[].obs;
  final instructors = <Instructor>[].obs;
  
  // Selected filters
  final selectedCategorySlug = RxnString();
  final selectedInstructorId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      // Fetch filters first
      final cats = await _contentService.getCategories();
      final insts = await _contentService.getInstructors();
      
      categories.assignAll(cats);
      instructors.assignAll(insts);
      
      // Fetch subjects
      await fetchSubjects();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSubjects() async {
    try {
      final subs = await _contentService.getSubjects(
        categorySlug: selectedCategorySlug.value,
        instructorId: selectedInstructorId.value,
      );
      subjects.assignAll(subs);
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    }
  }

  void filterByCategory(String? slug) {
    if (selectedCategorySlug.value == slug) {
      selectedCategorySlug.value = null; // Toggle off
    } else {
      selectedCategorySlug.value = slug;
    }
    fetchSubjects();
  }

  void filterByInstructor(int? id) {
    if (selectedInstructorId.value == id) {
      selectedInstructorId.value = null; // Toggle off
    } else {
      selectedInstructorId.value = id;
    }
    fetchSubjects();
  }
  
  void logout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'تأكيد تسجيل الخروج',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
          style: GoogleFonts.cairo(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () async {
              await _authService.logout();
              Get.offAllNamed('/login');
            },
            child: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
