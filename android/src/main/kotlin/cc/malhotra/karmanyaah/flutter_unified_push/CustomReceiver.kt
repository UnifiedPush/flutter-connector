package cc.malhotra.karmanyaah.flutter_unified_push

import android.content.Context
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.MessagingReceiverHandler

class CustomReceiver : MessagingReceiver(handler)
val handler = object : MessagingReceiverHandler {
    override fun onMessage(context: Context?, message: String) {
        event = "c"
        // val dict = URLDecoder.decode(message,"UTF-8").split("&")
        // val params= dict.associate { try{it.split("=")[0] to it.split("=")[1]}catch (e: Exception){"" to ""} }
        // val text = params["message"]?: "New notification"
        // val priority = params["priority"]?.toInt()?: 8
        // val title = params["title"]?: "UP - Example"
        // Notifier(context!!).sendNotification(title,text,priority)
    }

    override fun onNewEndpoint(context: Context?, endpoint: String) {
        event = "c"

        val name = context!!.packageName
        val args = HashMap<String, String>()
        args.put("name", name)
        args.put("endpoint", endpoint)
        print("new endpoint")
        print(endpoint)
        channel.invokeMethod("onNewEndpoint", args)
    }

    override fun onUnregistered(context: Context?) {
        event = "c"

        // val broadcastIntent = Intent()
        // broadcastIntent.`package` = context!!.packageName
        // broadcastIntent.action = UPDATE
        // broadcastIntent.putExtra("endpoint", "")
        // broadcastIntent.putExtra("registered", "false")
        // context.sendBroadcast(broadcastIntent)
    }
}
