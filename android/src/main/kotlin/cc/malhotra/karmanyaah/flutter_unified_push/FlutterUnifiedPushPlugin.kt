package cc.malhotra.karmanyaah.flutter_unified_push

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.unifiedpush.android.connector.getDistributors
import org.unifiedpush.android.connector.registerApp
import org.unifiedpush.android.connector.saveDistributor
import org.unifiedpush.android.connector.unregisterApp

lateinit var channel: MethodChannel
var event: String? = "b"

/** FlutterUnifiedPushPlugin */
class FlutterUnifiedPushPlugin : FlutterPlugin, MethodCallHandler {
    // / The MethodChannel that will the communication between Flutter and native Android
    // /
    // / This local reference serves to register the plugin with the Flutter Engine and unregister it
    // / when the Flutter Engine is detached from the Activity
    private lateinit var context: Context

    private var endpoint: String = ""
    private lateinit var registered: String

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_unified_push.method.channel")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "getDistributors") {
            val dist = getDistributors(context)

            if (dist.size != 0) {
                result.success(dist)
            } else {
                result.error("UNAVAILABLE", null, null)
            }
        } else if (call.method == "register") {
            channel.invokeMethod("onMessage", null)

            val name = call.argument<String>("name")
            saveDistributor(context, name!!)
            // print(getToken(context))
            val token = registerApp(context)
            if (!event.isNullOrEmpty()) {
                result.success(event!!)
            } else if (token.isNullOrEmpty()) {
                result.error("UNAVAILABLE", null, null)
            } else {
                result.success(token!!)
            }
//            event = "a"
        } else if (call.method == "unRegister") {
            unregisterApp(context)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

}
