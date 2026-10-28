import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/material.dart';

import 'package:universa/app/data/services/auth_service.dart';

class OnboardingController extends GetxController {
  final introKey = GlobalKey<IntroductionScreenState>();

  void onIntroEnd() async {
    await Get.find<AuthService>().completeOnboarding();
    Get.offAllNamed('/login');
  }
}
