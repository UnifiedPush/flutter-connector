package cc.malhotra.karmanyaah.flutter_unified_push

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONArray
import org.unifiedpush.android.connector.*


class FlutterUnifiedPushPlugin : ActivityAware, FlutterPlugin, MethodCallHandler {
    private var mContext : Context? = null
    private var mActivity : Activity? = null

    companion object {
        @JvmStatic
        private val TAG = "FlutterUnifiedPushPlugin"
        @JvmStatic
        val SHARED_PREFERENCES_KEY = "flutter_unified_push_plugin_cache"
        @JvmStatic
        val CALLBACK_HANDLE_KEY = "callback_handle"
        @JvmStatic
        val CALLBACK_DISPATCHER_HANDLE_KEY = "callback_dispatch_handler"

//        @JvmStatic
//        fun reRegisterAfterReboot(context: Context) {
//
//        }

        @JvmStatic
        private fun register(context: Context,
                                     args: ArrayList<*>?,
                                     result: Result?) {
//            val callbackHandle = args!![0] as Long
            val name = args!![0] as String

            saveDistributor(context, name!!)
            // print(getToken(context))
            val token = registerApp(context)
             if (token.isNullOrEmpty()) {
                result?.error("UNAVAILABLE", null, null)
            } else {
                result?.success(token!!)
            }


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

       unregisterApp(context)
        }

        @JvmStatic
        private fun getDistributorsList(context: Context, result: Result) {
            val dist = getDistributors(context)

            if (dist.size != 0) {
                result.success(dist)
            } else {
                result.error("UNAVAILABLE", null, null)
            }


        }

    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mContext = binding.getApplicationContext()
        val channel = MethodChannel(binding.getBinaryMessenger(), "flutter_unified_push.method.channel")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.getActivity()
    }

    override fun onDetachedFromActivity() {
        mActivity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        mActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        mActivity = binding.getActivity()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments<ArrayList<*>>()
        when(call.method) {
            "FlutterUnifiedPushPlugin.initializeService" -> {
                              initializeService(mContext!!, args)
                result.success(true)
            }
            "FlutterUnifiedPushPlugin.register" -> register(mContext!!,
                    args,
                    result)
            "FlutterUnifiedPushPlugin.unRegister" -> unregister(mContext!!,
                    args,
                    result)
            "FlutterUnifiedPushPlugin.getDistributors" -> getDistributorsList(mContext!!, result)
            else -> result.notImplemented()
        }
    }
}
