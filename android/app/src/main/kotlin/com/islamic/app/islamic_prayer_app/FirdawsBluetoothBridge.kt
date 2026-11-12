package com.islamic.app.islamic_prayer_app

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.PrintWriter
import java.util.UUID
import java.util.concurrent.Executors

class FirdawsBluetoothBridge(
    private val activity: Activity,
    private val channel: MethodChannel
) : MethodChannel.MethodCallHandler {

    companion object {
        private val SERVICE_UUID: UUID = UUID.fromString("fa87c0d0-afac-11de-8a39-0800200c9a66")
        private const val SERVICE_NAME = "AlFirdawsChallenge"
        private const val REQ_BT_PERMISSIONS = 4401
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor = Executors.newCachedThreadPool()
    private val btAdapter: BluetoothAdapter? by lazy {
        val mgr = activity.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        mgr?.adapter
    }

    private var serverSocket: BluetoothServerSocket? = null
    private var receiverRegistered = false
    private val discoveredDevices = linkedMapOf<String, Map<String, String>>()

    private val discoveryReceiver = object : BroadcastReceiver() {
        @SuppressLint("MissingPermission")
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }
                    if (device != null) {
                        val addr = device.address ?: return
                        val safeName = try {
                            device.name ?: "جهاز قريب"
                        } catch (_: SecurityException) {
                            "جهاز قريب"
                        }
                        discoveredDevices[addr] = mapOf(
                            "name" to safeName,
                            "address" to addr,
                            "paired" to "false"
                        )
                        emitDevicesUpdate()
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    mainHandler.post {
                        channel.invokeMethod("onDiscoveryFinished", discoveredDevices.values.toList())
                    }
                }
            }
        }
    }

    private fun hasBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestBluetoothPermissions() {
        val perms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_ADVERTISE
            )
        } else {
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }
        ActivityCompat.requestPermissions(activity, perms, REQ_BT_PERMISSIONS)
    }

    private fun emitDevicesUpdate() {
        val list = discoveredDevices.values.toList()
        mainHandler.post {
            channel.invokeMethod("onDevicesUpdated", list)
        }
    }

    @SuppressLint("MissingPermission")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getStatus" -> {
                val adapter = btAdapter
                result.success(
                    mapOf(
                        "supported" to (adapter != null),
                        "enabled" to (adapter?.isEnabled == true),
                        "hasPermission" to hasBluetoothPermissions()
                    )
                )
            }

            "requestPermissions" -> {
                if (!hasBluetoothPermissions()) {
                    requestBluetoothPermissions()
                }
                result.success(hasBluetoothPermissions())
            }

            "enableDiscoverable" -> {
                if (!hasBluetoothPermissions()) {
                    requestBluetoothPermissions()
                    result.success(false)
                    return
                }
                try {
                    val intent = Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE).apply {
                        putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 180)
                    }
                    activity.startActivity(intent)
                    result.success(true)
                } catch (_: Exception) {
                    result.success(false)
                }
            }

            "scanDevices" -> {
                val adapter = btAdapter
                if (adapter == null) {
                    result.error("NO_BT", "البلوتوث غير مدعوم على هذا الجهاز", null)
                    return
                }
                if (!hasBluetoothPermissions()) {
                    requestBluetoothPermissions()
                    result.error("NO_PERM", "يرجى السماح بصلاحية البلوتوث للمسح", null)
                    return
                }
                if (!adapter.isEnabled) {
                    result.error("BT_OFF", "يرجى تشغيل البلوتوث أولاً", null)
                    return
                }

                discoveredDevices.clear()
                try {
                    adapter.bondedDevices?.forEach { dev ->
                        val addr = dev.address ?: return@forEach
                        val name = try { dev.name ?: "جهاز مقترن" } catch (_: SecurityException) { "جهاز مقترن" }
                        discoveredDevices[addr] = mapOf(
                            "name" to name,
                            "address" to addr,
                            "paired" to "true"
                        )
                    }
                } catch (_: SecurityException) {}

                if (!receiverRegistered) {
                    val filter = IntentFilter().apply {
                        addAction(BluetoothDevice.ACTION_FOUND)
                        addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        activity.registerReceiver(discoveryReceiver, filter, Context.RECEIVER_EXPORTED)
                    } else {
                        activity.registerReceiver(discoveryReceiver, filter)
                    }
                    receiverRegistered = true
                }

                try {
                    if (adapter.isDiscovering) adapter.cancelDiscovery()
                    adapter.startDiscovery()
                } catch (_: Exception) {}

                emitDevicesUpdate()
                result.success(discoveredDevices.values.toList())
            }

            "startServer" -> {
                val localPayload = call.argument<String>("payload") ?: "{}"
                val adapter = btAdapter
                if (adapter == null || !adapter.isEnabled || !hasBluetoothPermissions()) {
                    if (!hasBluetoothPermissions()) requestBluetoothPermissions()
                    result.error("BT_UNAVAILABLE", "يرجى تفعيل البلوتوث وصلاحيات الاتصال", null)
                    return
                }
                executor.execute {
                    try {
                        serverSocket?.close()
                        val srv = adapter.listenUsingRfcommWithServiceRecord(SERVICE_NAME, SERVICE_UUID)
                        serverSocket = srv
                        val socket: BluetoothSocket = srv.accept()
                        val incoming = exchangeOverSocket(socket, localPayload, serverFirstRead = true)
                        try { srv.close() } catch (_: Exception) {}
                        mainHandler.post {
                            channel.invokeMethod("onPeerPayloadReceived", incoming)
                            result.success(incoming)
                        }
                    } catch (e: Exception) {
                        mainHandler.post {
                            result.error("BT_SERVER_ERR", e.message ?: "تعذر استقبال اتصال البلوتوث", null)
                        }
                    }
                }
            }

            "stopServer" -> {
                try { serverSocket?.close() } catch (_: Exception) {}
                serverSocket = null
                result.success(true)
            }

            "connectAndExchange" -> {
                val address = call.argument<String>("address") ?: ""
                val localPayload = call.argument<String>("payload") ?: "{}"
                val adapter = btAdapter
                if (adapter == null || !adapter.isEnabled || !hasBluetoothPermissions() || address.isEmpty()) {
                    result.error("BT_CONNECT_INVALID", "بيانات الجهاز أو صلاحية البلوتوث غير مكتملة", null)
                    return
                }
                executor.execute {
                    try {
                        if (adapter.isDiscovering) adapter.cancelDiscovery()
                        val device = adapter.getRemoteDevice(address)
                        val socket = device.createRfcommSocketToServiceRecord(SERVICE_UUID)
                        socket.connect()
                        val incoming = exchangeOverSocket(socket, localPayload, serverFirstRead = false)
                        mainHandler.post {
                            channel.invokeMethod("onPeerPayloadReceived", incoming)
                            result.success(incoming)
                        }
                    } catch (e: Exception) {
                        mainHandler.post {
                            result.error("BT_CONNECT_ERR", e.message ?: "تعذر الاتصال بالجهاز المحدد", null)
                        }
                    }
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun exchangeOverSocket(
        socket: BluetoothSocket,
        outgoingJson: String,
        serverFirstRead: Boolean
    ): String {
        var peerJson = "{}"
        socket.use { sock ->
            val reader = BufferedReader(InputStreamReader(sock.inputStream, Charsets.UTF_8))
            val writer = PrintWriter(sock.outputStream.bufferedWriter(Charsets.UTF_8), true)
            if (serverFirstRead) {
                peerJson = reader.readLine() ?: "{}"
                writer.println(outgoingJson.replace("\n", " "))
                writer.flush()
            } else {
                writer.println(outgoingJson.replace("\n", " "))
                writer.flush()
                peerJson = reader.readLine() ?: "{}"
            }
        }
        return peerJson
    }

    fun dispose() {
        try { serverSocket?.close() } catch (_: Exception) {}
        if (receiverRegistered) {
            try { activity.unregisterReceiver(discoveryReceiver) } catch (_: Exception) {}
            receiverRegistered = false
        }
        executor.shutdownNow()
    }
}
