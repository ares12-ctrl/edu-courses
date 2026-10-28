import 'package:get/get.dart';
import '../controllers/my_enrollments_controller.dart';

class MyEnrollmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyEnrollmentsController>(
      () => MyEnrollmentsController(),
    );
  }
}
