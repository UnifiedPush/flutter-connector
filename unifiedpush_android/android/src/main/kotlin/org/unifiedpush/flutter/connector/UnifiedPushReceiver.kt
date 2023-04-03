package org.unifiedpush.flutter.connector

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.PowerManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * This receiver has to be declared on the application side
 * and getEngine has to be overriden to get the FlutterEngine
 */

private const val TAG = "UnifiedPushReceiver"

open class UnifiedPushReceiver : BroadcastReceiver() {
    private val handler = Handler()
    private var pluginChannel : MethodChannel? = null

    companion object {
        private var engine : FlutterEngine? = null
    }

    open fun getEngine(context: Context): FlutterEngine {
        engine?.let {
            return it
        }
        return FlutterEngine(context).apply {
            engine = this
            localizationPlugin.sendLocalesToFlutter(
                context.resources.configuration
            )
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
        }
    }

    private fun getPlugin(context: Context): Plugin {
        val registry = getEngine(context).plugins
        var plugin = registry.get(Plugin::class.java) as? Plugin
        if (plugin == null) {
            plugin = Plugin()
            registry.add(plugin)
        }
        return plugin;
    }

    private fun onMessage(message: ByteArray, instance: String) {
        Log.d(TAG, "OnMessage")
        val data = mapOf("instance" to instance,
            "message" to message)
        handler.post {
            pluginChannel?.invokeMethod("onMessage",  data)
        }
    }

    private fun onNewEndpoint(endpoint: String, instance: String) {
        Log.d(TAG, "OnNewEndpoint")
        val data = mapOf("instance" to instance,
            "endpoint" to endpoint)
        handler.post {
            pluginChannel?.invokeMethod("onNewEndpoint", data)
        }
    }

    private fun onRegistrationFailed(instance: String) {
        Log.d(TAG, "OnRegistrationFailed")
        val data = mapOf("instance" to instance)
        handler.post {
            pluginChannel?.invokeMethod("onRegistrationFailed", data)
        }
    }

    private fun onUnregistered(instance: String) {
        Log.d(TAG, "OnUnregistered")
        val data = mapOf("instance" to instance)
        handler.post {
            pluginChannel?.invokeMethod("onUnregistered", data)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val wakeLock = (context.getSystemService(Context.POWER_SERVICE) as PowerManager).run {
            newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG).apply {
                acquire(60000L /*1min*/)
            }
        }
        pluginChannel = Plugin.pluginChannel ?: getPlugin(context).getChannel()
        val instance = intent.getStringExtra(INT_EXTRA_INSTANCE)!!
        when (intent.action) {
            INT_ACTION_NEW_ENDPOINT -> {
                val endpoint = intent.getStringExtra(INT_EXTRA_ENDPOINT)!!
                onNewEndpoint(endpoint, instance)
            }
            INT_ACTION_REGISTRATION_FAILED -> {
                onRegistrationFailed(instance)
            }
            INT_ACTION_UNREGISTERED -> {
                onUnregistered(instance)
            }
            INT_ACTION_MESSAGE -> {
                val message = intent.getByteArrayExtra(INT_EXTRA_MESSAGE)!!
                onMessage(message, instance)
            }
        }
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
    }
}
