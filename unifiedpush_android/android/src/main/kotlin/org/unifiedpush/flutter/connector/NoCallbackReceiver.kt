package org.unifiedpush.flutter.connector

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import org.unifiedpush.android.connector.*

interface EngineHandler {
    fun getEngine(context: Context): FlutterEngine
}

open class NoCallbackReceiver(private val engineHandler: EngineHandler
) : BroadcastReceiver() {
    private val handler = Handler()

    private fun getPlugin(context: Context?): Plugin {
        val registry = engineHandler.getEngine(context!!).plugins
        var plugin = registry.get(Plugin::class.java) as? Plugin
        if (plugin == null) {
            plugin = Plugin()
            registry.add(plugin)
        }
        return plugin;
    }

    private fun onMessage(context: Context?, message: String, instance: String) {
        Log.d("Receiver","OnMessage")
        val data = mapOf("instance" to instance,
            "message" to message)
        handler.post {
            getPlugin(context).withReceiverChannel?.invokeMethod("onMessage",  data)
        }
    }

    private fun onNewEndpoint(context: Context?, endpoint: String, instance: String) {
        Log.d("Receiver","OnNewEndpoint")
        val data = mapOf("instance" to instance,
            "endpoint" to endpoint)
        handler.post {
            getPlugin(context).withReceiverChannel?.invokeMethod("onNewEndpoint", data)
        }
    }

    private fun onRegistrationFailed(context: Context?, instance: String) {
        Log.d("Receiver","OnRegistrationFailed")
        val data = mapOf("instance" to instance)
        handler.post {
            getPlugin(context).withReceiverChannel?.invokeMethod("onRegistrationFailed", data)
        }
    }

    private fun onUnregistered(context: Context?, instance: String) {
        Log.d("Receiver","OnUnregistered")
        val data = mapOf("instance" to instance)
        handler.post {
            getPlugin(context).withReceiverChannel?.invokeMethod("onUnregistered", data)
        }
    }

    // This will be removed when getInstance will be opened
    // https://github.com/UnifiedPush/android-connector/issues/41
    private fun getInstance(context: Context, token: String): String? {
        val prefs = context.getSharedPreferences(PREF_MASTER, Context.MODE_PRIVATE)
        val instances = prefs.getStringSet(PREF_MASTER_INSTANCE, null)?: emptySet<String>().toMutableSet()
        instances.forEach {
            if (prefs.getString("$it/$PREF_MASTER_TOKEN","").equals(token)) {
                return it
            }
        }
        return null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        val token = intent!!.getStringExtra(EXTRA_TOKEN)
        val instance = token?.let { getInstance(context!!, it) }
            ?: return
        when (intent.action) {
            ACTION_NEW_ENDPOINT -> {
                val endpoint = intent.getStringExtra(EXTRA_ENDPOINT)!!
                onNewEndpoint(context, endpoint, instance)
            }
            ACTION_REGISTRATION_FAILED -> {
                onRegistrationFailed(context, instance)
            }
            ACTION_REGISTRATION_REFUSED -> {
                onRegistrationFailed(context, instance)
            }
            ACTION_UNREGISTERED -> {
                onUnregistered(context, instance)
            }
            ACTION_MESSAGE -> {
                val message = intent.getStringExtra(EXTRA_MESSAGE)!!
                onMessage(context, message, instance)
            }
        }
    }
}
