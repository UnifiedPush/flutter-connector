package org.unifiedpush.flutter.example

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import org.unifiedpush.flutter.connector.UnifiedPushHandler
import org.unifiedpush.android.connector.MessagingReceiver

val receiverHandler = object : UnifiedPushHandler() {
    override fun getEngine(context: Context): FlutterEngine {
        return provideEngine(context)
    }

    fun provideEngine(context: Context): FlutterEngine {
        var engine = MainActivity.engine
        if (engine == null) {
            engine = MainActivity.provideEngine(context)
            engine.getLocalizationPlugin().sendLocalesToFlutter(
                context.getResources().getConfiguration())
            engine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault())
        }
        return engine
    }
}

class UnifiedPushReceiver : MessagingReceiver(receiverHandler)