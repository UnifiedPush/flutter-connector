package org.unifiedpush.flutter.connector

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Plugin : ActivityAware, FlutterPlugin, MethodCallHandler {
    private var mContext : Context? = null
    private var mActivity : Activity? = null
    var withReceiverChannel: MethodChannel? = null

    companion object {

        var withCallbackChannel: MethodChannel? = null

        @JvmStatic
        private fun getDistributors(context: Context,
                                    result: Result?){
            val intent = Intent()
            intent.action = ACTION_REGISTER
            val distributors = context.packageManager.queryBroadcastReceivers(intent, 0).mapNotNull {
                if (it.activityInfo.exported || it.activityInfo.packageName == context.packageName) {
                    val packageName = it.activityInfo.packageName
                    Log.d("UP-Registration", "Found distributor with package name $packageName")
                    packageName
                } else {
                    null
                }
            }

            result?.success(distributors)
        }

        @JvmStatic
        private fun registerApp(context: Context,
                                args: ArrayList<*>?,
                                result: Result?){
            val distributor = args!![0] as String
            val token = args!![1] as String

            val broadcastIntent = Intent()
            broadcastIntent.`package` = distributor
            broadcastIntent.action = ACTION_REGISTER
            broadcastIntent.putExtra(EXTRA_TOKEN, token)
            broadcastIntent.putExtra(EXTRA_APPLICATION, context.packageName)
            context.sendBroadcast(broadcastIntent)

            context.getSharedPreferences(TOKENS_MAP_SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
            .edit()
            .putString(token, distributor)
            .apply()

            result?.success(true)
        }

        @JvmStatic
        private fun unregister(context: Context,
                               args: ArrayList<*>?,
                               result: Result) {
            val distributor = args!![0] as String
            val token = args!![1] as String

            val broadcastIntent = Intent()
            broadcastIntent.`package` = distributor
            broadcastIntent.action = ACTION_UNREGISTER
            broadcastIntent.putExtra(EXTRA_TOKEN, token)
            context.sendBroadcast(broadcastIntent)

            context.getSharedPreferences(TOKENS_MAP_SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
            .edit()
            .remove(token)
            .apply()

            result.success(true)
        }

        @JvmStatic
        private fun initializeBackgroundCallback(context: Context, args: ArrayList<*>?, result: Result) {
            val callbackHandle = args?.get(0) as? Long ?: 0
            context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
                    .edit()
                    .putLong(CALLBACK_DISPATCHER_HANDLE_KEY, callbackHandle)
                    .apply()
            result.success(true)
        }

        private fun getAllNativeSharedPrefs(context: Context,
                               args: ArrayList<*>?,
                               result: Result) {
            val prefs = context.getSharedPreferences("UP-lib", Context.MODE_PRIVATE)
            val allPrefs = prefs?.all

            if (allPrefs != null) {
                val sanitizedAllPrefs = mutableMapOf<String, Any?>()
                for ((k, v) in allPrefs) {
                    if (v is Collection<*>) {
                        val l = mutableListOf<Any?>()
                        l.addAll(v)
                        sanitizedAllPrefs.put(k, l)
                    } else {
                        sanitizedAllPrefs.put(k, v)
                    }
                }
                result.success(sanitizedAllPrefs)
            }
        }

        fun isWithCallback(context: Context): Boolean {
            val method = context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
                    .getLong(CALLBACK_DISPATCHER_HANDLE_KEY, 0)
            Log.d("Plugin","isWithCallback: ${method > 0}")
            return method > 0
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("Plugin", "onAttachedToEngine")
        mContext = binding.applicationContext
        withReceiverChannel = MethodChannel(binding.binaryMessenger, PLUGIN_CHANNEL)
        withReceiverChannel?.setMethodCallHandler(this)
        withCallbackChannel = MethodChannel(binding.binaryMessenger, PLUGIN_CHANNEL)
        withCallbackChannel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("Plugin", "onDetachedFromEngine")
        withReceiverChannel?.setMethodCallHandler(null)
        withCallbackChannel?.setMethodCallHandler(null)
        mContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d("Plugin", "onAttachedToActivity")
        mActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        Log.d("Plugin", "onDetachedFromActivity")
        mActivity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d("Plugin", "onDetachedFromActivityForConfigChanges")
        mActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d("Plugin", "onReattachedToActivityForConfigChanges")
        mActivity = binding.activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d("Plugin","Method: ${call.method}")
        val args = call.arguments<ArrayList<*>>()
        // TODO mContext vs mActivity as context ?
        when(call.method) {
            PLUGIN_EVENT_INITIALIZE_BG_CALLBACK -> initializeBackgroundCallback(mContext!!, args, result)
            PLUGIN_EVENT_GET_DISTRIBUTORS -> getDistributors(mActivity!!, result)
            PLUGIN_EVENT_REGISTER_APP -> registerApp(mActivity!!, args, result)
            PLUGIN_EVENT_UNREGISTER -> unregister(mActivity!!, args, result)
            PLUGIN_EVENT_GET_ALL_NATIVE_SHARED_PREFS -> getAllNativeSharedPrefs(mActivity!!, args, result)
            else -> result.notImplemented()
        }
    }
}
