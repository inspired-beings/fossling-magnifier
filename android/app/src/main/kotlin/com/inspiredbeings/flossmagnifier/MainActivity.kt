package com.inspiredbeings.flossmagnifier

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// A magnifier must not sleep mid-reading.
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.inspiredbeings.flossmagnifier/settings")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Only meaningful right after a denied request: rationale=false
                    // then means the OS will no longer show the prompt.
                    "isCameraPermissionPermanentlyDenied" -> {
                        val denied = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.CAMERA,
                        ) != PackageManager.PERMISSION_GRANTED
                        val noPrompt = !ActivityCompat.shouldShowRequestPermissionRationale(
                            this,
                            Manifest.permission.CAMERA,
                        )
                        result.success(denied && noPrompt)
                    }
                    "openAppSettings" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.fromParts("package", packageName, null),
                            ),
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
