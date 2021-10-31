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
    var withReceiverChannel: MethodChannel? = null

    companion object {

        var withCallbackChannel: MethodChannel? = null
        private var up = Registration()

        /**
         * To:
         * 1. ask for the distributor the user want to use
         * 2. saveIt
         * 3. register the end user application to the distributor
         * You can use registerAppWithDialog()
         */
        @JvmStatic
        private fun registerAppWithDialog(context: Context,
                                          args: ArrayList<*>?,
                                          result: Result?) {
            val instance: String = (args?.get(0) ?: "") as String
            if (instance.isEmpty()) {
                up.registerAppWithDialog(context)
            } else {
                up.registerAppWithDialog(context, instance)
            }
            result?.success(null)
        }

        /**
         * If you prefer doing it by yourself:
         * 1. getDistributors() gives the distributors list
         * 2. saveDistributor(distributor) saves the user's distributor
         * 3. registerApp() register the end user application to the distributor
         */
        @JvmStatic
        private fun getDistributors(context: Context,
                                    result: Result?){
            val distributors = up.getDistributors(context)
            result?.success(distributors)
        }

        @JvmStatic
        private fun getDistributor(context: Context,
                                    result: Result?){
            val distributor = up.getDistributor(context)
            result?.success(distributor)
        }

        @JvmStatic
        private fun saveDistributor(context: Context,
                                    args: ArrayList<*>?,
                                    result: Result?){
            val distributor = args!![0] as String
            up.saveDistributor(context,distributor)
            result?.success(true)
        }

        @JvmStatic
        private fun registerApp(context: Context,
                                args: ArrayList<*>?,
                                result: Result?){
            val instance: String = (args?.get(0) ?: "") as String
            if (instance.isEmpty()) {
                up.registerApp(context)
            } else {
                up.registerApp(context, instance)
            }
            result?.success(true)
        }

        @JvmStatic
        private fun unregister(context: Context,
                               args: ArrayList<*>?,
                               result: Result) {
            val instance: String = (args?.get(0) ?: "") as String
            if (instance.isEmpty()) {
                up.unregisterApp(context)
            } else {
                up.unregisterApp(context, instance)
            }
            result.success(true)
        }

        @JvmStatic
        private fun initializeCallback(context: Context, args: ArrayList<*>?, result: Result) {
            val callbackHandle = args?.get(0) as? Long ?: 0
            context.getSharedPreferences(SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE)
                    .edit()
                    .putLong(CALLBACK_DISPATCHER_HANDLE_KEY, callbackHandle)
                    .apply()
            result.success(true)
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
        when(call.method) {
            PLUGIN_EVENT_INITIALIZE_CALLBACK -> initializeCallback(mContext!!, args, result)
            PLUGIN_EVENT_REGISTER_APP_WITH_DIALOG -> registerAppWithDialog(mActivity!!, args, result)
            PLUGIN_EVENT_GET_DISTRIBUTORS -> getDistributors(mActivity!!, result)
            PLUGIN_EVENT_GET_DISTRIBUTOR -> getDistributor(mActivity!!, result)
            PLUGIN_EVENT_SAVE_DISTRIBUTOR -> saveDistributor(mActivity!!, args, result)
            PLUGIN_EVENT_REGISTER_APP -> registerApp(mActivity!!, args, result)
            PLUGIN_EVENT_UNREGISTER -> unregister(mActivity!!, args, result)
            else -> result.notImplemented()
        }
    }
}
