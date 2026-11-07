package com.yanxia.reader

import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * 檐下 · 主 Activity。
 *
 * 除了承载 Flutter 界面，还开了一条 [CHANNEL] 供 Dart 侧调用系统
 * 文字转语音：init / speak / stop / shutdown，并用 onDone / onError
 * 把每句的播完事件回推给 Dart，供阅读页做跟读高亮。
 *
 * 不引入任何第三方 TTS 库，只用平台自带的 android.speech.tts，
 * 避免插件 Kotlin 版本与 Flutter Gradle 插件冲突。
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "yanxia/tts"
        private const val UTTERANCE_ID = "yanxia_utterance"
    }

    private var channel: MethodChannel? = null
    private var tts: TextToSpeech? = null
    private var ready = false
    private var initResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> initTts(result)
                "speak" -> speak(
                    call.argument<String>("text") ?: "",
                    (call.argument<Double>("rate") ?: 0.5).toFloat(),
                    result,
                )
                "stop" -> {
                    tts?.stop()
                    result.success(null)
                }
                "shutdown" -> {
                    tts?.shutdown()
                    tts = null
                    ready = false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initTts(result: MethodChannel.Result) {
        if (tts != null) {
            result.success(ready)
            return
        }
        initResult = result
        tts = TextToSpeech(this) { status ->
            ready = status == TextToSpeech.SUCCESS
            if (ready) {
                try {
                    tts?.language = Locale.SIMPLIFIED_CHINESE
                } catch (_: Exception) {
                    // 部分机型没有中文语音包，保留引擎默认语言即可
                }
                tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {}

                    override fun onDone(utteranceId: String?) {
                        notifyDart("onDone")
                    }

                    @Deprecated("Legacy callback, kept for older engines")
                    override fun onError(utteranceId: String?, errorCode: Int) {
                        notifyDart("onError")
                    }

                    override fun onError(utteranceId: String?) {
                        notifyDart("onError")
                    }
                })
            }
            val pending = initResult
            initResult = null
            pending?.success(ready)
        }
    }

    private fun speak(text: String, rate: Float, result: MethodChannel.Result) {
        if (!ready || tts == null || text.isEmpty()) {
            result.success(false)
            return
        }
        try {
            tts?.setSpeechRate(rate.coerceIn(0.1f, 2.0f))
            val params = Bundle()
            params.putString(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, UTTERANCE_ID)
            val rc = tts?.speak(text, TextToSpeech.QUEUE_FLUSH, params, UTTERANCE_ID)
            result.success(rc == TextToSpeech.SUCCESS)
        } catch (_: Exception) {
            result.success(false)
        }
    }

    /** 原生回调可能不在主线程，切回主线程再发给 Dart。 */
    private fun notifyDart(method: String) {
        runOnUiThread {
            try {
                channel?.invokeMethod(method, null)
            } catch (_: Exception) {
                // Flutter 侧已销毁时忽略
            }
        }
    }

    override fun onDestroy() {
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }
}
