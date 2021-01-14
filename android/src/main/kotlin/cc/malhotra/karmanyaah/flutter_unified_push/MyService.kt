package cc.malhotra.karmanyaah.flutter_unified_push


import android.content.Context
import android.content.Intent
import android.os.IBinder
import android.os.PowerManager
import android.os.Handler
import android.util.Log
import androidx.core.app.JobIntentService
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments
import java.util.ArrayDeque
import java.util.concurrent.atomic.AtomicBoolean
import java.util.UUID

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback


class FlutterUnifiedPushService : MethodCallHandler, JobIntentService() {
    private val queue = ArrayDeque<String>()
    private lateinit var mBackgroundChannel: MethodChannel
    private lateinit var mContext: Context

    companion object {
        @JvmStatic
        private val TAG = "FlutterUnifiedPushService"
        @JvmStatic
        private val JOB_ID = UUID.randomUUID().mostSignificantBits.toInt()
        @JvmStatic
        private var sBackgroundFlutterEngine: FlutterEngine? = null
        @JvmStatic
        private val sServiceStarted = AtomicBoolean(false)

        @JvmStatic
        private lateinit var sPluginRegistrantCallback: PluginRegistrantCallback

        @JvmStatic
        fun enqueueWork(context: Context, work: Intent) {
            enqueueWork(context, FlutterUnifiedPushService::class.java, JOB_ID, work)
        }

        @JvmStatic
        fun setPluginRegistrant(callback: PluginRegistrantCallback) {
            sPluginRegistrantCallback = callback
        }
    }

    private fun startService(context: Context) {
        synchronized(sServiceStarted) {
            mContext = context
            if (sBackgroundFlutterEngine == null) {
                val callbackHandle = context.getSharedPreferences(
                        FlutterUnifiedPushPlugin.SHARED_PREFERENCES_KEY,
                        Context.MODE_PRIVATE)
                        .getLong(FlutterUnifiedPushPlugin.CALLBACK_DISPATCHER_HANDLE_KEY, 0)
                if (callbackHandle == 0L) {
                    Log.e(TAG, "Fatal: no callback registered")
                    return
                }

                val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
                if (callbackInfo == null) {
                    Log.e(TAG, "Fatal: failed to find callback")
                    return
                }
                Log.i(TAG, "Starting FlutterUnifiedPushService...")
                sBackgroundFlutterEngine = FlutterEngine(context)

                val args = DartCallback(
                        context.getAssets(),
                        FlutterMain.findAppBundlePath(context)!!,
                        callbackInfo
                )
                sBackgroundFlutterEngine!!.getDartExecutor().executeDartCallback(args)
//                IsolateHolderService.setBackgroundFlutterEngine(sBackgroundFlutterEngine)
            }
        }
        mBackgroundChannel = MethodChannel(sBackgroundFlutterEngine!!.getDartExecutor().getBinaryMessenger(),
                "flutter_unified_push.method.background_channel")
        mBackgroundChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when(call.method) {
            "FlutterUnifiedPushService.initialized" -> {
                synchronized(sServiceStarted) {
                    while (!queue.isEmpty()) {
                        mBackgroundChannel.invokeMethod("", queue.remove())
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

        val callbackHandle = intent.getLongExtra(FlutterUnifiedPushPlugin.CALLBACK_HANDLE_KEY, 0)
val message = intent.getStringExtra("message")

    //    Log.d(TAG, message)
//        if (geofencingEvent.hasError()) {
//            Log.e(TAG, "Geofencing error: ${geofencingEvent.errorCode}")
//            return
//        }
//
//        // Get the transition type.
//        val geofenceTransition = geofencingEvent.geofenceTransition
//
//        // Get the geofences that were triggered. A single event can trigger
//        // multiple geofences.
//        val triggeringGeofences = geofencingEvent.triggeringGeofences.map {
//            it.requestId
//        }
//
//        val location = geofencingEvent.triggeringLocation
//        val locationList = listOf(location.latitude,
//                location.longitude)
//        val geofenceUpdateList = listOf(callbackHandle,
//                triggeringGeofences,
//                locationList,
//                geofenceTransition)
//
        synchronized(sServiceStarted) {
            if (!sServiceStarted.get()) {
                // Queue up geofencing events while background isolate is starting
                queue.add(message)
            } else {
                // Callback method name is intentionally left blank.
                Handler(mContext.mainLooper).post { mBackgroundChannel.invokeMethod("", message )}
            }
        }
    }
}
