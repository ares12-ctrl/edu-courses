package com.educourses.app

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.SensorManager
import android.os.Build
import android.telephony.TelephonyManager
import java.io.File

/**
 * كشف المحاكيات (Android Studio AVD / BlueStacks / Nox / LDPlayer / Genymotion ...)
 *
 * بنظام تقييم: كل مؤشر بيضيف نقاط، ولو مجموع النقاط وصل [THRESHOLD]
 * نعتبر الجهاز محاكي. الطريقة دي أفضل من الاعتماد على شرط واحد،
 * لأن BlueStacks بيزوّر بصمة الجهاز لكنه مش قادر يخفي كل المؤشرات.
 */
object EmulatorDetector {

    /** الحد الأدنى لمجموع النقاط اللي بنعتبر عنده الجهاز محاكي */
    private const val THRESHOLD = 40

    /** أسماء محاكيات معروفة ممكن تظهر في بصمة الجهاز */
    private val KNOWN_EMULATOR_NAMES = listOf(
        "bluestacks", "genymotion", "nox", "ldplayer", "memu",
        "andy", "droid4x", "ttvm", "vbox", "android sdk built for"
    )

    /** حزم بتتثبت جوّه المحاكيات نفسها */
    private val KNOWN_EMULATOR_PACKAGES = listOf(
        "com.bluestacks.home",
        "com.bluestacks.appmart",
        "com.bluestacks.BstCommandProcessor",
        "com.bignox.app",
        "com.vphone.launcher"
    )

    /** ملفات ومسارات بتدل على وجود محاكي */
    private val KNOWN_EMULATOR_PATHS = listOf(
        "/sdcard/windows/BstSharedFolder",          // BlueStacks shared folder
        "/sdcard/windows/BstConfig",                // BlueStacks config
        "/data/local/tmp/bluestacks.conf",          // BlueStacks
        "/system/lib/libbluestacks.so",             // BlueStacks
        "/system/lib64/libbluestacks.so",           // BlueStacks
        "/dev/socket/qemud",                        // QEMU
        "/dev/qemu_pipe",                           // QEMU
        "/system/lib/libc_malloc_debug_qemu.so",    // QEMU
        "/system/bin/qemu-props"                    // QEMU
    )

    fun isEmulator(context: Context): Boolean = score(context) >= THRESHOLD

    /** بيرجع مجموع نقاط المؤشرات (للتشخيص) */
    fun score(context: Context): Int {
        return fingerprintScore() +
            systemPropertyScore() +
            pathScore() +
            packageScore(context) +
            hardwareScore(context)
    }

    /** 1) بصمة الجهاز وخصائص البناء */
    private fun fingerprintScore(): Int {
        var points = 0
        val fingerprint = (Build.FINGERPRINT ?: "").lowercase()
        val model = (Build.MODEL ?: "").lowercase()
        val brand = (Build.BRAND ?: "").lowercase()
        val device = (Build.DEVICE ?: "").lowercase()
        val product = (Build.PRODUCT ?: "").lowercase()
        val manufacturer = (Build.MANUFACTURER ?: "").lowercase()
        val hardware = (Build.HARDWARE ?: "").lowercase()

        // اسم محاكي صريح
        if (KNOWN_EMULATOR_NAMES.any {
                model.contains(it) || manufacturer.contains(it) ||
                    brand.contains(it) || product.contains(it)
            }
        ) {
            points += 50
        }

        if (fingerprint.startsWith("generic") || fingerprint.startsWith("unknown")) points += 30
        if (model.contains("google_sdk") || model.contains("emulator") || model.contains("sdk_gphone")) points += 40
        if (brand.startsWith("generic") && device.startsWith("generic")) points += 30
        if (product.contains("sdk") || product.contains("vbox86p") ||
            product.contains("emulator") || product.contains("simulator")
        ) {
            points += 30
        }
        if (hardware.contains("goldfish") || hardware.contains("ranchu") || hardware.contains("vbox86")) points += 40

        // أجهزة الكمبيوتر بتاعت المحاكيات بتشتغل على معمارية x86
        if (hardware == "intel" || hardware == "intel64" || hardware == "amd") points += 20

        // روم مخصص/معدّل (مؤشر ضعيف لوحده)
        if (Build.TAGS?.contains("test-keys") == true) points += 10

        return points
    }

    /** 2) خصائص النظام (ro.*) اللي المحاكي بيسيب أثر فيها */
    private fun systemPropertyScore(): Int {
        var points = 0

        if (getProp("ro.kernel.qemu") == "1" || getProp("ro.boot.qemu") == "1") points += 50
        if (getProp("ro.hardware").contains("goldfish") || getProp("ro.hardware").contains("ranchu")) points += 40
        if (getProp("ro.product.cpu.abi").contains("x86")) points += 20
        if (getProp("ro.product.cpu.abilist").contains("x86")) points += 20
        if (getProp("ro.hardware.egl").contains("swiftshader") ||
            getProp("ro.hardware.egl").contains("bluestacks")
        ) {
            points += 40
        }
        if (getProp("ro.build.flavor").contains("sdk_") || getProp("ro.build.flavor").contains("emulator")) points += 30

        // معالج x86 حقيقي = جهاز كمبيوتر مش موبايل
        val cpuInfo = readFile("/proc/cpuinfo")
        if (cpuInfo.contains("GenuineIntel") || cpuInfo.contains("AuthenticAMD")) points += 40

        return points
    }

    /** 3) ملفات ومسارات BlueStacks والمحاكيات */
    private fun pathScore(): Int {
        var points = 0
        for (path in KNOWN_EMULATOR_PATHS) {
            if (File(path).exists()) {
                points += 50
                break
            }
        }
        return points
    }

    /** 4) حزم مثبتة خاصة بالمحاكيات */
    private fun packageScore(context: Context): Int {
        val pm = context.packageManager
        for (pkg in KNOWN_EMULATOR_PACKAGES) {
            try {
                pm.getPackageInfo(pkg, 0)
                return 40
            } catch (_: PackageManager.NameNotFoundException) {
                // الحزمة غير موجودة، نكمل
            } catch (_: Exception) {
                // قيود رؤية الحزم على Android 11+، نتجاهل
            }
        }
        return 0
    }

    /** 5) خصائص العتاد ومصادر المحاكاة */
    private fun hardwareScore(context: Context): Int {
        var points = 0

        // المحاكي غالبًا ملهوش حساسات حقيقية
        try {
            val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
            val sensors = sensorManager?.getSensorList(android.hardware.Sensor.TYPE_ALL)
            if (sensors != null && sensors.isEmpty()) points += 40
        } catch (_: Exception) {
        }

        // مفيش شريحة اتصال / راديو
        try {
            val telephony = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            if (telephony != null && telephony.phoneType == TelephonyManager.PHONE_TYPE_NONE) points += 20
        } catch (_: Exception) {
        }

        // معالج واحد نادر جدًا في موبايل حقيقي
        if (Runtime.getRuntime().availableProcessors() <= 1) points += 10

        return points
    }

    /** قراءة خصائص النظام بالـ reflection (زي getprop) */
    @Suppress("PrivateApi")
    private fun getProp(key: String): String {
        return try {
            val clazz = Class.forName("android.os.SystemProperties")
            val get = clazz.getMethod("get", String::class.java)
            (get.invoke(null, key) as? String).orEmpty().lowercase()
        } catch (_: Exception) {
            ""
        }
    }

    private fun readFile(path: String): String {
        return try {
            File(path).takeIf { it.exists() }?.readText().orEmpty()
        } catch (_: Exception) {
            ""
        }
    }
}
