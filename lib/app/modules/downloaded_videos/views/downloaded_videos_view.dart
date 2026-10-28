import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universa/app/theme/app_theme.dart';
import '../controllers/downloaded_videos_controller.dart';

class DownloadedVideosView extends GetView<DownloadedVideosController> {
  const DownloadedVideosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text('الفيديوهات المحملة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
            Obx(() => controller.username.value.isNotEmpty 
              ? Text(controller.username.value, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary))
              : const SizedBox.shrink()),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.downloads.isEmpty) {
          return Center(
            child: Text('لا توجد فيديوهات محملة', style: GoogleFonts.cairo(color: AppColors.textPrimary)),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadDownloads,
          child: ListView.builder(
            itemCount: controller.downloads.length,
            itemBuilder: (context, index) {
              final download = controller.downloads[index];
              final status = download['download_status'] as int?;
              final progress = download['download_progress'] as int? ?? 0;
              final isCompleted = status == 3;
              final isRunning = status == 1;
              final isPaused = status == 5;
              final isFailed = status == 4;
              
              return ListTile(
                title: Text(
                  download['title'] ?? 'درس',
                  style: GoogleFonts.cairo(color: AppColors.textPrimary),
                ),
                subtitle: !isCompleted 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: AppColors.border,
                            color: isPaused ? AppColors.secondary : AppColors.primaryLight,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isPaused ? 'متوقف مؤقتاً ($progress%)' : isFailed ? 'فشل ($progress%)' : 'جاري التحميل ($progress%)',
                                style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              if (isRunning)
                                IconButton(
                                  icon: const Icon(Icons.pause, size: 20, color: AppColors.secondary),
                                  onPressed: () => controller.pauseDownload(download['lesson_id']),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                )
                              else if (isPaused || isFailed)
                                IconButton(
                                  icon: const Icon(Icons.play_arrow, size: 20, color: AppColors.primaryLight),
                                  onPressed: () => controller.resumeDownload(
                                    download['lesson_id'],
                                    download['title'],
                                    download['direct_hls_url'] ?? '',
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ],
                      )
                    : Text('مكتمل', style: GoogleFonts.cairo(color: AppColors.success)),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  color: AppColors.surfaceAlt,
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmationDialog(context, download['lesson_id']);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: AppColors.danger),
                          const SizedBox(width: 8),
                          Text('حذف', style: GoogleFonts.cairo(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: isCompleted ? () => controller.playVideo(download) : null,
              );
            },
          ),
        );
      }),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic lessonId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'تأكيد الحذف',
          style: GoogleFonts.cairo(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من أنك تريد حذف هذا الفيديو؟',
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
            onPressed: () {
              controller.deleteDownload(lessonId);
              Get.back();
            },
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
