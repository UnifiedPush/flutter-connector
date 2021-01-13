package cc.malhotra.karmanyaah.flutter_unified_push
//
import android.content.Context
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.MessagingReceiverHandler
//import java.util.*
//
class CustomReceiver : MessagingReceiver(handler)
val handler = object : MessagingReceiverHandler {
    override fun onMessage(context: Context?, message: String) {
//        event = "c"
//         val dict = URLDecoder.decode(message,"UTF-8").split("&")
//         val params= dict.associate { try{it.split("=")[0] to it.split("=")[1]}catch (e: Exception){"" to ""} }
//         val text = params["message"]?: "New notification"
//         val priority = params["priority"]?.toInt()?: 8
//         val title = params["title"]?: "UP - Example"
        // Notifier(context!!).sendNotification(title,text,priority)
//        FlutterMain.startInitialization(context)
//        FlutterMain.ensureInitializationComplete(context, null)
//        MyService.enqueNotification(context, intent)
        print("message" + message);
    }

    override fun onNewEndpoint(context: Context?, endpoint: String) {
//        event = "c"
//        val args = HashMap<String, String>()
//        args.put("name", context!!.packageName)
//        args.put("endpoint", endpoint)
//        // print(endpoint)
//        channel.invokeMethod("onNewEndpoint", args)
    }

    override fun onUnregistered(context: Context?) {
//        event = "c"
//    channel.invokeMethod("onUnregister", null)
    }
}
