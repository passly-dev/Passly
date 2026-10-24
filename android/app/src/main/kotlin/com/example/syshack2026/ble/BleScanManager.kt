package com.example.syshack2026.ble

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.os.ParcelUuid
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.util.UUID

class BleScanManager(private val context: Context) {

    companion object {
        private const val TAG = "BleScanManager"
    }

    private val bluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter: BluetoothAdapter? = bluetoothManager.adapter
    private var scanner: BluetoothLeScanner? = null
    private var eventSink: EventChannel.EventSink? = null
    private var scanning = false
    private var targetServiceUuid: String? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun isScanning(): Boolean = scanning

    fun startScanning(serviceUuid: String) {
        if (scanning) {
            Log.d(TAG, "already scanning, ignoring startScanning()")
            return
        }
        val adapter = bluetoothAdapter
        if (adapter == null || !adapter.isEnabled) {
            Log.w(TAG, "Bluetooth disabled; cannot start scanning")
            return
        }
        scanner = adapter.bluetoothLeScanner
        val leScanner = scanner ?: run {
            Log.w(TAG, "BluetoothLeScanner unavailable")
            return
        }

        targetServiceUuid = serviceUuid

        val filter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid(UUID.fromString(serviceUuid)))
            .build()

        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()

        try {
            leScanner.startScan(listOf(filter), settings, scanCallback)
            scanning = true
            Log.i(TAG, "BLE scan started (serviceUuid=$serviceUuid)")
        } catch (e: SecurityException) {
            Log.e(TAG, "Missing BLUETOOTH_SCAN permission", e)
        }
    }

    fun stopScanning() {
        if (!scanning) return
        try {
            scanner?.stopScan(scanCallback)
        } catch (e: SecurityException) {
            Log.e(TAG, "Missing BLUETOOTH_SCAN permission on stop", e)
        }
        scanning = false
        Log.i(TAG, "BLE scan stopped")
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val record = result.scanRecord ?: return
            var token: String? = null

            // 1. Service Data から抽出 (Androidからの発信)
            if (targetServiceUuid != null) {
                val pUuid = ParcelUuid.fromString(targetServiceUuid)
                val serviceDataBytes = record.serviceData[pUuid]
                if (serviceDataBytes != null) {
                    token = String(serviceDataBytes, Charsets.UTF_8).trim()
                }
            }

            // 2. Local Name から抽出 (iOSからの発信)。iOSはLocal Nameにトークンを格納する。
            //    "SP_" プレフィックス付きなら剥がす(無くても許容)。
            if (token.isNullOrEmpty()) {
                val deviceName = record.deviceName?.trim()
                if (!deviceName.isNullOrEmpty()) {
                    token = if (deviceName.startsWith("SP_")) deviceName.substring(3) else deviceName
                }
            }

            // バリデーション: エフェメラルトークンは16進文字列(8桁 or 16桁)。
            // 長さだけでなく16進かどうかも検証し、近隣の無関係なBLE端末名
            // (例:「Slackの住人」= ちょうど8文字だが16進ではない)を確実に除外する(2026-09-19)。
            val t = token
            val isHexToken = t != null &&
                (t.length == 8 || t.length == 16) &&
                t.all { it in '0'..'9' || it in 'a'..'f' || it in 'A'..'F' }
            if (isHexToken) {
                eventSink?.success(
                    mapOf(
                        "ephemeralId" to t,
                        "rssi" to result.rssi,
                        "timestampMs" to System.currentTimeMillis()
                    )
                )
            }
        }

        override fun onScanFailed(errorCode: Int) {
            Log.e(TAG, "onScanFailed: errorCode=$errorCode")
        }
    }
}
