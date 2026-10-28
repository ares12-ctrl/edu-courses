import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:universa/app/theme/app_theme.dart';
import '../controllers/lesson_details_controller.dart';

class LessonDetailsView extends GetView<LessonDetailsController> {
  const LessonDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.lesson.value?.title ?? 'تفاصيل الدرس',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isLocked.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 60,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'عفواً، هذا الدرس مغلق',
                    style: GoogleFonts.cairo(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'يجب عليك إكمال الدروس السابقة أولاً لتتمكن من مشاهدة هذا الدرس',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (controller.suggestedLessonId.value != null)
                    ElevatedButton.icon(
                      onPressed: () => controller.loadLesson(
                        controller.suggestedLessonId.value!,
                      ),
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text(
                        'الذهاب للدرس المتاح',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'العودة للخلف',
                      style: GoogleFonts.cairo(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final lesson = controller.lesson.value;
        if (lesson == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                Text(
                  'فشل في تحميل بيانات الدرس',
                  style: GoogleFonts.cairo(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchLessonDetails(),
                  child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Video Section
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: Obx(() {
                    if (controller.isVideoLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.hasVideoError.value) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.danger,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.videoErrorMessage.value,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => controller.retryVideo(),
                                icon: const Icon(
                                  Icons.refresh,
                                  color: AppColors.primaryLight,
                                  size: 18,
                                ),
                                label: Text(
                                  'إعادة المحاولة',
                                  style: GoogleFonts.cairo(
                                    color: AppColors.primaryLight,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (controller.betterPlayerController != null) {
                      return BetterPlayer(
                        controller: controller.betterPlayerController!,
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_off_outlined,
                            color: AppColors.textSecondary,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'الفيديو غير متاح حالياً',
                            style: GoogleFonts.cairo(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lesson.title,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (lesson.durationSeconds != null) ...[
                          Text(
                            '${(lesson.durationSeconds! / 60).floor()} دقيقة',
                            style: GoogleFonts.cairo(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: AppColors.primaryLight,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Actions Section (Complete & Navigation)
                    Column(
                      children: [
                        // Mark as Completed Button
                        Obx(() {
                          final isCompleted =
                              controller.lesson.value?.isCompleted ?? false;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isCompleted
                                  ? null
                                  : () => controller.markAsCompleted(),
                              icon: Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                              ),
                              label: Text(
                                isCompleted ? 'تم إكمال الدرس' : 'تحديد كمكتمل',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCompleted
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isCompleted
                                      ? const BorderSide(
                                          color: AppColors.success,
                                        )
                                      : BorderSide.none,
                                ),
                                disabledBackgroundColor: AppColors.success
                                    .withOpacity(0.1),
                                disabledForegroundColor: AppColors.success,
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Completion Hint
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'تأكد من إكمال الدرس لتتمكن من الانتقال للدرس التالى',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Navigation Buttons
                        Obx(() {
                          final hasNext = controller.nextLessonId.value != null;
                          final hasPrev = controller.prevLessonId.value != null;

                          if (!hasNext && !hasPrev) {
                            return const SizedBox.shrink();
                          }

                          return Row(
                            children: [
                              if (hasPrev)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => controller.loadLesson(
                                      controller.prevLessonId.value!,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'الدرس السابق',
                                      style: GoogleFonts.cairo(),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      foregroundColor: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              if (hasNext && hasPrev) const SizedBox(width: 12),
                              if (hasNext)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => controller.loadLesson(
                                      controller.nextLessonId.value!,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'الدرس التالي',
                                      style: GoogleFonts.cairo(),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.surfaceAlt,
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Download Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() {
                                if (controller.isDownloaded.value) {
                                  return const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  );
                                }
                                if (controller.isDownloading.value) {
                                  return Text(
                                    '${controller.downloadProgress.value}%',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return const Icon(
                                  Icons.download_for_offline_outlined,
                                  color: AppColors.textSecondary,
                                );
                              }),
                              Text(
                                'مشاهدة بدون إنترنت',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: Obx(() {
                              if (controller.isDownloaded.value) {
                                return OutlinedButton.icon(
                                  onPressed:
                                      () {}, // Already handled by player initialization
                                  icon: const Icon(Icons.play_circle_outline),
                                  label: Text(
                                    'تشغيل من المحملات',
                                    style: GoogleFonts.cairo(),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.success,
                                    side: const BorderSide(
                                      color: AppColors.success,
                                    ),
                                  ),
                                );
                              }

                              if (controller.isDownloading.value) {
                                return Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value:
                                          controller.downloadProgress.value /
                                          100,
                                      backgroundColor: AppColors.border,
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'جاري التحميل...',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () =>
                                              controller.pauseDownload(),
                                          icon: const Icon(
                                            Icons.pause,
                                            size: 16,
                                            color: AppColors.secondary,
                                          ),
                                          label: Text(
                                            'إيقاف مؤقت',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }

                              if (controller.isPaused.value) {
                                return Column(
                                  children: [
                                    LinearProgressIndicator(
                                      value:
                                          controller.downloadProgress.value /
                                          100,
                                      backgroundColor: AppColors.border,
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'تم الإيقاف المؤقت',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => controller
                                              .startDownload(), // Resume
                                          icon: const Icon(
                                            Icons.play_arrow,
                                            size: 16,
                                            color: AppColors.primaryLight,
                                          ),
                                          label: Text(
                                            'استئناف',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: AppColors.primaryLight,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }

                              return ElevatedButton.icon(
                                onPressed: () => controller.startDownload(),
                                icon: const Icon(Icons.download),
                                label: Text(
                                  'تحميل الدرس الآن',
                                  style: GoogleFonts.cairo(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: AppColors.primaryLight,
                                  elevation: 0,
                                  side: BorderSide(
                                    color: AppColors.primary.withOpacity(0.5),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
