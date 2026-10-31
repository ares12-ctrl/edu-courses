package com.educourses.app

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : io.flutter.embedding.android.FlutterActivity() {

    companion object {
        private const val DEVICE_GUARD_CHANNEL = "app/device_guard"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_GUARD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // كشف المحاكي بنظام التقييم
                    "isEmulator" -> result.success(EmulatorDetector.isEmulator(applicationContext))
                    // مجموع النقاط (للتشخيص)
                    "emulatorScore" -> result.success(EmulatorDetector.score(applicationContext))
                    else -> result.notImplemented()
                }
            }
    }
}
