package org.unifiedpush.flutter.connector

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.view.FlutterMain

interface MessagingReceiverHandler {
    fun onNewEndpoint(context: Context?, token: String, endpoint: String)
    fun onRegistrationFailed(context: Context?, token: String, message: String?)
    fun onRegistrationRefused(context: Context?, token: String, message: String?)
    fun onUnregistered(context: Context?, token: String)
    fun onMessage(context: Context?, token: String, message: String)
}

open class MessagingReceiver(private val handler: MessagingReceiverHandler) : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        val token = intent!!.getStringExtra(EXTRA_TOKEN)
        token!!
        when (intent.action) {
            ACTION_NEW_ENDPOINT -> {
                val endpoint = intent.getStringExtra(EXTRA_ENDPOINT)!!
                this@MessagingReceiver.handler.onNewEndpoint(context, token, endpoint)
            }
            ACTION_REGISTRATION_FAILED -> {
                val message = intent.getStringExtra(EXTRA_MESSAGE)
                Log.i("UP-registration", "Failed: $message")
                this@MessagingReceiver.handler.onRegistrationFailed(context, token, message)
            }
            ACTION_REGISTRATION_REFUSED -> {
                val message = intent.getStringExtra(EXTRA_MESSAGE)
                Log.i("UP-registration", "Refused: $message")
                this@MessagingReceiver.handler.onRegistrationRefused(context, token, message)
            }
            ACTION_UNREGISTERED -> {
                this@MessagingReceiver.handler.onUnregistered(context, token)
                // TODO check
                // up.safeRemoveDistributor(context)
            }
            ACTION_MESSAGE -> {
                val message = intent.getStringExtra(EXTRA_MESSAGE)!!
                val id = intent.getStringExtra(EXTRA_MESSAGE_ID) ?: ""
                this@MessagingReceiver.handler.onMessage(context, token, message)
                acknowledgeMessage(context!!, token, id)
            }
        }
    }

    private fun acknowledgeMessage(context: Context, token: String, id: String) {
        val distributor = context.getSharedPreferences(TOKENS_MAP_SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE).getString(token, null)

        if (distributor != null) {
            val broadcastIntent = Intent()
            broadcastIntent.`package` = distributor
            broadcastIntent.action = ACTION_MESSAGE_ACK
            broadcastIntent.putExtra(EXTRA_TOKEN, token)
            broadcastIntent.putExtra(EXTRA_MESSAGE_ID, id)
            context.sendBroadcast(broadcastIntent)
        }
    }
}
/***
 * Handler used when there is a callback
 */

val handler = object : MessagingReceiverHandler {

    override fun onMessage(context: Context?, token: String, message: String) {
        Log.d("Receiver","OnMessage")
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.withCallbackChannel != null && !CallbackService.sServiceStarted.get()){
            Log.d("Receiver","foregroundChannel")
            val data = mapOf(
                "token" to token,
                "message" to message,
            )
            Plugin.withCallbackChannel?.invokeMethod("onMessage", data)
        } else {
            Log.d("Receiver","CallbackChannel")
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, EXTRA_CALLBACK_EVENT_MESSAGE)
            intent.putExtra(EXTRA_TOKEN, token)
            intent.putExtra(EXTRA_MESSAGE, message)
            CallbackService.enqueueWork(context, intent)
        }
    }

    override fun onNewEndpoint(context: Context?, token: String, endpoint: String) {
        Log.d("Receiver","OnNewEndpoint")

        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.withCallbackChannel != null && !CallbackService.sServiceStarted.get()) {
            val data = mapOf(
                "token" to token,
                "endpoint" to endpoint
            )
            Plugin.withCallbackChannel?.invokeMethod("onNewEndpoint", data)
        } else {
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, EXTRA_CALLBACK_EVENT_NEW_ENDPOINT)
            intent.putExtra(EXTRA_TOKEN, token)
            intent.putExtra(EXTRA_ENDPOINT, endpoint)
            CallbackService.enqueueWork(context, intent)
        }
    }

    override fun onRegistrationFailed(context: Context?, token: String, message: String?) {
        Log.d("Receiver","OnRegistrationFailed")
        val data = mapOf(
            "token" to token,
            "message" to message,
        )
        Plugin.withCallbackChannel?.invokeMethod("onRegistrationFailed", data)
    }

    override fun onRegistrationRefused(context: Context?, token: String, message: String?) {
        Log.d("Receiver","OnRegistrationRefused")
        val data = mapOf(
            "token" to token,
            "message" to message,
        )
        Plugin.withCallbackChannel?.invokeMethod("onRegistrationRefused", data)
    }

    override fun onUnregistered(context: Context?, token: String) {
        Log.d("Receiver","OnUnregistered")

        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.withCallbackChannel != null && !CallbackService.sServiceStarted.get()) {
            val data = mapOf("token" to token)
            Plugin.withCallbackChannel?.invokeMethod("onUnregistered", data)
        } else {
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, EXTRA_CALLBACK_EVENT_UNREGISTERED)
            intent.putExtra(EXTRA_TOKEN, token)
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

    override fun onMessage(context: Context?, token: String, message: String) {
        Log.d("Receiver","OnMessage")
        val data = mapOf(
            "token" to token,
            "message" to message,
        )
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onMessage",  data)
        }
    }

    override fun onNewEndpoint(context: Context?, token: String, endpoint: String) {
        Log.d("Receiver","OnNewEndpoint")
        val data = mapOf(
            "token" to token,
            "endpoint" to endpoint,
        )
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onNewEndpoint", data)
        }
    }

    override fun onRegistrationFailed(context: Context?, token: String, message: String?) {
        Log.d("Receiver","OnRegistrationFailed")
        val data = mapOf(
            "token" to token,
            "message" to message,
        )
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onRegistrationFailed", data)
        }
    }

    override fun onRegistrationRefused(context: Context?, token: String, message: String?) {
        Log.d("Receiver","OnRegistrationRefused")
        val data = mapOf(
            "token" to token,
            "message" to message,
        )
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onRegistrationRefused", data)
        }
    }

    override fun onUnregistered(context: Context?, token: String) {
        Log.d("Receiver","OnUnregistered")
        val data = mapOf("token" to token)
        handler.post {
            getPlugin(context!!).withReceiverChannel?.invokeMethod("onUnregistered", data)
        }
    }
}
