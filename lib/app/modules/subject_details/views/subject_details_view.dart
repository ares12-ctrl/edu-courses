import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:universa/app/data/services/logger_service.dart';
import 'package:universa/app/theme/app_theme.dart';
import '../controllers/subject_details_controller.dart';
import '../../../data/models/subject_model.dart';
import '../../../routes/app_pages.dart';

class SubjectDetailsView extends GetView<SubjectDetailsController> {
  const SubjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        final subject = controller.subject.value;
        if (subject == null) {
          return _buildErrorState();
        }

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(subject),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSubjectInfo(subject),
                    const SizedBox(height: 30),
                    Text(
                      'محتوى المادة',
                      style: GoogleFonts.cairo(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCoursesList(subject.courses),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.subject.value == null) {
          return const SizedBox.shrink();
        }
        return _buildBottomAction(controller.subject.value!);
      }),
    );
  }

  Widget _buildSliverAppBar(Subject subject) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (subject.coverImage.isNotEmpty)
              Image.network(
                subject.coverImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.surface),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectInfo(Subject subject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: Text(
            subject.category.name,
            style: GoogleFonts.cairo(
              color: AppColors.primaryLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subject.name,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'المحاضر: ${subject.instructor.fullName}',
                style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.person_outline,
                color: AppColors.primaryLight,
                size: 20,
              ),
            ],
          ),
        ),
        if (subject.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            subject.description,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoursesList(List<Course> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد محتوى متاح حالياً',
          style: GoogleFonts.cairo(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: ExpansionTile(
            collapsedIconColor: AppColors.textSecondary,
            iconColor: AppColors.primaryLight,
            title: Text(
              course.title,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            children: course.lessons
                .map((lesson) => _buildLessonItem(lesson))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildLessonItem(Lesson lesson) {
    final isEnrolled = controller.subject.value?.isEnrolled ?? false;
    final isUnlocked = lesson.isFreePreview || isEnrolled;
    final isCompleted = lesson.isCompleted;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: isUnlocked
          ? (isCompleted
                ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.success,
                      size: 16,
                    ),
                  )
                : (lesson.isFreePreview
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'مجاني',
                            style: GoogleFonts.cairo(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.play_circle_outline_rounded,
                          color: AppColors.primaryLight,
                          size: 22,
                        )))
          : Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 18,
            ),
      title: Text(
        lesson.title,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(
          color: isCompleted ? AppColors.success : AppColors.textSecondary,
          decoration: isCompleted
              ? TextDecoration.none
              : null, // Optional: lineThrough if desired, but green is usually enough
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: isUnlocked
            ? AppColors.textSecondary
            : AppColors.textSecondary.withOpacity(0.3),
        size: 16,
      ),
      onTap: () {
        if (isUnlocked) {
          Get.toNamed(Routes.LESSON_DETAILS, arguments: lesson.id);
        } else {
          LoggerService().warning(
            'هذا الدرس غير متاح لحسابك',
            title: 'عفواً',
          );
        }
      },
    );
  }

  Widget _buildBottomAction(Subject subject) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: subject.isEnrolled
            ? Container(
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.5)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'هذه المادة متاحة لحسابك',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : (subject.enrollmentStatus == 'pending'
                  ? Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.hourglass_empty_rounded,
                              color: AppColors.secondary,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'هذا المحتوى غير متاح لحسابك',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.primaryLight,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'هذا المحتوى غير متاح لحسابك',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceAlt,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 300, color: AppColors.surface),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(
                  5,
                  (index) => Container(
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: GoogleFonts.cairo(color: AppColors.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.fetchSubjectDetails(),
            child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
}
