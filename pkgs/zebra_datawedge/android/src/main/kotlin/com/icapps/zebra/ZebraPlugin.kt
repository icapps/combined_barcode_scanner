package com.icapps.zebra

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import com.icapps.architecture.arch.ObservableFuture
import com.icapps.architecture.arch.onMain

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ZebraPlugin */
class ZebraPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val COMMAND_CHANNEL = "zebra"
        const val EVENT_CHANNEL = "zebra/scan"

        const val INTENT_ACTION_RESULT_NOTIFICATION = "com.symbol.datawedge.api.NOTIFICATION_ACTION"
        const val INTENT_ACTION_SCAN = "com.icapps.zebra.SCAN"

        const val METHOD_GET_PROFILES = "getProfiles"
        const val METHOD_IS_SUPPORTED = "isSupported"
        const val METHOD_CREATE_PROFILE = "createProfile"
        const val ARGUMENT_PROFILE_NAME = "profileName"
        const val METHOD_START_SCAN = "startScan"
        const val METHOD_STOP_SCAN = "stopScan"
        const val METHOD_UPDATE_PROFILE = "updateProfile"
        const val ARGUMENT_CODES = "formats"
    }

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var appContext: Context
    private lateinit var intentFilter: IntentFilter
    private lateinit var dataWedgeInterface: DataWedgeInterface
    private val broadcastReceivers = mutableListOf<ScanIntentHandler>()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appContext = flutterPluginBinding.applicationContext

        dataWedgeInterface = DataWedgeInterface(appContext)
        dataWedgeInterface.init()

        intentFilter = IntentFilter().also {
            it.addAction(INTENT_ACTION_SCAN)
            it.addAction(INTENT_ACTION_RESULT_NOTIFICATION)
            it.addCategory(Intent.CATEGORY_DEFAULT)
        }

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, COMMAND_CHANNEL)
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_GET_PROFILES -> getProfiles(result)
            METHOD_IS_SUPPORTED -> checkSupported(result)
            METHOD_CREATE_PROFILE -> createProfile(call.argument<String>(ARGUMENT_PROFILE_NAME)!!, call.argument<List<String>>(ARGUMENT_CODES)!!, result)
            METHOD_START_SCAN -> startScan(result)
            METHOD_STOP_SCAN -> stopScan(result)
            METHOD_UPDATE_PROFILE -> updateProfile(call.argument<String>(ARGUMENT_PROFILE_NAME)!!, call.argument<List<String>>(ARGUMENT_CODES)!!, result)
            else -> result.notImplemented()
        }
    }

    private fun startScan(result: Result) {
        dataWedgeInterface.startScanning().dispatch(result)
    }

    private fun stopScan(result: Result) {
        dataWedgeInterface.stopScanning().dispatch(result)
    }

    private fun getProfiles(result: Result) {
        dataWedgeInterface.getProfiles().dispatch(result)
    }

    private fun checkSupported(result: Result) {
        return result.success(android.os.Build.MANUFACTURER.contains("Zebra Technologies") || android.os.Build.MANUFACTURER.contains("Motorola Solutions"))
    }

    private fun createProfile(name: String, barcodeNames: List<String>, result: Result) {
        dataWedgeInterface.createProfile(name, barcodeNames.map { BarcodeType.values().find{ code -> code.decoderName == it }!! }.toSet()).dispatch(result)
    }

    private fun updateProfile(name: String, barcodeNames: List<String>, result: Result) {
        dataWedgeInterface.updateProfile(name, barcodeNames.map { BarcodeType.values().find{ code -> code.decoderName == it }!! }.toSet()).dispatch(result)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)

        broadcastReceivers.forEach { appContext.unregisterReceiver(it) }
        broadcastReceivers.clear()

        dataWedgeInterface.destroy()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        broadcastReceivers += ScanIntentHandler(events).also {
            appContext.registerReceiver(it, intentFilter)
        }
    }

    override fun onCancel(arguments: Any?) {
        //There is no way to determine what the arguments were that created it I guess?
    }
}

private fun <T> ObservableFuture<T>.dispatch(result: Result) {
    onSuccess { result.success(it) } onFailure { result.error("err", it.message, it) } observe onMain
}
