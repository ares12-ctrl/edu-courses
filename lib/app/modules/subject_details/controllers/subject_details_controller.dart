import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/services/content_service.dart';

class SubjectDetailsController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();
  
  final isLoading = true.obs;
  final subject = Rxn<Subject>();
  final String subjectSlug = Get.arguments as String;
  final allLessons = <Lesson>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubjectDetails();
  }

  Future<void> fetchSubjectDetails() async {
    isLoading.value = true;
    try {
      final result = await _contentService.getSubjectDetails(subjectSlug);
      if (result != null) {
        subject.value = result;
        
        // Flatten lessons for navigation
        allLessons.clear();
        for (var course in result.courses) {
          allLessons.addAll(course.lessons);
        }

        if (kDebugMode) {
          debugPrint('Subject ID: ${result.id}');
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  int? getNextLessonId(int currentId) {
    final index = allLessons.indexWhere((l) => l.id == currentId);
    if (index != -1 && index < allLessons.length - 1) {
      return allLessons[index + 1].id;
    }
    return null;
  }

  int? getPrevLessonId(int currentId) {
    final index = allLessons.indexWhere((l) => l.id == currentId);
    if (index != -1 && index > 0) {
      return allLessons[index - 1].id;
    }
    return null;
  }
}
