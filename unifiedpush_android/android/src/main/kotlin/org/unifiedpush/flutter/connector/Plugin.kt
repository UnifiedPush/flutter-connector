package org.unifiedpush.flutter.connector

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch
import org.unifiedpush.android.connector.UnifiedPush as up

class Plugin : FlutterPlugin, MethodCallHandler {
    private var mContext : Context? = null
    private var job: Job? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pluginChannel: MethodChannel? = null
    // Allow up to 20 calls during initialization
    val calls = MutableSharedFlow<Call>(replay = 20)

    init {
        instance = this
    }

    /**
     * Get list of distributors
     *
     * argv1 = features (not used for android at this moment)
     */
    private fun getDistributors(context: Context,
                                result: MethodChannel.Result){
        // We ignore features at this moment
        // val features = parseFeatures(args?.get(0))
        val distributors = up.getDistributors(context)
        result.success(distributors)
    }

    private fun getDistributor(context: Context,
                               result: MethodChannel.Result) {
        result.success(up.getAckDistributor(context))
    }

    private fun saveDistributor(context: Context,
                                args: ArrayList<String>?,
                                result: MethodChannel.Result) {
        val distributor = args?.get(0) ?: run {
            result.success(false)
            return
        }
        up.saveDistributor(context, distributor)
        result.success(true)
    }

    /**
     * Register instance
     * instance = argv1
     * features = argv2 (not used for android at this moment)
     * vapid = argv3 <= TODO
     */
    private fun registerApp(context: Context,
                            args: ArrayList<String>?,
                            result: MethodChannel.Result) {
        val instance = args?.get(0)
        // We ignore features at this moment
        // val features = parseFeatures(args?.get(1))
        Log.d(TAG, "registerApp: instance=$instance")
        if (instance.isNullOrBlank()) {
            up.register(context)
        } else {
            up.register(context, instance)
        }
        result.success(true)
    }

    private fun unregister(context: Context,
                           args: ArrayList<String>?,
                           result: MethodChannel.Result) {
        val instance = args?.get(0)
        Log.d(TAG, "unregisterApp: instance=$instance")
        if (instance.isNullOrEmpty()) {
            up.unregister(context)
        } else {
            up.unregister(context, instance)
        }
        result.success(true)
    }

    /*
    Parse Known features, at this moment we don't use any with android
    private fun parseFeatures(arg: String?): ArrayList<String> {
        val jsonArray = JSONArray(arg ?: "[]")
        val knownFeatures = arrayOf(up.FEATURE_BYTES_MESSAGE)
        return (0 until jsonArray.length()).mapNotNull {
            val feature = jsonArray.getString(it)
            if (knownFeatures.contains(feature)) {
                feature
            } else {
                null
            }
        } as ArrayList<String>
    }
    */

    private fun onInitialized(result: MethodChannel.Result) {
        // job = CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
        job = CoroutineScope(dispatcher).launch {
            Log.d(TAG, "onInitialized, collecting calls")
            calls.collect {
                coroutineContext.ensureActive()
                Log.d(TAG, "Calling ${it.method}")
                mainHandler.post {
                    pluginChannel?.invokeMethod(it.method, it.data)
                }
            }
        }
        result.success(true)
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        mContext = binding.applicationContext
        pluginChannel = MethodChannel(binding.binaryMessenger, PLUGIN_CHANNEL).apply {
            setMethodCallHandler(this@Plugin)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        pluginChannel?.setMethodCallHandler(null)
        pluginChannel = null
        mContext = null
        job?.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "Method: ${call.method}")
        val args = call.arguments<ArrayList<String>>()
        when(call.method) {
            PLUGIN_EVENT_GET_DISTRIBUTORS -> getDistributors(mContext!!,result)
            PLUGIN_EVENT_GET_DISTRIBUTOR -> getDistributor(mContext!!, result)
            PLUGIN_EVENT_SAVE_DISTRIBUTOR -> saveDistributor(mContext!!, args, result)
            PLUGIN_EVENT_REGISTER_APP -> registerApp(mContext!!, args, result)
            PLUGIN_EVENT_UNREGISTER -> unregister(mContext!!, args, result)
            PLUGIN_EVENT_INITIALIZED -> onInitialized(result)
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val TAG = "Plugin"
        var instance : Plugin? = null
        val dispatcher = Dispatchers.IO
    }
}
