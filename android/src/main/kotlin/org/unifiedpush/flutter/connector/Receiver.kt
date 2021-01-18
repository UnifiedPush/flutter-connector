package org.unifiedpush.flutter.connector

import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.view.FlutterMain
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.MessagingReceiverHandler

val handler = object : MessagingReceiverHandler {

    private val TAG = "FlutterUnifiedPushReceiver"

    override fun onMessage(context: Context?, message: String) {
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        val intent = Intent(context, Receiver::class.java)

        intent.putExtra("message", message)
        Log.d(TAG, "onMessage")
        Service.enqueueWork(context, intent)
    }

    override fun onNewEndpoint(context: Context?, endpoint: String) {
        Log.d(TAG, endpoint)
        Log.d(TAG, Plugin.toString())
        Log.d(TAG, Plugin?.channel.toString())
        Plugin.channel?.invokeMethod("onNewEndpoint", endpoint)
        Log.e(TAG, "channel is null")
    }

    override fun onRegistrationFailed(context: Context?) {
        Plugin.channel?.invokeMethod("onRegistrationFailed", null)
    }

    override fun onRegistrationRefused(context: Context?) {
        Plugin.channel?.invokeMethod("onRegistrationRefused", null)
    }

    override fun onUnregistered(context: Context?) {
        Plugin.channel?.invokeMethod("onUnregistered", null)
    }
}

class Receiver : MessagingReceiver(handler)
