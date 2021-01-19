package org.unifiedpush.flutter.connector

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.unifiedpush.android.connector.Registration

class Plugin : ActivityAware, FlutterPlugin, MethodCallHandler {
    private var mContext : Context? = null
    private var mActivity : Activity? = null

    companion object {

        var channel: MethodChannel? = null
        private var up = Registration()

        @JvmStatic
        private fun registerAppWithDialog(context: Context,
                                          result: Result?) {
            up.registerAppWithDialog(context)
            result?.success(null)
        }

        @JvmStatic
        private fun unregister(context: Context,
                               result: Result) {
            up.unregisterApp(context)
            result.success(true)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "org.unifiedpush.flutter.connector.channel")
        channel?.setMethodCallHandler(this)

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        mActivity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        mActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mActivity = binding.activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when(call.method) {
            "registerAppWithDialog" -> registerAppWithDialog(mActivity!!, result)
            "unregister" -> unregister(mActivity!!, result)
            else -> result.notImplemented()
        }
    }
}
