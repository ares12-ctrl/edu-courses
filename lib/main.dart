import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/content_service.dart';
import 'app/data/services/device_service.dart';
import 'app/data/services/download_service.dart';
import 'app/modules/device_guard/views/device_blocked_view.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // منع تشغيل التطبيق على المحاكي
  final isRealDevice = await DeviceService.isRealDevice();
  if (!isRealDevice) {
    runApp(const DeviceBlockedApp());
    return;
  }

  // Initialize Services
  final authService = Get.put(AuthService(), permanent: true);
  Get.put(ContentService(), permanent: true);
  Get.put(DownloadService(), permanent: true);

  // Check login status and first time
  final isFirstTime = await authService.isFirstTime();
  final isLoggedIn = await authService.isLoggedIn();

  String initialRoute;
  if (isFirstTime) {
    initialRoute = Routes.ONBOARDING;
  } else {
    initialRoute = isLoggedIn ? Routes.DASHBOARD : Routes.LOGIN;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

/// تطبيق مختصر بيظهر شاشة الحجب على المحاكي
class DeviceBlockedApp extends StatelessWidget {
  const DeviceBlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EduCourses',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: const Locale('ar', 'SA'),
      home: const DeviceBlockedView(),
    );
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EduCourses',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      defaultTransition: Transition.cupertino,
    );
  }
}

