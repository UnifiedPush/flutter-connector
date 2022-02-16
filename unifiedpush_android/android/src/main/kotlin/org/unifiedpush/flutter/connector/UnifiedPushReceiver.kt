package org.unifiedpush.flutter.connector

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.PowerManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine

/**
 * This receiver has to be declared on the application side
 * and getEngine has to be overriden to get the FlutterEngine
 */

private const val TAG = "UnifiedPushReceiver"

open class UnifiedPushReceiver : BroadcastReceiver() {
    private val handler = Handler()

    open fun getEngine(context: Context): FlutterEngine? {
        return null
    }

    private fun getPlugin(context: Context): Plugin {
        val registry = getEngine(context)!!.plugins
        var plugin = registry.get(Plugin::class.java) as? Plugin
        if (plugin == null) {
            plugin = Plugin()
            registry.add(plugin)
        }
        return plugin;
    }

    private fun onMessage(context: Context, message: ByteArray, instance: String) {
        Log.d(TAG, "OnMessage")
        val data = mapOf("instance" to instance,
            "message" to message)
        handler.post {
            getPlugin(context).pluginChannel?.invokeMethod("onMessage",  data)
        }
    }

    private fun onNewEndpoint(context: Context, endpoint: String, instance: String) {
        Log.d(TAG, "OnNewEndpoint")
        val data = mapOf("instance" to instance,
            "endpoint" to endpoint)
        handler.post {
            getPlugin(context).pluginChannel?.invokeMethod("onNewEndpoint", data)
        }
    }

    private fun onRegistrationFailed(context: Context, instance: String) {
        Log.d(TAG, "OnRegistrationFailed")
        val data = mapOf("instance" to instance)
        handler.post {
            getPlugin(context).pluginChannel?.invokeMethod("onRegistrationFailed", data)
        }
    }

    private fun onUnregistered(context: Context, instance: String) {
        Log.d(TAG, "OnUnregistered")
        val data = mapOf("instance" to instance)
        handler.post {
            getPlugin(context).pluginChannel?.invokeMethod("onUnregistered", data)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val wakeLock = (context.getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG).apply {
                acquire(60000L /*1min*/)
            }
        }
        val instance = intent.getStringExtra(INT_EXTRA_INSTANCE)
        when (intent.action) {
            INT_ACTION_NEW_ENDPOINT -> {
                val endpoint = intent.getStringExtra(INT_EXTRA_ENDPOINT)!!
                onNewEndpoint(context, endpoint, instance)
            }
            INT_ACTION_REGISTRATION_FAILED -> {
                onRegistrationFailed(context, instance)
            }
            INT_ACTION_UNREGISTERED -> {
                onUnregistered(context, instance)
            }
            INT_ACTION_MESSAGE -> {
                val message = intent.getByteArrayExtra(INT_EXTRA_MESSAGE)!!
                onMessage(context, message, instance)
            }
        }
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
    }
}
