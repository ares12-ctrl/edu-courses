import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universa/app/theme/app_theme.dart';
import '../controllers/offline_player_controller.dart';

class OfflinePlayerView extends GetView<OfflinePlayerController> {
  const OfflinePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: GetBuilder<OfflinePlayerController>(
          builder: (controller) => Column(
            children: [
              Text(controller.title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
              if (controller.username.isNotEmpty)
                Text(controller.username, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: GetBuilder<OfflinePlayerController>(
            builder: (c) {
              final playerController = c.betterPlayerController;
              if (playerController == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return BetterPlayer(controller: playerController);
            },
          ),
        ),
      ),
    );
  }
}
