package com.icapps.unitech_scanner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class UnitechScannerPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val COMMAND_CHANNEL = "unitech_scanner"
        const val EVENT_CHANNEL = "unitech_scanner/scan"
        const val METHOD_IS_SUPPORTED = "isSupported"
        const val METHOD_START_SCAN = "startScan"
        const val METHOD_STOP_SCAN = "stopScan"
        private const val START_SCANSERVICE = "unitech.scanservice.start"
        private const val START_SCANSERVICE2 = "unitech.scanservice.init"
        private const val CLOSE_SCANSERVICE = "unitech.scanservice.close"
        private const val SCAN2KEY_SETTING = "unitech.scanservice.scan2key_setting"
        private const val SOFTWARE_SCANKEY = "unitech.scanservice.software_scankey"

        const val ACTION_RECEIVE_DATA = "unitech.scanservice.data"
        const val ACTION_RECEIVE_DATA2 = "android.intent.ACTION_DECODE_DATA"
    }

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var appContext: Context
    private lateinit var intentFilter: IntentFilter
    private val listeners = mutableListOf<ScanIntentHandler>()
    private val scanReceiver = ScanReceiver(listeners)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appContext = flutterPluginBinding.applicationContext

        intentFilter = IntentFilter().also {
            it.addAction(ACTION_RECEIVE_DATA)
            it.addAction(ACTION_RECEIVE_DATA2)
        }

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, COMMAND_CHANNEL)
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            METHOD_IS_SUPPORTED -> checkSupported(result)
            METHOD_START_SCAN -> startScan(result)
            METHOD_STOP_SCAN -> stopScan(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel.setStreamHandler(null)
        channel.setMethodCallHandler(null)

        if (listeners.isNotEmpty()) {
            listeners.clear()
            appContext.unregisterReceiver(scanReceiver)
            shutdown()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        listeners += ScanIntentHandler(events)
        if (listeners.size == 1) {
            appContext.registerReceiver(scanReceiver, intentFilter)
            setup()
        }
    }

    private fun setup() {
        var bundle = Bundle().also { it.putBoolean("scan2key", false) }
        appContext.sendBroadcast(Intent().setAction(SCAN2KEY_SETTING).putExtras(bundle))

        bundle = Bundle().also { it.putBoolean("enabled", true) }
        appContext.sendBroadcast(Intent().setAction(START_SCANSERVICE2).putExtras(bundle))

        bundle = Bundle().also { it.putBoolean("close", true) }
        appContext.sendBroadcast(Intent().setAction(START_SCANSERVICE).putExtras(bundle))
    }

    override fun onCancel(arguments: Any?) {
    }

    private fun checkSupported(result: Result) {
        return result.success(android.os.Build.MANUFACTURER.contains("Unitech", ignoreCase = true))
    }

    private fun startScan(result: Result) {
        val bundle = Bundle().also {
            it.putBoolean("scan", true)
        }
        appContext.sendBroadcast(Intent().setAction(SOFTWARE_SCANKEY).putExtras(bundle))
        result.success(true)
    }

    private fun stopScan(result: Result) {
        val bundle = Bundle().also {
            it.putBoolean("scan", false)
        }
        appContext.sendBroadcast(Intent().setAction(SOFTWARE_SCANKEY).putExtras(bundle))
        result.success(true)
    }

    private fun shutdown() {
        val bundle = Bundle().also { it.putBoolean("close", true) }
        appContext.sendBroadcast(Intent().setAction(CLOSE_SCANSERVICE).putExtras(bundle))
    }

}

private class ScanReceiver(private val listeners: List<ScanIntentHandler>) : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent) {
        val bundle = intent.extras ?: return
        when (intent.action) {
            UnitechScannerPlugin.ACTION_RECEIVE_DATA -> {
                val barcodeStr = bundle.getString("text")

                if (barcodeStr != null) {
                    listeners.forEach { it.onData(barcodeStr) }
                }
            }
            UnitechScannerPlugin.ACTION_RECEIVE_DATA2 -> {
                val barcodeStr = bundle.getString("barcode_string")

                if (barcodeStr != null) {
                    listeners.forEach { it.onData(barcodeStr) }
                }
            }
        }
    }

}