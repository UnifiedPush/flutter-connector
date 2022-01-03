package org.unifiedpush.flutter.connector

const val PLUGIN_EVENT_INITIALIZE_BG_CALLBACK = "initializeBackgroundCallback"
const val PLUGIN_EVENT_GET_DISTRIBUTORS = "getDistributors"
const val PLUGIN_EVENT_GET_DISTRIBUTOR = "getDistributor"
const val PLUGIN_EVENT_SAVE_DISTRIBUTOR = "saveDistributor"
const val PLUGIN_EVENT_REGISTER_APP = "registerApp"
const val PLUGIN_EVENT_UNREGISTER = "unregister"
const val PLUGIN_EVENT_GET_ALL_NATIVE_SHARED_PREFS = "getAllNativeSharedPrefs"
const val PLUGIN_CHANNEL = "org.unifiedpush.flutter.connector.PLUGIN_CHANNEL"

const val CALLBACK_DISPATCHER_HANDLE_KEY = "callback_dispatch_handler"
const val CALLBACK_CHANNEL = "org.unifiedpush.flutter.connector.CALLBACK_CHANNEL"

const val SHARED_PREFERENCES_KEY = "flutter-connector_plugin_cache"

const val PREF_TOKEN_DISTRIB_MAP = "unifiedpush_token_distrib_map"

const val EXTRA_CALLBACK_EVENT = "event"
const val EXTRA_CALLBACK_MESSAGE = "data.message"
const val EXTRA_CALLBACK_ENDPOINT = "data.endpoint"
const val EXTRA_CALLBACK_INSTANCE = "data.instance"

const val CALLBACK_EVENT_MESSAGE = "message"
const val CALLBACK_EVENT_NEW_ENDPOINT = "new_endpoint"
const val CALLBACK_EVENT_UNREGISTERED = "unregistered"
const val CALLBACK_EVENT_INITIALIZED = "initialized"