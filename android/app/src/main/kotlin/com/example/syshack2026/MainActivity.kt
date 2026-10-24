package com.example.syshack2026

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.syshack2026.ble.BleAdvertiseManager
import com.example.syshack2026.ble.BleScanManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val batteryChannelName = "syshack/battery_optimization"
	private val bleChannelName = "syshack/ble"
	private val bleEventChannelName = "syshack/ble/scan_results"
	private val permissionRequestCode = 20260915

	private val bluetoothAdapter: BluetoothAdapter by lazy {
		val manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
		manager.adapter
	}
	private val bleAdvertiseManager: BleAdvertiseManager by lazy {
		BleAdvertiseManager(applicationContext, bluetoothAdapter)
	}
	private val bleScanManager: BleScanManager by lazy {
		BleScanManager(applicationContext)
	}

	private var pendingPermissionResult: MethodChannel.Result? = null

	private fun requiredBlePermissions(): Array<String> {
		return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
			arrayOf(
				android.Manifest.permission.BLUETOOTH_SCAN,
				android.Manifest.permission.BLUETOOTH_ADVERTISE,
				android.Manifest.permission.BLUETOOTH_CONNECT,
			)
		} else {
			arrayOf(android.Manifest.permission.ACCESS_FINE_LOCATION)
		}
	}

	private fun hasAllBlePermissions(): Boolean {
		return requiredBlePermissions().all {
			ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
		}
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		// --- BLE(すれ違い通信): スキャン / アドバタイズ / 権限 ---
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bleChannelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"isBluetoothEnabled" -> {
						result.success(bluetoothAdapter.isEnabled)
					}

					"hasRequiredPermissions" -> {
						result.success(hasAllBlePermissions())
					}

					"requestPermissions" -> {
						if (hasAllBlePermissions()) {
							result.success(true)
						} else {
							pendingPermissionResult = result
							ActivityCompat.requestPermissions(
								this,
								requiredBlePermissions(),
								permissionRequestCode,
							)
						}
					}

					"startAdvertising" -> {
						val token = call.argument<String>("token")
						val serviceUuid = call.argument<String>("serviceUuid")
						if (token != null && serviceUuid != null) {
							bleAdvertiseManager.start(token, serviceUuid) { success, error ->
								if (success) {
									result.success(null)
								} else {
									result.error("ADVERTISE_FAILED", error, null)
								}
							}
						} else {
							result.error("INVALID_ARGS", "token and serviceUuid are required", null)
						}
					}

					"stopAdvertising" -> {
						bleAdvertiseManager.stop { result.success(null) }
					}

					"startScanning" -> {
						val serviceUuid = call.argument<String>("serviceUuid")
						if (serviceUuid != null) {
							bleScanManager.startScanning(serviceUuid)
							result.success(null)
						} else {
							result.error("INVALID_ARGS", "serviceUuid is required", null)
						}
					}

					"stopScanning" -> {
						bleScanManager.stopScanning()
						result.success(null)
					}

					else -> result.notImplemented()
				}
			}

		EventChannel(flutterEngine.dartExecutor.binaryMessenger, bleEventChannelName)
			.setStreamHandler(object : EventChannel.StreamHandler {
				override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
					bleScanManager.setEventSink(events)
				}

				override fun onCancel(arguments: Any?) {
					bleScanManager.setEventSink(null)
				}
			})

		// --- バッテリー最適化(既存) ---
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, batteryChannelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"isIgnoringBatteryOptimizations" -> {
						val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
						result.success(powerManager.isIgnoringBatteryOptimizations(packageName))
					}

					"requestIgnoreBatteryOptimizations" -> {
						try {
							val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
								data = Uri.parse("package:$packageName")
							}
							startActivity(intent)
							result.success(true)
						} catch (e: Exception) {
							try {
								val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
								startActivity(fallbackIntent)
								result.success(true)
							} catch (fallbackError: Exception) {
								result.error(
									"OPEN_SETTINGS_FAILED",
									fallbackError.message,
									null
								)
							}
						}
					}

					else -> result.notImplemented()
				}
			}
	}

	override fun onRequestPermissionsResult(
		requestCode: Int,
		permissions: Array<out String>,
		grantResults: IntArray,
	) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		if (requestCode == permissionRequestCode) {
			val granted = grantResults.isNotEmpty() &&
				grantResults.all { it == PackageManager.PERMISSION_GRANTED }
			pendingPermissionResult?.success(granted)
			pendingPermissionResult = null
		}
	}
}
