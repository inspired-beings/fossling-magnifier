package com.inspiredbeings.flossmagnifier

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

// A magnifier must not sleep mid-reading.
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}
