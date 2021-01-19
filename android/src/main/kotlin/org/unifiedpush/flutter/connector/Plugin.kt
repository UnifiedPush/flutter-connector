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

        /**
         * To:
         * 1. ask for the distributor the user want to use
         * 2. saveIt
         * 3. register the end user application to the distributor
         * You can use registerAppWithDialog()
         */
        @JvmStatic
        private fun registerAppWithDialog(context: Context,
                                          result: Result?) {
            up.registerAppWithDialog(context)
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
        private fun saveDistributor(context: Context,
                                    args: ArrayList<*>?,
                                    result: Result?){
            val distributor = args!![0] as String
            up.saveDistributor(context,distributor)
            result?.success(true)
        }

        @JvmStatic
        private fun registerApp(context: Context,
                                result: Result?){
            up.registerApp(context)
            result?.success(true)
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
        val args = call.arguments<ArrayList<*>>()
        when(call.method) {
            "registerAppWithDialog" -> registerAppWithDialog(mActivity!!, result)
            "getDistributors" -> getDistributors(mActivity!!, result)
            "saveDistributor" -> saveDistributor(mActivity!!, args, result)
            "registerApp" -> registerApp(mActivity!!, result)
            "unregister" -> unregister(mActivity!!, result)
            else -> result.notImplemented()
        }
    }
}
