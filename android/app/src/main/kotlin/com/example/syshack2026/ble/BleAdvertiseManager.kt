package com.example.syshack2026.ble

import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.os.ParcelUuid
import android.util.Log

/**
 * BluetoothLeAdvertiser のラッパー。
 * Plan C: 16-bit UUID + Service Data (Android)
 * アダプタ名を書き換えず、Service Dataのペイロードとしてトークンを送信します。
 */
class BleAdvertiseManager(
    private val context: Context,
    private val bluetoothAdapter: BluetoothAdapter
) {
    companion object {
        private const val TAG = "BleAdvertiseManager"
    }

    private var advertiser: BluetoothLeAdvertiser? = null
    private var advertiseCallback: AdvertiseCallback? = null
    private var isAdvertising = false

    fun isCurrentlyAdvertising(): Boolean = isAdvertising

    fun start(token: String, serviceUuid: String, onResult: (Boolean, String?) -> Unit) {
        if (isAdvertising) {
            stop()
        }

        if (!bluetoothAdapter.isEnabled) {
            onResult(false, "BLUETOOTH_DISABLED")
            return
        }

        val leAdvertiser = bluetoothAdapter.bluetoothLeAdvertiser
        if (leAdvertiser == null) {
            onResult(false, "ADVERTISE_UNSUPPORTED")
            return
        }
        advertiser = leAdvertiser

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_BALANCED)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .setConnectable(false)
            .setTimeout(0)
            .build()

        val pUuid = ParcelUuid.fromString(serviceUuid)
        val advertiseData = AdvertiseData.Builder()
            .setIncludeDeviceName(false) // ローカルネームは使用しない
            .setIncludeTxPowerLevel(false)
            .addServiceUuid(pUuid)
            .addServiceData(pUuid, token.toByteArray(Charsets.UTF_8))
            .build()

        val callback = object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
                isAdvertising = true
                Log.d(TAG, "アドバタイズ開始成功(ServiceData): $token")
                onResult(true, null)
            }

            override fun onStartFailure(errorCode: Int) {
                Log.w(TAG, "アドバタイズ開始失敗: errorCode=$errorCode")
                onResult(false, "ADVERTISE_FAILED_$errorCode")
            }
        }
        advertiseCallback = callback

        try {
            leAdvertiser.startAdvertising(settings, advertiseData, callback)
        } catch (e: SecurityException) {
            onResult(false, "PERMISSION_DENIED")
        }
    }

    fun stop(onResult: ((Boolean) -> Unit)? = null) {
        try {
            val currentAdvertiser = advertiser
            val currentCallback = advertiseCallback
            if (currentAdvertiser != null && currentCallback != null) {
                try {
                    currentAdvertiser.stopAdvertising(currentCallback)
                } catch (e: SecurityException) {
                    Log.w(TAG, "アドバタイズ停止時に権限エラー: ${e.message}")
                }
            }
        } finally {
            isAdvertising = false
            advertiseCallback = null
        }
        onResult?.invoke(true)
    }
}
