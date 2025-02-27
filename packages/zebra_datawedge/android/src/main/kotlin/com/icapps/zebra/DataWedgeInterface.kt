package com.icapps.zebra

import android.app.Activity
import android.content.*
import android.content.ContentValues.TAG
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat.startActivityForResult
import com.icapps.architecture.arch.ConcreteMutableObservableFuture
import com.icapps.architecture.arch.MutableObservableFuture
import com.icapps.architecture.arch.ObservableFuture
import com.icapps.architecture.arch.asObservable
import java.util.*

/**
 * @author Nicola Verbeeck
 */
class DataWedgeInterface(private val appContext: Context) : BroadcastReceiver() {

    companion object {
        private const val INTENT_ACTION = "com.symbol.datawedge.api.ACTION"
        private const val INTENT_ACTION_RESULT_ACTION = "com.symbol.datawedge.api.RESULT_ACTION"
        private const val INTENT_EXTRA_ACTION_GET_PROFILES = "com.symbol.datawedge.api.GET_PROFILES_LIST"
        private const val INTENT_EXTRA_PROFILE_NAMES = "com.symbol.datawedge.api.RESULT_GET_PROFILES_LIST"
        private const val INTENT_EXTRA_ACTION_CREATE_PROFILE = "com.symbol.datawedge.api.CREATE_PROFILE"
        private const val INTENT_EXTRA_ACTION_SET_CONFIG = "com.symbol.datawedge.api.SET_CONFIG"
        private const val INTENT_EXTRA_SEND_RESULT = "SEND_RESULT"
        private const val INTENT_EXTRA_COMMAND_IDENTIFIER = "COMMAND_IDENTIFIER"
        private const val INTENT_EXTRA_COMMAND = "COMMAND"
        private const val INTENT_EXTRA_RESULT = "RESULT"
        private const val INTENT_EXTRA_ACTION_SOFT_SCANNER = "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER"
        private const val URI_IMEI = "content://oem_info/wan/imei"

        private const val ID_GET_PROFILES = "getProfiles"
    }

    private val waitingCommands = mutableMapOf<String, MutableObservableFuture<*>>()
    private val commandQueue = LinkedList<Intent>()
    private var processing = false

    fun init() {
        val filter = IntentFilter()
        filter.addAction(INTENT_ACTION_RESULT_ACTION)
        filter.addCategory(Intent.CATEGORY_DEFAULT)
        appContext.registerReceiver(this, filter)
    }

    fun destroy() {
        appContext.unregisterReceiver(this)
        commandQueue.clear()
        waitingCommands.clear()
    }

    fun getProfiles(): ObservableFuture<List<String>> {
        val future = ConcreteMutableObservableFuture<List<String>>()
        val command = Intent(INTENT_ACTION)
                .putExtra(INTENT_EXTRA_ACTION_GET_PROFILES, "")

        waitingCommands[ID_GET_PROFILES] = future
        sendCommand(command)

        return future
    }

    fun createProfile(name: String, barcodes: Set<BarcodeType>): ObservableFuture<Boolean> {
        val id = UUID.randomUUID().toString()
        val command = Intent(INTENT_ACTION)
                .putExtra(INTENT_EXTRA_ACTION_CREATE_PROFILE, name)
                .putExtra(INTENT_EXTRA_SEND_RESULT, "true")
                .putExtra(INTENT_EXTRA_COMMAND_IDENTIFIER, id)

        val future = ConcreteMutableObservableFuture<Boolean>()
        waitingCommands[id] = future

        sendCommand(command)

        return future andThen {
            if (it) configurePlugin(name, barcodes) else false.asObservable()
        }
    }

    fun updateProfile(name: String, barcodes: Set<BarcodeType>): ObservableFuture<Boolean> {
        return configurePlugin(name, barcodes)
    }

    private fun disableKeystroke(name: String): ObservableFuture<Boolean> {
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", name)
        profileConfig.putString("PROFILE_ENABLED", "true")
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        val barcodeConfig = Bundle()
        barcodeConfig.putString("PLUGIN_NAME", "KEYSTROKE")

        val barcodeProps = Bundle()
        barcodeProps.putString("keystroke_output_enabled", "false")
        barcodeConfig.putBundle("PARAM_LIST", barcodeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", barcodeConfig)

        val id = UUID.randomUUID().toString()
        val future = ConcreteMutableObservableFuture<Boolean>()
        waitingCommands[id] = future

        sendCommand(
                Intent(INTENT_ACTION)
                        .putExtra(INTENT_EXTRA_ACTION_SET_CONFIG, profileConfig)
                        .putExtra(INTENT_EXTRA_SEND_RESULT, "true")
                        .putExtra(INTENT_EXTRA_COMMAND_IDENTIFIER, id)
        )

        return future andThen {
            if (it) configureScan(name) else false.asObservable()
        }
    }

    private fun configurePlugin(name: String, barcodes: Set<BarcodeType>): ObservableFuture<Boolean> {
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", name)
        profileConfig.putString("PROFILE_ENABLED", "true")
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        val barcodeConfig = Bundle()
        barcodeConfig.putString("PLUGIN_NAME", "BARCODE")
        barcodeConfig.putString("RESET_CONFIG", "true")

        val barcodeProps = Bundle()
        barcodeProps.putString("scanner_input_enabled", "true");
        barcodeProps.putString("scanner_selection_by_identifier", "INTERNAL_IMAGER");
        BarcodeType.values().forEach {
            barcodeProps.putString(it.decoderName, "${it in barcodes}")
        }
        barcodeConfig.putBundle("PARAM_LIST", barcodeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", barcodeConfig)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", appContext.packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))

        val id = UUID.randomUUID().toString()
        val future = ConcreteMutableObservableFuture<Boolean>()
        waitingCommands[id] = future

        sendCommand(
                Intent(INTENT_ACTION)
                        .putExtra(INTENT_EXTRA_ACTION_SET_CONFIG, profileConfig)
                        .putExtra(INTENT_EXTRA_SEND_RESULT, "true")
                        .putExtra(INTENT_EXTRA_COMMAND_IDENTIFIER, id)
        )

        return future andThen {
            if (it) disableKeystroke(name) else false.asObservable()
        }
    }

    private fun configureScan(name: String): ObservableFuture<Boolean> {
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", name)
        profileConfig.putString("PROFILE_ENABLED", "true")
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        appContext.sendBroadcast(
                Intent(INTENT_ACTION)
                        .putExtra(INTENT_EXTRA_ACTION_SET_CONFIG, profileConfig)
        )

        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")
        val intentProps = Bundle()
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", ZebraPlugin.INTENT_ACTION_SCAN)
        intentProps.putString("intent_delivery", "2")
        intentConfig.putBundle("PARAM_LIST", intentProps)
        profileConfig.putBundle("PLUGIN_CONFIG", intentConfig)

        val id = UUID.randomUUID().toString()
        val future = ConcreteMutableObservableFuture<Boolean>()
        waitingCommands[id] = future

        sendCommand(
                Intent(INTENT_ACTION)
                        .putExtra(INTENT_EXTRA_ACTION_SET_CONFIG, profileConfig)
                        .putExtra(INTENT_EXTRA_SEND_RESULT, "true")
                        .putExtra(INTENT_EXTRA_COMMAND_IDENTIFIER, id)
        )

        return future
    }

    private fun sendCommand(command: Intent) {
        commandQueue.add(command)
        tryProcess()
    }

    private fun tryProcess() {
        if (processing) return
        if (commandQueue.isEmpty()) return

        processing = true
        val intent = commandQueue.pop()
        appContext.sendBroadcast(intent)
    }

    override fun onReceive(context: Context, intent: Intent) {
        intent.extras?.dump()?.let {
            Log.e("Zebra", it)
        }

        val id = intent.getStringExtra(INTENT_EXTRA_COMMAND_IDENTIFIER)
        val command = intent.getStringExtra(INTENT_EXTRA_COMMAND)

        when {
            intent.hasExtra(INTENT_EXTRA_PROFILE_NAMES) -> {
                dispatch(ID_GET_PROFILES, intent.getStringArrayExtra(INTENT_EXTRA_PROFILE_NAMES)!!.toList())
            }
            command == INTENT_EXTRA_ACTION_CREATE_PROFILE -> {
                dispatch(id!!, intent.getStringExtra(INTENT_EXTRA_RESULT) == "SUCCESS")
            }
            command == INTENT_EXTRA_ACTION_SET_CONFIG -> {
                dispatch(id!!, intent.getStringExtra(INTENT_EXTRA_RESULT) == "SUCCESS")
            }
            command == INTENT_EXTRA_ACTION_SOFT_SCANNER -> {
                dispatch(id!!, intent.getStringExtra(INTENT_EXTRA_RESULT) == "SUCCESS")
            }
        }
    }

    private fun <T : Any> dispatch(id: String, data: T) {
        val command = waitingCommands.remove(id) as? MutableObservableFuture<T>
        if (command != null) {
            command.onResult(data)
            processing = false
            tryProcess()
        }
    }

    fun startScanning(): ObservableFuture<Boolean> {
        return toggleScanner(true)
    }

    fun stopScanning(): ObservableFuture<Boolean> {
        return toggleScanner(false)
    }

    // fun retrieveIMEI(context: Context): String? {
    //     val myUri = Uri.parse(URI_IMEI)

    //     // Query the content provider
    //     val cr: ContentResolver = context.contentResolver
    //     val cursor: Cursor? = cr.query(myUri, null, null, null, null)

    //     // Read the cursor
    //     cursor?.moveToFirst()
    //     val imei: String = cursor?.getString(0) ?: ""
    //     Log.i(TAG, "Device IMEI is : $imei")
    //     return imei
    // }

    fun retrieveIMEI(context: Context): String? {
        val uri = Uri.parse(URI_IMEI)
        var data = "Error"
        val cursor = context.contentResolver.query(uri, null, null, null, null)
        if (cursor == null || cursor.count < 1) {
            val errorMsg = "Could not read identifier.  Have you granted access?  Does this device support retrieval of this identifier?"
            return errorMsg
        } else {
            while (cursor.moveToNext()) {
                if (cursor.columnCount == 0) {
                    //  No data in the cursor.
                    val errorMsg = "Error: $uri does not exist on this device"
                    return errorMsg
                } else {
                    for (i in 0 until cursor.columnCount) {
                        try {
                            data = cursor.getString(cursor.getColumnIndex(cursor.getColumnName(i)))
                        } catch (e: Exception) {
                            return e.message
                        }
                    }
                }
            }
            cursor.close()
            return data
        }
    }

    private fun toggleScanner(on: Boolean): ObservableFuture<Boolean> {
        val future = ConcreteMutableObservableFuture<Boolean>()
        val id = UUID.randomUUID().toString()
        val command = Intent(INTENT_ACTION)
                .putExtra(INTENT_EXTRA_ACTION_SOFT_SCANNER, if (on) "START_SCANNING" else "STOP_SCANNING")
                .putExtra(INTENT_EXTRA_SEND_RESULT, "true")
                .putExtra(INTENT_EXTRA_COMMAND_IDENTIFIER, id)

        waitingCommands[id] = future
        sendCommand(command)

        return future
    }

}

fun Bundle.dump(): String {
    return buildString {
        for (key in keySet()) {
            append(key + " : " + dumpValue(get(key)))
            append('\n')
        }
    }
}

private fun dumpValue(value: Any?): String {
    if (value is Bundle) return value.dump()
    return "$value"
}

enum class BarcodeType(val decoderName: String) {
    CODE11("decoder_code11"),
    CODE128("decoder_code128"),
    CODE39("decoder_code39"),
    EAN13("decoder_ean13"),
    EAN8("decoder_ean8"),
    KOREAN3OF5("decoder_korean_3of5"),
    CHINESE2OF5("decoder_chinese_2of5"),
    D2OF5("decoder_d2of5"),
    TRIOPTIC39("decoder_trioptic39"),
    CODE93("decoder_code93"),
    MSI("decoder_msi"),
    CODEBAR("decoder_codabar"),
    UPCE0("decoder_upce0"),
    UPCE1("decoder_upce1"),
    UPCA("decoder_upca"),
    US4STATE("decoder_us4state"),
    TLC39("decoder_tlc39"),
    MAILMARK("decoder_mailmark"),
    HANXIN("decoder_hanxin"),
    SIGNATURE("decoder_signature"),
    WEBCODE("decoder_webcode"),
    MATRIX_2OF5("decoder_matrix_2of5"),
    MATRIX_2OF5_REDUNDANCY("decoder_matrix_2of5_redundancy"),
    MATRIX_2OF5_REPORT_CHECK_DIGIT("decoder_matrix_2of5_report_check_digit"),
    MATRIX_2OF5_VERIFY_CHECK_DIGIT("decoder_matrix_2of5_verify_check_digit"),
    I2OF5("decoder_i2of5"),
    I2OF5_REDUNDANCY("decoder_i2of5_redundancy"),
    I2OF5_REPORT_CHECK_DIGIT("decoder_i2of5_report_check_digit"),
    I2OF5_CONVERT_TO_EAN13("decoder_i2of5_convert_to_ean13"),
    I2OF5_CHECK_DIGIT("decoder_i2of5_check_digit"),
    I2OF5_SECURITY_LEVEL("decoder_i2of5_security_level"),
    GS1_DATABAR("decoder_gs1_databar"),
    DATAMATRIX("decoder_datamatrix"),
    QRCODE("decoder_qrcode"),
    GS1_DATAMATRIX("decoder_gs1_datamatrix"),
    GS1_QRCODE("decoder_gs1_qrcode"),
    PDF417("decoder_pdf417"),
    COMPOSITE_AB("decoder_composite_ab"),
    COMPOSITE_C("decoder_composite_c"),
    MICROQR("decoder_microqr"),
    AZTEC("decoder_aztec"),
    MAXICODE("decoder_maxicode"),
    MICROPDF("decoder_micropdf"),
    USPOSTNET("decoder_uspostnet"),
    USPLANET("decoder_usplanet"),
    AUSTRALIAN_POSTAL("decoder_australian_postal"),
    UK_POSTAL("decoder_uk_postal"),
    JAPANESE_POSTAL("decoder_japanese_postal"),
    CANADIAN_POSTAL("decoder_canadian_postal"),
    DUTCH_POSTAL("decoder_dutch_postal"),
    GS1_LIM_SECURITY_LEVEL("decoder_gs1_lim_security_level"),
}
