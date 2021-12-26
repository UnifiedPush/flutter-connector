package org.unifiedpush.flutter.connector

const val PLUGIN_EVENT_INITIALIZE_BG_CALLBACK = "initializeBackgroundCallback"
const val PLUGIN_EVENT_GET_DISTRIBUTORS = "getDistributors"
const val PLUGIN_EVENT_REGISTER_APP = "registerApp"
const val PLUGIN_EVENT_UNREGISTER = "unregister"
const val PLUGIN_EVENT_GET_ALL_NATIVE_SHARED_PREFS = "getAllNativeSharedPrefs"
const val PLUGIN_CHANNEL = "org.unifiedpush.flutter.connector.PLUGIN_CHANNEL"

const val CALLBACK_DISPATCHER_HANDLE_KEY = "callback_dispatch_handler"
const val CALLBACK_CHANNEL = "org.unifiedpush.flutter.connector.CALLBACK_CHANNEL"

const val SHARED_PREFERENCES_KEY = "flutter-connector_plugin_cache"

const val TOKENS_MAP_SHARED_PREFERENCES_KEY = "flutter-connector_tokens_map"

const val ACTION_NEW_ENDPOINT = "org.unifiedpush.android.connector.NEW_ENDPOINT"
const val ACTION_REGISTRATION_FAILED = "org.unifiedpush.android.connector.REGISTRATION_FAILED"
const val ACTION_REGISTRATION_REFUSED = "org.unifiedpush.android.connector.REGISTRATION_REFUSED"
const val ACTION_UNREGISTERED = "org.unifiedpush.android.connector.UNREGISTERED"
const val ACTION_MESSAGE = "org.unifiedpush.android.connector.MESSAGE"

const val ACTION_REGISTER = "org.unifiedpush.android.distributor.REGISTER"
const val ACTION_UNREGISTER = "org.unifiedpush.android.distributor.UNREGISTER"
const val ACTION_MESSAGE_ACK = "org.unifiedpush.android.distributor.MESSAGE_ACK"

const val EXTRA_APPLICATION = "application"
const val EXTRA_TOKEN = "token"
const val EXTRA_ENDPOINT = "endpoint"
const val EXTRA_MESSAGE = "message"
const val EXTRA_MESSAGE_ID = "id"

const val EXTRA_CALLBACK_EVENT = "event"
const val EXTRA_CALLBACK_EVENT_MESSAGE = "message"
const val EXTRA_CALLBACK_EVENT_NEW_ENDPOINT = "new_endpoint"
const val EXTRA_CALLBACK_EVENT_UNREGISTERED = "unregistered"
const val EXTRA_CALLBACK_EVENT_INITIALIZED = "initialized"
