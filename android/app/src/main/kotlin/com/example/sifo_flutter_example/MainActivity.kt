package com.example.sifo_flutter_example

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import se.kantarsifo.mobileanalytics.framework.TSMobileAnalytics
import se.kantarsifo.mobileanalytics.framework.TWAModel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.app/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "initializeFramework") {
                val cpId = call.argument<String>("cpId")
                val appName = call.argument<String>("appName")
                val isPanelistOnly = call.argument<Boolean>("isPanelistOnly")
                val isLogEnabled = call.argument<Boolean>("isLogEnabled")
                val isWebViewBased = call.argument<Boolean>("isWebViewBased")

                if (cpId != null && appName != null && isPanelistOnly != null && isLogEnabled != null && isWebViewBased != null) {
                    val success = initializeFramework(
                        cpId,
                        appName,
                        isPanelistOnly,
                        isLogEnabled,
                        isWebViewBased
                    )
                    result.success(success)
                } else {
                    result.error("INVALID_DATA", "Invalid data received from Flutter", null)
                }
            } else if (call.method == "sendTag") {
                val category = call.argument<String>("category")
                val contentId = call.argument<String>("contentID")
                if (category != null && contentId != null) {
                    val success = sendTag(category, contentId)
                    result.success(success)
                } else {
                    result.error("INVALID_DATA", "Invalid data received from Flutter", null)
                }
            } else if (call.method == "destroyFramework") {
                val success = destroyCurrentFramework()
                result.success(success)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun initializeFramework(
        cpId: String,
        appName: String,
        isPanelistOnly: Boolean,
        isLogEnabled: Boolean,
        isWebViewBased: Boolean
    ): Boolean {
        return try {
            TSMobileAnalytics.createInstance(
                this,
                TSMobileAnalytics.Builder()
                    .setCpId(cpId)
                    .setApplicationName(appName)
                    .setPanelistTrackingOnly(isPanelistOnly)
                    .setIsWebViewBased(isWebViewBased)
                    .setLogPrintsActivated(isLogEnabled)
                    .setTWAInfo(TWAModel(url = "https://www.mediafacts.se/").apply {
                        extraParams.apply {
                            put("customCustomerParam", "foo")
                        }
                    })
                    .build()
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun sendTag(category: String?, contentId: String?): Boolean {
        TSMobileAnalytics.instance?.sendTag(category, contentId)
        return true
    }

    private fun destroyCurrentFramework(): Boolean {
        TSMobileAnalytics.destroyFramework()
        return true
    }
}
