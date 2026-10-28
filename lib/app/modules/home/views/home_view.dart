import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/subject_model.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_theme.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      key: GlobalKey<ScaffoldState>(), // Key to open drawer
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 70, // Increase width for padding
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 8.0,
              bottom: 8.0,
              right: 16.0,
            ),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.menu,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'EduCourses',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 40.0,
              left: 10.0,
            ), // More inward padding
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.background,
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(
                        Icons.school,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section - Beautiful Dropdowns
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                // Category Dropdown
                Expanded(
                  child: Obx(
                    () => _buildDropdown<String>(
                      context: context,
                      value: controller.selectedCategorySlug.value,
                      hint: 'القسم',
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('كل الأقسام'),
                        ),
                        ...controller.categories.map(
                          (cat) => DropdownMenuItem(
                            value: cat.slug,
                            child: Text(cat.name),
                          ),
                        ),
                      ],
                      onChanged: (val) => controller.filterByCategory(val),
                      icon: Icons.category_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Instructor Dropdown
                Expanded(
                  child: Obx(
                    () => _buildDropdown<int>(
                      context: context,
                      value: controller.selectedInstructorId.value,
                      hint: 'المحاضر',
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('كل المحاضرين'),
                        ),
                        ...controller.instructors.map(
                          (inst) => DropdownMenuItem(
                            value: inst.id,
                            child: Text(inst.fullName),
                          ),
                        ),
                      ],
                      onChanged: (val) => controller.filterByInstructor(val),
                      icon: Icons.person_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subjects List with Shimmer
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.subjects.isEmpty) {
                return _buildShimmerLoading(context);
              }

              if (controller.subjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        color: AppColors.textSecondary,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مواد متاحة حالياً',
                        style: GoogleFonts.cairo(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchInitialData,
                        child: Text(
                          'إعادة المحاولة',
                          style: GoogleFonts.cairo(),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchInitialData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = controller.subjects[index];
                    return _buildSubjectCard(context, subject, primaryColor);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: AppColors.primaryLight,
          ),
          dropdownColor: AppColors.surface,
          items: items,
          onChanged: onChanged,
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((DropdownMenuItem<T> item) {
              return Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: AppColors.primaryLight.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.value == null ? hint : (item.child as Text).data!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: AppColors.surfaceAlt,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.surface),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryColor.withOpacity(0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/logo (1).png',
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.school, color: primaryColor, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'EduCourses',
                    style: GoogleFonts.cairo(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'الرئيسية',
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(color: AppColors.border, indent: 20, endIndent: 20),

                // Contact Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Text(
                    'تواصل معنا',
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),

                // Contact Social Items
                _buildContactItem(
                  icon: Icons.email_outlined,
                  title: 'الدعم الفني',
                  subtitle: 'تواصل معنا عبر البريد',
                  color: primaryColor,
                  onTap: () {
                    Get.defaultDialog(
                      title: 'الدعم الفني',
                      titleStyle: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      backgroundColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(20),
                      content: Text(
                        'للتواصل مع الدعم الفني، يمكنك مراسلتنا عبر البريد الإلكتروني:\n\nsupport@educourses.site',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      confirm: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'حسناً',
                          style: GoogleFonts.cairo(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.border, indent: 20, endIndent: 20),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  onTap: () {
                    Navigator.pop(context);
                    controller.logout();
                  },
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'الإصدار 1.0.0',
              style: GoogleFonts.cairo(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        textAlign: TextAlign.right,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.right,
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
        textAlign: TextAlign.right,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    Subject subject,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image with Rounded Corners
          if (subject.coverImage.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  subject.coverImage.trim(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceAlt,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Arabic RTL feel
              children: [
                // Title
                Text(
                  subject.name,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Instructor Row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'المحاضر: ${subject.instructor.fullName}',
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Badge and Price Row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Enrollment Status Indicator
                      if (subject.isEnrolled)
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'متاح',
                              style: GoogleFonts.cairo(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'مادة دراسية',
                              style: GoogleFonts.cairo(
                                color: AppColors.primaryLight,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.school_outlined,
                              size: 14,
                              color: AppColors.primaryLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // View Subject Button (Gradient)
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(
                          Routes.SUBJECT_DETAILS,
                          arguments: subject.slug,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'عرض المادة',
                            style: GoogleFonts.cairo(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
