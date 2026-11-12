package com.islamic.app.islamic_prayer_app

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.KeyEvent
import android.view.WindowManager
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val channelName = "com.islamic.app/firdaws_native"
    private val btChannelName = "com.islamic.app/firdaws_bluetooth"
    private var methodChannel: MethodChannel? = null
    private var btBridge: FirdawsBluetoothBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        val btChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, btChannelName)
        btBridge?.dispose()
        btBridge = FirdawsBluetoothBridge(this, btChannel)
        btChannel.setMethodCallHandler(btBridge)

        AdhanPlaybackService.onStateChangedListener = { isRinging, voiceId, prayerName ->
            runOnUiThread {
                methodChannel?.invokeMethod(
                    "onAdhanStateChanged",
                    mapOf(
                        "isRinging" to isRinging,
                        "voiceId" to voiceId,
                        "prayerName" to prayerName
                    )
                )
            }
        }

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startAdhanAlarm" -> {
                    val voiceId = call.argument<String>("voiceId") ?: "madinah"
                    val prayerName = call.argument<String>("prayerName") ?: "صلاة الفرض"
                    val intent = Intent(this, AdhanPlaybackService::class.java).apply {
                        action = AdhanPlaybackService.ACTION_START_ADHAN
                        putExtra(AdhanPlaybackService.EXTRA_VOICE_ID, voiceId)
                        putExtra(AdhanPlaybackService.EXTRA_PRAYER_NAME, prayerName)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(true)
                }

                "stopAdhanAlarm" -> {
                    val intent = Intent(this, AdhanPlaybackService::class.java).apply {
                        action = AdhanPlaybackService.ACTION_STOP_ADHAN
                    }
                    startService(intent)
                    result.success(true)
                }

                "isAdhanRinging" -> {
                    result.success(
                        mapOf(
                            "isRinging" to AdhanPlaybackService.isRinging,
                            "voiceId" to AdhanPlaybackService.activeVoiceId,
                            "prayerName" to AdhanPlaybackService.activePrayerName
                        )
                    )
                }

                "schedulePrayerAlarms" -> {
                    val alarms = call.argument<List<Map<String, Any>>>("alarms") ?: emptyList()
                    AdhanAlarmScheduler.saveAndSchedule(this, alarms)
                    result.success(true)
                }

                "getAdhanDiagnostics" -> {
                    val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val canExact = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        am.canScheduleExactAlarms()
                    } else {
                        true
                    }
                    val ignoringBattery = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        pm.isIgnoringBatteryOptimizations(packageName)
                    } else {
                        true
                    }
                    val notifEnabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
                    val overlayEnabled = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
                    result.success(
                        mapOf(
                            "canScheduleExactAlarms" to canExact,
                            "notificationsEnabled" to notifEnabled,
                            "ignoringBatteryOptimizations" to ignoringBattery,
                            "canDrawOverlays" to overlayEnabled,
                            "scheduledCount" to AdhanAlarmScheduler.getScheduledFutureCount(this)
                        )
                    )
                }

                "requestExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        } catch (_: Exception) {}
                    }
                    result.success(true)
                }

                "requestBatteryOptimizationExemption" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        } catch (_: Exception) {}
                    }
                    result.success(true)
                }

                "canDrawOverlays" -> {
                    val allowed = Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                        Settings.canDrawOverlays(this)
                    result.success(allowed)
                }

                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        try {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            ).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        } catch (_: Exception) {}
                    }
                    result.success(true)
                }

                "showSalawatOverlayNow" -> {
                    val allowed = Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                        Settings.canDrawOverlays(this)
                    val intent = Intent(this, SalawatOverlayService::class.java)
                    startService(intent)
                    result.success(allowed)
                }

                "scheduleSalawatReminders" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val intervalMinutes = call.argument<Int>("intervalMinutes") ?: 0
                    val customTimes = call.argument<List<String>>("customTimes") ?: emptyList()
                    scheduleNativeSalawatAlarms(enabled, intervalMinutes, customTimes)
                    result.success(true)
                }

                "consumeNativeLaunchExtras" -> {
                    val map = mapOf(
                        "openAdhanAlarm" to (intent?.getBooleanExtra("open_adhan_alarm", false) == true),
                        "voiceId" to (intent?.getStringExtra("voice_id") ?: "madinah"),
                        "prayerName" to (intent?.getStringExtra("prayer_name") ?: "صلاة الفرض")
                    )
                    intent?.removeExtra("open_adhan_alarm")
                    result.success(map)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("open_adhan_alarm", false)) {
            methodChannel?.invokeMethod(
                "onOpenAdhanScreen",
                mapOf(
                    "voiceId" to (intent.getStringExtra("voice_id") ?: "madinah"),
                    "prayerName" to (intent.getStringExtra("prayer_name") ?: "صلاة الفرض")
                )
            )
            intent.removeExtra("open_adhan_alarm")
        }
    }

    // زر رفع الصوت من الجنب يوقف الأذان فوراً
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            methodChannel?.invokeMethod("onVolumeUpPressed", null)
            if (AdhanPlaybackService.isRinging) {
                val intent = Intent(this, AdhanPlaybackService::class.java).apply {
                    action = AdhanPlaybackService.ACTION_STOP_ADHAN
                }
                startService(intent)
                return true
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    // تم نقل جدولة المنبهات إلى AdhanAlarmScheduler لحفظها وإعادة جدولتها تلقائياً بعد إعادة التشغيل

    private fun scheduleNativeSalawatAlarms(
        enabled: Boolean,
        intervalMinutes: Int,
        customTimes: List<String>
    ) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // إلغاء الدوري + المخصص (8800..8830)
        for (req in 8800..8830) {
            val cancelIntent = Intent(this, SalawatAlarmReceiver::class.java)
            val pi = PendingIntent.getBroadcast(
                this,
                req,
                cancelIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            am.cancel(pi)
        }

        if (!enabled) return

        if (intervalMinutes > 0) {
            val intervalIntent = Intent(this, SalawatAlarmReceiver::class.java).apply {
                putExtra(SalawatOverlayService.EXTRA_RESCHEDULE_MINUTES, intervalMinutes)
            }
            val pi = PendingIntent.getBroadcast(
                this,
                8800,
                intervalIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val firstAt = System.currentTimeMillis() + intervalMinutes * 60_000L
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, firstAt, pi)
                } else {
                    am.set(AlarmManager.RTC_WAKEUP, firstAt, pi)
                }
            } catch (_: Exception) {}
        }

        val now = Calendar.getInstance()
        for ((idx, hhmm) in customTimes.take(25).withIndex()) {
            val parts = hhmm.split(":")
            if (parts.size != 2) continue
            val hour = parts[0].toIntOrNull() ?: continue
            val minute = parts[1].toIntOrNull() ?: continue
            if (hour !in 0..23 || minute !in 0..59) continue

            val target = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                if (before(now)) {
                    add(Calendar.DAY_OF_MONTH, 1)
                }
            }

            val timeIntent = Intent(this, SalawatAlarmReceiver::class.java)
            val pi = PendingIntent.getBroadcast(
                this,
                8801 + idx,
                timeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            try {
                am.setRepeating(
                    AlarmManager.RTC_WAKEUP,
                    target.timeInMillis,
                    AlarmManager.INTERVAL_DAY,
                    pi
                )
            } catch (_: Exception) {}
        }
    }

    override fun onDestroy() {
        btBridge?.dispose()
        btBridge = null
        super.onDestroy()
    }
}
