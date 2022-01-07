package com.icapps.zebra

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel

/**
 * @author Nicola Verbeeck
 */
class ScanIntentHandler(private val eventChannel: EventChannel.EventSink) : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        eventChannel.success(intent.getStringExtra("com.symbol.datawedge.data_string"))
    }
}