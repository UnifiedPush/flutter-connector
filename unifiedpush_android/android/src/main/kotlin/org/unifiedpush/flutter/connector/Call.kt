package org.unifiedpush.flutter.connector

import java.io.Serializable

data class Call(val method: String, val data: Map<String, Serializable?>)
