package org.unifiedpush.flutter.connector

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.util.Log
import androidx.core.app.JobIntentService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import java.util.*
import java.util.concurrent.atomic.AtomicBoolean

class CallbackService : MethodCallHandler, JobIntentService() {
    private val instances: MutableMap<String, CallbackInstance> = mutableMapOf()

    private lateinit var mBackgroundChannel: MethodChannel
    private lateinit var mContext: Context

    companion object {
        @JvmStatic
        private val TAG = "FlutterUPService"
        @JvmStatic
        private val JOB_ID = UUID.randomUUID().mostSignificantBits.toInt()
        @JvmStatic
        private var sBackgroundFlutterEngine: FlutterEngine? = null
        @JvmStatic
        val sServiceStarted = AtomicBoolean(false)

        @JvmStatic
        fun enqueueWork(context: Context, work: Intent) {
            enqueueWork(context, CallbackService::class.java, JOB_ID, work)
        }
    }

    private fun startService(context: Context) {
        synchronized(sServiceStarted) {
            mContext = context
            if (sBackgroundFlutterEngine == null) {
                val callbackHandle = context.getSharedPreferences(
                        SHARED_PREFERENCES_KEY,
                        Context.MODE_PRIVATE)
                        .getLong(CALLBACK_DISPATCHER_HANDLE_KEY, 0)
                if (callbackHandle == 0L) {
                    Log.e(TAG, "Fatal: no callback registered")
                    return
                }
                Log.d(TAG, callbackHandle.toString())
                val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)

                Log.i(TAG, "Starting FlutterUnifiedPushService...")
                sBackgroundFlutterEngine = FlutterEngine(context)

                val args = DartCallback(
                        context.assets,
                        FlutterMain.findAppBundlePath(context)!!,
                        callbackInfo
                )
                sBackgroundFlutterEngine!!.dartExecutor.executeDartCallback(args)
            }
        }
        mBackgroundChannel = MethodChannel(
                sBackgroundFlutterEngine!!.dartExecutor.binaryMessenger,
                CALLBACK_CHANNEL
        )
        mBackgroundChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when(call.method) {
            EXTRA_CALLBACK_EVENT_INITIALIZED -> {
                Log.i("CallbackService","EVENT_INITIALIZED")
                synchronized(sServiceStarted) {
                    instances.values.forEach { instance ->
                        instance.unregisteredQueue.poll()?.let {
                            Log.d("CallbackService", "unregisteredQueue not empty")
                            mBackgroundChannel.invokeMethod(
                                EXTRA_CALLBACK_EVENT_UNREGISTERED,
                                mapOf("token" to instance.token)
                            )
                            instance.unregisteredQueue.clear()
                            instance.endpointQueue.clear()
                            instance.messageQueue.clear()
                        }
                        instance.endpointQueue.removeAll {
                            Log.d("CallbackService", "endpointQueue not empty")
                            mBackgroundChannel.invokeMethod(
                                EXTRA_CALLBACK_EVENT_NEW_ENDPOINT,
                                mapOf("token" to instance.token, "endpoint" to it)
                            )
                            true
                        }
                        instance.messageQueue.removeAll {
                            Log.d("CallbackService", "messageQueue not empty")
                            mBackgroundChannel.invokeMethod(
                                EXTRA_CALLBACK_EVENT_MESSAGE,
                                mapOf("token" to instance.token, "message" to it)
                            )
                            true
                        }
                    }
                    sServiceStarted.set(true)
                }
            }
            else -> {
                result.notImplemented()
                return
            }
        }
        result.success(null)
    }

    override fun onCreate() {
        super.onCreate()
        startService(this)
    }

    override fun onHandleWork(intent: Intent) {
        val event = intent.getStringExtra(EXTRA_CALLBACK_EVENT)?: ""
        val token = intent.getStringExtra(EXTRA_TOKEN)?: ""
        val message = intent.getStringExtra(EXTRA_MESSAGE)?: ""
        val endpoint = intent.getStringExtra(EXTRA_ENDPOINT)?: ""
        if (!instances.keys.contains(token))
            instances[token] = CallbackInstance(token)

        val instance = instances[token]!!

        synchronized(sServiceStarted) {
            if (!sServiceStarted.get()) {
                Log.d("CallbackService","Not yet started")
                when(event){
                    EXTRA_CALLBACK_EVENT_MESSAGE -> {
                        instance.messageQueue.add(message)
                    }
                    EXTRA_CALLBACK_EVENT_NEW_ENDPOINT -> {
                        instance.endpointQueue.clear()
                        instance.endpointQueue.add(endpoint)
                    }
                    EXTRA_CALLBACK_EVENT_UNREGISTERED -> {
                        instance.unregisteredQueue.clear()
                        instance.unregisteredQueue.add(null)
                    }
                    else -> {}
                }
            } else {
                Handler(mContext.mainLooper).post {
                    val data = mapOf(
                        "token" to token,
                        "message" to message,
                        "endpoint" to endpoint
                    )
                    mBackgroundChannel.invokeMethod(event, data)
                }
            }
        }
    }
}
