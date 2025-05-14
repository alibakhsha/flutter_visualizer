//package com.example.test1
//
//import android.media.audiofx.Visualizer
//import android.util.Log
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity: FlutterActivity() {
//    private val CHANNEL = "visualizer"
//    private var visualizer: Visualizer? = null
//    private val TAG = "VisualizerMainActivity"
//
//    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            when (call.method) {
//                "getWaveform" -> {
//                    val waveform = getWaveform()
//                    if (waveform != null) {
//                        Log.d(TAG, "Waveform data: ${waveform.size} bytes")
//                        result.success(waveform.toList())
//                    } else {
//                        Log.e(TAG, "Failed to get waveform")
//                        result.error("WAVEFORM_ERROR", "Could not get waveform data", null)
//                    }
//                }
//                "stopVisualizer" -> {
//                    stopVisualizer()
//                    Log.d(TAG, "Visualizer stopped")
//                    result.success(null)
//                }
//                "releaseVisualizer" -> {
//                    releaseVisualizer()
//                    Log.d(TAG, "Visualizer released")
//                    result.success(null)
//                }
//                else -> result.notImplemented()
//            }
//        }
//    }
//
//    private fun getWaveform(): ByteArray? {
//        if (visualizer == null) {
//            try {
//                visualizer = Visualizer(0).apply {
//                    captureSize = Visualizer.getCaptureSizeRange()[1] // استفاده از حداکثر اندازه ممکن
//                    measurementMode = Visualizer.MEASUREMENT_MODE_PEAK_RMS
//                    enabled = true
//                }
//                Log.d(TAG, "Visualizer initialized with size: ${visualizer?.captureSize}")
//            } catch (e: Exception) {
//                Log.e(TAG, "Visualizer init error", e)
//                return null
//            }
//        }
//
//        return ByteArray(visualizer?.captureSize ?: 1024).apply {
//            val status = visualizer?.getWaveForm(this)
//            if (status != Visualizer.SUCCESS) {
//                Log.e(TAG, "Waveform failed with status: $status")
//                return null
//            }
//        }
//    }
//
//    private fun stopVisualizer() {
//        visualizer?.enabled = false
//        Log.d(TAG, "Visualizer disabled")
//    }
//
//    private fun releaseVisualizer() {
//        visualizer?.release()
//        visualizer = null
//        Log.d(TAG, "Visualizer released")
//    }
//}


package com.example.test1

import android.media.audiofx.Visualizer
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "visualizer"
    private var visualizer: Visualizer? = null
    private val TAG = "VisualizerMainActivity"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initVisualizer" -> {
                    val audioSessionId = call.argument<Int>("audioSessionId")
                    try {
                        initVisualizer(audioSessionId)
                        Log.d(TAG, "Visualizer initialized with audioSessionId: $audioSessionId")
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e(TAG, "Visualizer init error", e)
                        result.error("VISUALIZER_INIT_ERROR", "Failed to initialize visualizer", e.message)
                    }
                }
                "getWaveform" -> {
                    val waveform = getWaveform()
                    if (waveform != null) {
                        Log.d(TAG, "Waveform data: ${waveform.size} bytes, values: ${waveform.toList()}")
                        result.success(waveform.toList())
                    } else {
                        Log.e(TAG, "Failed to get waveform")
                        result.error("WAVEFORM_ERROR", "Could not get waveform data", null)
                    }
                }
                "stopVisualizer" -> {
                    stopVisualizer()
                    Log.d(TAG, "Visualizer stopped")
                    result.success(null)
                }
                "releaseVisualizer" -> {
                    releaseVisualizer()
                    Log.d(TAG, "Visualizer released")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initVisualizer(audioSessionId: Int?) {
        try {
            visualizer?.release()
            visualizer = null
            visualizer = Visualizer(audioSessionId ?: 0).apply {
                captureSize = Visualizer.getCaptureSizeRange()[1]
                measurementMode = Visualizer.MEASUREMENT_MODE_PEAK_RMS
                enabled = true
            }
            Log.d(TAG, "Visualizer initialized with size: ${visualizer?.captureSize}")
        } catch (e: Exception) {
            Log.e(TAG, "Visualizer init error", e)
            visualizer = null
            throw e // Let the caller handle the error
        }
    }

    private fun getWaveform(): ByteArray? {
        if (visualizer == null) {
            Log.w(TAG, "Visualizer is null")
            return null
        }

        return try {
            ByteArray(visualizer?.captureSize ?: 1024).apply {
                val status = visualizer?.getWaveForm(this)
                if (status != Visualizer.SUCCESS) {
                    Log.e(TAG, "Waveform failed with status: $status")
                    return null
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting waveform", e)
            null
        }
    }

    private fun stopVisualizer() {
        visualizer?.enabled = false
        Log.d(TAG, "Visualizer disabled")
    }

    private fun releaseVisualizer() {
        visualizer?.enabled = false
        visualizer?.release()
        visualizer = null
        Log.d(TAG, "Visualizer released")
    }
}