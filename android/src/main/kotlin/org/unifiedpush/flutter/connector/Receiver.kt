package org.unifiedpush.flutter.connector

import android.content.Context
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.MessagingReceiverHandler

val handler = object : MessagingReceiverHandler {

    override fun onMessage(context: Context?, message: String) {
        Plugin.channel?.invokeMethod("onMessage", message)
    }

    override fun onNewEndpoint(context: Context?, endpoint: String) {
        Plugin.channel?.invokeMethod("onNewEndpoint", endpoint)
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
