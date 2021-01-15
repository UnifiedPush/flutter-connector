package org.unifiedpush.flutter.connector
//
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.view.FlutterMain
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.MessagingReceiverHandler

//


val handler = object : MessagingReceiverHandler {

    private val TAG = "FlutterUnifiedPushReceiver"
    
    override fun onMessage(context: Context?, message: String) {
//        event = "c"
//         val dict = URLDecoder.decode(message,"UTF-8").split("&")
//         val params= dict.associate { try{it.split("=")[0] to it.split("=")[1]}catch (e: Exception){"" to ""} }
//         val text = params["message"]?: "New notification"
//         val priority = params["priority"]?.toInt()?: 8
//         val title = params["title"]?: "UP - Example"
        // Notifier(context!!).sendNotification(title,text,priority)
        FlutterMain.startInitialization(context!!)
        FlutterMain.ensureInitializationComplete(context, null)
        val intent = Intent(context, Receiver::class.java)

        intent.putExtra("message", message)
        Log.d(TAG, "onMessage")
        Service.enqueueWork(context, intent)
    }

    override fun onNewEndpoint(context: Context?, endpoint: String) {
//        event = "c"
        // print(endpoint)
        Log.d(TAG, endpoint)
Log.d(TAG, Plugin.toString())

Log.d(TAG, Plugin?.channel.toString())
        if (Plugin?.channel != null)
            Plugin?.channel!!.invokeMethod("onNewEndpoint", endpoint)
        else Log.e(TAG, "channel is null")

    }

    override fun onRegistrationFailed(context: Context?) {
        Plugin.channel?.invokeMethod("onRegistrationFailed", null)
    }
    override fun onRegistrationRefused(context: Context?) {
        Plugin.channel?.invokeMethod("onRegistrationRefused", null)
    }

    override fun onUnregistered(context: Context?) {
//        event = "c"
        Plugin.channel?.invokeMethod("onUnregister", null)
    }
}

class Receiver : MessagingReceiver(handler)
