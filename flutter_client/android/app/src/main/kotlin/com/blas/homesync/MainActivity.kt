package com.blas.homesync

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.emoji2.text.EmojiCompat
import androidx.emoji2.bundled.BundledEmojiCompatConfig
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        val config = BundledEmojiCompatConfig(this)
        EmojiCompat.init(config)
        super.onCreate(savedInstanceState)
    }
}
