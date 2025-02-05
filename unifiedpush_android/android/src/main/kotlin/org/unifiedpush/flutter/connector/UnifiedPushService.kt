package org.unifiedpush.flutter.connector

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.unifiedpush.android.connector.FailedReason
import org.unifiedpush.android.connector.PushService
import org.unifiedpush.android.connector.data.PushEndpoint
import org.unifiedpush.android.connector.data.PushMessage
import org.unifiedpush.flutter.connector.Plugin.Companion.dispatcher

/**
 * Implementation of [PushService] for the flutter library, forward events to
 * flutter engine through [Plugin].
 *
 * If you need to use your own service, for instance to control the flutter
 * engine, by overriding [getEngine], please update your Manifest:
 *
 * ```xml
 * <manifest xmlns:android="http://schemas.android.com/apk/res/android"
 *     xmlns:tools="http://schemas.android.com/tools">
 *     <application "...">
 *         <!-- ... -->
 *         <service android:name="org.unifiedpush.flutter.connector.UnifiedPushService"
 *             tools:node="replace">
 *         </service>
 *     </application>
 * </manifest>
 * ```
 */
open class UnifiedPushService: PushService() {

    /**
     * Returns [FlutterEngine] used when creating [Plugin]
     * if it doesn't exist yet. Plugin is then added to its
     * plugins registry
     */
    open fun getEngine(context: Context): FlutterEngine {
        return FlutterEngine(context).apply {
            localizationPlugin.sendLocalesToFlutter(
                context.resources.configuration
            )
            dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
        }
    }

    private fun getPlugin(context: Context): Plugin {
        return synchronized(lock) {
            Plugin.instance ?: run {
                val registry = getEngine(context).plugins
                (registry.get(Plugin::class.java) as? Plugin)
                    ?: Plugin().also { registry.add(it) }
            }
        }
    }

    override fun onMessage(message: PushMessage, instance: String) {
        Log.d(TAG, "onMessage")
        val data = mapOf(
            PLUGIN_ARG_INSTANCE to instance,
            PLUGIN_ARG_MESSAGE_CONTENT to message.content,
            PLUGIN_ARG_MESSAGE_DECRYPTED to message.decrypted,
        )
        val calls = getPlugin(this).calls
        CoroutineScope(dispatcher).launch {
            calls.emit(Call(PLUGIN_CALL_MESSAGE, data))
            coroutineContext.cancel()
        }
    }

    override fun onNewEndpoint(endpoint: PushEndpoint, instance: String) {
        Log.d(TAG, "onNewEndpoint")
        val data = mapOf(
            PLUGIN_ARG_INSTANCE to instance,
            PLUGIN_ARG_ENDPOINT_URL to endpoint.url,
            PLUGIN_ARG_ENDPOINT_KEY_PUBKEY to endpoint.pubKeySet?.pubKey,
            PLUGIN_ARG_ENDPOINT_KEY_AUTH to endpoint.pubKeySet?.auth
        )
        val calls = getPlugin(this).calls
        CoroutineScope(dispatcher).launch {
            calls.emit(Call(PLUGIN_CALL_NEW_ENDPOINT, data))
            coroutineContext.cancel()
        }
    }

    override fun onRegistrationFailed(reason: FailedReason, instance: String) {
        Log.d(TAG, "onRegistrationFailed")
        val data = mapOf(
            PLUGIN_ARG_INSTANCE to instance,
            PLUGIN_ARG_REASON to reason.name
        )
        val calls = getPlugin(this).calls
        CoroutineScope(dispatcher).launch {
            calls.emit(Call(PLUGIN_CALL_REGISTRATION_FAILED, data))
            coroutineContext.cancel()
        }
    }

    override fun onUnregistered(instance: String) {
        Log.d(TAG, "onUnregistered")
        val data = mapOf(PLUGIN_ARG_INSTANCE to instance)
        val calls = getPlugin(this).calls
        CoroutineScope(dispatcher).launch {
            calls.emit(Call(PLUGIN_CALL_UNREGISTERED, data))
            coroutineContext.cancel()
        }
    }

    internal companion object {
        private val lock = Object()
        private const val TAG = "UnifiedPushService"
    }
}