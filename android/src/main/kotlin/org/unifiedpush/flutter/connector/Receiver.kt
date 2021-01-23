package org.unifiedpush.flutter.connector

import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.view.FlutterMain
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.MessagingReceiverHandler

val handler = object : MessagingReceiverHandler {

    override fun onMessage(context: Context?, message: String) {
        Log.d("Receiver","OnMessage")
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.channel != null){
            Plugin.channel?.invokeMethod("onMessage", message)
        } else {
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, CALLBACK_EVENT_MESSAGE)
            intent.putExtra(EXTRA_CALLBACK_DATA, message)
            CallbackService.enqueueWork(context, intent)
        }
    }

    override fun onNewEndpoint(context: Context?, endpoint: String) {
        Log.d("Receiver","OnNewEndpoint")
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.channel != null) {
            Plugin.channel?.invokeMethod("onNewEndpoint", endpoint)
        } else {
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, CALLBACK_EVENT_NEW_ENDPOINT)
            intent.putExtra(EXTRA_CALLBACK_DATA, endpoint)
            CallbackService.enqueueWork(context, intent)
        }
    }

    override fun onRegistrationFailed(context: Context?) {
        Log.d("Receiver","OnRegistrationFailed")
        Plugin.channel?.invokeMethod("onRegistrationFailed", null)
    }

    override fun onRegistrationRefused(context: Context?) {
        Log.d("Receiver","OnRegistrationRefused")
        Plugin.channel?.invokeMethod("onRegistrationRefused", null)
    }

    override fun onUnregistered(context: Context?) {
        Log.d("Receiver","OnUnregistered")
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        if (Plugin.channel != null) {
            Plugin.channel?.invokeMethod("onUnregistered", null)
        } else {
            val intent = Intent(context, CallbackService::class.java)
            intent.putExtra(EXTRA_CALLBACK_EVENT, CALLBACK_EVENT_UNREGISTERED)
            CallbackService.enqueueWork(context, intent)
        }
    }
}

class Receiver : MessagingReceiver(handler)
