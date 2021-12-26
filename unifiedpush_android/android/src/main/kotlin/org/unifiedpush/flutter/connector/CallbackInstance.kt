package org.unifiedpush.flutter.connector

import java.util.ArrayDeque

class CallbackInstance (token: String){
    val token: String?
    internal val messageQueue = ArrayDeque<String>()
    internal val endpointQueue = ArrayDeque<String>()
    internal val unregisteredQueue = ArrayDeque<String>()
    init {
        this.token = token
    }
}
