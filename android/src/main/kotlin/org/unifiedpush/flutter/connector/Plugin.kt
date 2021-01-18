package org.unifiedpush.flutter.connector

import android.app.Activity
import android.content.Context
import android.util.Log
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

        @JvmStatic
        private val TAG = "FlutterUnifiedPushPlugin"
        @JvmStatic
        val SHARED_PREFERENCES_KEY = "flutter-connector_plugin_cache"
        @JvmStatic
        val CALLBACK_HANDLE_KEY = "callback_handle"
        @JvmStatic
        val CALLBACK_DISPATCHER_HANDLE_KEY = "callback_dispatch_handler"

        var channel: MethodChannel? = null
        private var up = Registration()

        @JvmStatic
        private fun register(context: Context,
                             args: ArrayList<*>?,
                             result: Result?) {
            val name = args!![0] as String
            up.saveDistributor(context, name)
            up.registerApp(context)
            result?.success(null)
        }

        @JvmStatic
        private fun registerAppWithDialog(context: Context,
                                          args: ArrayList<*>?,
                                          result: Result?) {
            up.registerAppWithDialog(context)
            result?.success(null)
        }

        @JvmStatic
        private fun initializeService(context: Context, args: ArrayList<*>?) {
            Log.d(TAG, "Initializing FlutterUnifiedPushService")
            val callbackHandle = args!![0] as Long
            context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
                    .edit()
                    .putLong(CALLBACK_DISPATCHER_HANDLE_KEY, callbackHandle)
                    .apply()
        }

        @JvmStatic
        private fun unregister(context: Context,
                                   args: ArrayList<*>?,
                                   result: Result) {
            up.unregisterApp(context)
            result.success(true)
        }

        @JvmStatic
        private fun getDistributorsList(context: Context, result: Result) {
            val dist = up.getDistributors(context)

            if (dist.isNotEmpty()) {
                result.success(dist)
            } else {
                result.error("UNAVAILABLE", null, null)
            }
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
        val args = call.arguments<ArrayList<*>>()
        when(call.method) {
            "initializeService" -> {
                initializeService(mContext!!, args)
                result.success(true)
            }
            "register" -> register(mContext!!, args, result)
            "registerAppWithDialog" -> registerAppWithDialog(mActivity!!,args,result)
            "unregister" -> unregister(mContext!!, args, result)
            "getDistributors" -> getDistributorsList(mContext!!, result)
            else -> result.notImplemented()
        }
    }
}
