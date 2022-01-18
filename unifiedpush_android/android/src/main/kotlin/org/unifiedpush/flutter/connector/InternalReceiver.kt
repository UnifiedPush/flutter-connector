package org.unifiedpush.flutter.connector

import android.content.Context
import android.content.Intent
import org.unifiedpush.android.connector.MessagingReceiver

/***
 * Handler used when there is a callback
 */

class InternalReceiver : MessagingReceiver() {
    override fun onMessage(context: Context?, message: String, instance: String) {
        val broadcastIntent = Intent()
        broadcastIntent.`package` = context!!.packageName
        broadcastIntent.action = INT_ACTION_MESSAGE
        broadcastIntent.putExtra(INT_EXTRA_MESSAGE, message)
        broadcastIntent.putExtra(INT_EXTRA_INSTANCE, instance)
        context.sendBroadcast(broadcastIntent)
    }

    override fun onNewEndpoint(context: Context?, endpoint: String, instance: String) {
        val broadcastIntent = Intent()
        broadcastIntent.`package` = context!!.packageName
        broadcastIntent.action = INT_ACTION_NEW_ENDPOINT
        broadcastIntent.putExtra(INT_EXTRA_ENDPOINT, endpoint)
        broadcastIntent.putExtra(INT_EXTRA_INSTANCE, instance)
        context.sendBroadcast(broadcastIntent)
    }

    override fun onRegistrationFailed(context: Context?, instance: String) {
        val broadcastIntent = Intent()
        broadcastIntent.`package` = context!!.packageName
        broadcastIntent.action = INT_ACTION_REGISTRATION_FAILED
        broadcastIntent.putExtra(INT_EXTRA_INSTANCE, instance)
        context.sendBroadcast(broadcastIntent)
    }

    override fun onUnregistered(context: Context?, instance: String) {
        val broadcastIntent = Intent()
        broadcastIntent.`package` = context!!.packageName
        broadcastIntent.action = INT_ACTION_UNREGISTERED
        broadcastIntent.putExtra(INT_EXTRA_INSTANCE, instance)
        context.sendBroadcast(broadcastIntent)
    }
}
