package com.icapps.unitech_scanner

import io.flutter.plugin.common.EventChannel

/**
 * @author Nicola Verbeeck
 */
class ScanIntentHandler(private val eventChannel: EventChannel.EventSink) {
    fun onData(barcode: String) {
        eventChannel.success(barcode)
    }
}