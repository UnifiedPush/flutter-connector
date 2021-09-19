package org.unifiedpush.flutter.connector

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.view.FlutterMain
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.MessagingReceiverHandler

/***
 * Handler used when there is a callback
 */

val handler = object : MessagingReceiverHandler {

    override fun onMessage(context: Context?, message: String, instance: String) {
        Log.d("Receiver","OnMessage")
        val data = mapOf("instance" to instance,
            "message" to message)
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.withCallbackChannel != null && !CallbackService.sServiceStarted.get()){
            Log.d("Receiver","foregroundChannel")
            Plugin.withCallbackChannel?.invokeMethod("onMessage", data)
        } else {
            Log.d("Receiver","CallbackChannel")
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, CALLBACK_EVENT_MESSAGE)
            intent.putExtra(EXTRA_CALLBACK_INSTANCE, instance)
            intent.putExtra(EXTRA_CALLBACK_MESSAGE, message)
            CallbackService.enqueueWork(context, intent)
        }
    }

    override fun onNewEndpoint(context: Context?, endpoint: String, instance: String) {
        Log.d("Receiver","OnNewEndpoint")
        val data = mapOf("instance" to instance,
            "endpoint" to endpoint)
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.withCallbackChannel != null && !CallbackService.sServiceStarted.get()) {
            Plugin.withCallbackChannel?.invokeMethod("onNewEndpoint", data)
        } else {
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, CALLBACK_EVENT_NEW_ENDPOINT)
            intent.putExtra(EXTRA_CALLBACK_INSTANCE, instance)
            intent.putExtra(EXTRA_CALLBACK_ENDPOINT, endpoint)
            CallbackService.enqueueWork(context, intent)
        }
    }

    override fun onRegistrationFailed(context: Context?, instance: String) {
        Log.d("Receiver","OnRegistrationFailed")
        val data = mapOf("instance" to instance)
        Plugin.withCallbackChannel?.invokeMethod("onRegistrationFailed", data)
    }

    override fun onRegistrationRefused(context: Context?, instance: String) {
        Log.d("Receiver","OnRegistrationRefused")
        val data = mapOf("instance" to instance)
        Plugin.withCallbackChannel?.invokeMethod("onRegistrationRefused", data)
    }

    override fun onUnregistered(context: Context?, instance: String) {
        Log.d("Receiver","OnUnregistered")
        val data = mapOf("instance" to instance)
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.withCallbackChannel != null && !CallbackService.sServiceStarted.get()) {
            Plugin.withCallbackChannel?.invokeMethod("onUnregistered", data)
        } else {
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, CALLBACK_EVENT_UNREGISTERED)
            intent.putExtra(EXTRA_CALLBACK_INSTANCE, instance)
            CallbackService.enqueueWork(context, intent)
        }
    }
}

class Receiver : MessagingReceiver(handler) {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (Plugin.isWithCallback(context!!)) {
            super.onReceive(context, intent)
        }
    }
}

/***
 * Handler used when the Receiver is defined in the app
 */

abstract class UnifiedPushHandler : MessagingReceiverHandler {
    abstract fun getEngine(context: Context): FlutterEngine

    private val handler = Handler()

    private fun getPlugin(context: Context): Plugin {
        val registry = getEngine(context).getPlugins()
        var plugin = registry.get(Plugin::class.java) as? Plugin
        if (plugin == null) {
            plugin = Plugin()
            registry.add(plugin)
        }
        return plugin;
    }

    override fun onMessage(context: Context?, message: String, instance: String) {
        Log.d("Receiver","OnMessage")
        val data = mapOf("instance" to instance,
            "message" to message)
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onMessage",  data)
        }
    }

    override fun onNewEndpoint(context: Context?, endpoint: String, instance: String) {
        Log.d("Receiver","OnNewEndpoint")
        val data = mapOf("instance" to instance,
            "endpoint" to endpoint)
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onNewEndpoint", data)
        }
    }

    override fun onRegistrationFailed(context: Context?, instance: String) {
        Log.d("Receiver","OnRegistrationFailed")
        val data = mapOf("instance" to instance)
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onRegistrationFailed", data)
        }
    }

    override fun onRegistrationRefused(context: Context?, instance: String) {
        Log.d("Receiver","OnRegistrationRefused")
        val data = mapOf("instance" to instance)
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onRegistrationRefused", data)
        }
    }

    override fun onUnregistered(context: Context?, instance: String) {
        Log.d("Receiver","OnUnregistered")
        val data = mapOf("instance" to instance)
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onUnregistered", data)
        }
    }
}
