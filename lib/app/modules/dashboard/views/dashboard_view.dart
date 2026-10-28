import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../downloaded_videos/views/downloaded_videos_view.dart';
import '../../../theme/app_theme.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Widget> pages = [
      const HomeView(),
      const DownloadedVideosView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: pages,
      )),
      bottomNavigationBar: SafeArea(
        // Keep the bar above the Android system navigation buttons
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Obx(() => CurvedNavigationBar(
            index: controller.selectedIndex.value,
            backgroundColor: AppColors.background, // Matches Scaffold background to blend in
            color: AppColors.surface, // Navigation bar color
            buttonBackgroundColor: theme.colorScheme.primary, // Floating button color
            height: 75,
            animationDuration: const Duration(milliseconds: 300),
            items: const [
              CurvedNavigationBarItem(
                child: Icon(Icons.home_rounded, color: AppColors.textPrimary),
                label: 'الرئيسية',
                labelStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
              CurvedNavigationBarItem(
                child: Icon(Icons.download_rounded, color: AppColors.textPrimary),
                label: 'التحميلات',
                labelStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
              CurvedNavigationBarItem(
                child: Icon(Icons.person_rounded, color: AppColors.textPrimary),
                label: 'حسابي',
                labelStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ],
            onTap: (index) => controller.changeIndex(index),
          )),
        ),
      ),
    );
  }
}
