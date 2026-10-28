import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:universa/app/theme/app_theme.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 28.0,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
      bodyTextStyle: GoogleFonts.cairo(
        fontSize: 18.0,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      pageColor: Colors.transparent, // Transparant to show background gradient
      imagePadding: const EdgeInsets.only(top: 60.0, bottom: 40.0),
      titlePadding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
    );

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
          child: IntroductionScreen(
            key: controller.introKey,
            globalBackgroundColor: Colors.transparent,
            allowImplicitScrolling: true,
            pages: [
              PageViewModel(
                title: "منصّة تعليمية جامعية متميزة",
                body: "تجمع بين خبرة أساتذة الجامعات وتقنيات التعلم الحديثة لتوفير تجربة تعليمية فريدة.",
                image: _buildImage(Icons.school_rounded),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: "مشاهدة بدون إنترنت",
                body: "شاهد محاضراتك في أي وقت — حتى بدون اتصال بالإنترنت. تجربة تعليمية أسرع وأكثر أمانًا.",
                image: _buildImage(Icons.cloud_download_rounded),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: "دورات معتمدة",
                body: "دورات تعليمية معتمدة يقدّمها نخبة من أساتذة الجامعات بخبرة أكاديمية حقيقية تضمن جودة المحتوى.",
                image: _buildImage(Icons.verified_rounded),
                decoration: pageDecoration,
              ),
              PageViewModel(
                title: "حماية كاملة للمحتوى",
                body: "ادرس بحرية مع ضمان حماية خصوصيتك ومحتواك التعليمي عبر تقنيات تشفير متطورة.",
                image: _buildImage(Icons.security_rounded),
                decoration: pageDecoration,
              ),
            ],
            onDone: () => controller.onIntroEnd(),
            onSkip: () => controller.onIntroEnd(),
            showSkipButton: true,
            skipOrBackFlex: 0,
            nextFlex: 0,
            showBackButton: false,
            skip: Text(
              'تخطى',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            next: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
            ),
            done: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              child: Text(
                'ابدأ الآن',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            curve: Curves.fastLinearToSlowEaseIn,
            controlsMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            controlsPadding: const EdgeInsets.all(8),
            dotsDecorator: DotsDecorator(
              size: const Size(10.0, 10.0),
              color: AppColors.border,
              activeSize: const Size(28.0, 10.0),
              activeColor: AppColors.primaryLight,
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Decorative background circles like the website image
        Positioned(
          left: -20,
          top: 0,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -10,
          bottom: 0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Main Icon with Gradient
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Icon(
            icon,
            size: 160.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
