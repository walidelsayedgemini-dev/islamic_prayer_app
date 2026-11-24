package com.islamic.app.islamic_prayer_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class AdhanAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val voiceId = intent.getStringExtra(AdhanPlaybackService.EXTRA_VOICE_ID) ?: "madinah"
        val prayerName = intent.getStringExtra(AdhanPlaybackService.EXTRA_PRAYER_NAME) ?: "صلاة الفرض"
        val mode = intent.getStringExtra(AdhanPlaybackService.EXTRA_MODE) ?: "adhan"
        val volumePercent = intent.getIntExtra(AdhanPlaybackService.EXTRA_VOLUME_PERCENT, 100)
        if (mode == "off") return

        // قفل إيقاظ قصير لإتاحة تشغيل الخدمة دون رجوع الجهاز للنوم.
        try {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            val wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Firdaws::AdhanReceiverWL")
            wl.acquire(15_000L)
        } catch (_: Exception) {}

        val serviceIntent = Intent(context, AdhanPlaybackService::class.java).apply {
            action = AdhanPlaybackService.ACTION_START_ADHAN
            putExtra(AdhanPlaybackService.EXTRA_VOICE_ID, voiceId)
            putExtra(AdhanPlaybackService.EXTRA_PRAYER_NAME, prayerName)
            putExtra(AdhanPlaybackService.EXTRA_MODE, mode)
            putExtra(AdhanPlaybackService.EXTRA_VOLUME_PERCENT, volumePercent.coerceIn(0, 100))
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (_: Exception) {
            // لا تُسقط إعدادات الصلاة إلى رنين كامل الصوت عند تعذر بدء الخدمة.
            postFallbackNotification(context, voiceId, prayerName, mode, volumePercent)
        }
    }

    private fun postFallbackNotification(
        context: Context,
        voiceId: String,
        prayerName: String,
        mode: String,
        volumePercent: Int,
    ) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            AdhanPlaybackService.cleanupLegacyAdhanChannels(nm)
            val vibrationOnly = mode == "vibrationOnly"
            val resId = context.resources.getIdentifier("adhan_$voiceId", "raw", context.packageName)
            val soundUri = if (resId != 0) {
                Uri.parse("android.resource://${context.packageName}/$resId")
            } else {
                null
            }
            // Android notification channels cannot apply a percentage volume.
            // Therefore only the 100% fallback may sound; lower values stay silent.
            val playSound = !vibrationOnly && volumePercent >= 100 && soundUri != null
            val chId = when {
                playSound -> "firdaws_adhan_v4_fallback_$voiceId"
                vibrationOnly -> "firdaws_adhan_v4_fallback_vibration"
                else -> "firdaws_adhan_v4_fallback_silent"
            }
            val vibrationPattern = longArrayOf(0, 500, 300, 500, 300, 900)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && nm.getNotificationChannel(chId) == null) {
                val channel = NotificationChannel(
                    chId,
                    if (playSound) "تنبيه الأذان الاحتياطي ($voiceId)" else "تنبيه الصلاة الاحتياطي",
                    if (playSound || vibrationOnly) NotificationManager.IMPORTANCE_HIGH else NotificationManager.IMPORTANCE_LOW,
                ).apply {
                    if (playSound) {
                        setSound(
                            soundUri,
                            AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_ALARM)
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .build()
                        )
                    }
                    if (vibrationOnly) setVibrationPattern(vibrationPattern)
                    enableVibration(vibrationOnly)
                }
                nm.createNotificationChannel(channel)
            }

            val fullIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_adhan_alarm", !vibrationOnly)
                putExtra("voice_id", voiceId)
                putExtra("prayer_name", prayerName)
                putExtra("volume_percent", volumePercent.coerceIn(0, 100))
            }
            val pi = PendingIntent.getActivity(
                context,
                9105,
                fullIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notification = NotificationCompat.Builder(context, chId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(if (vibrationOnly) "تنبيه صلاة: $prayerName" else "🕌 حان الآن موعد $prayerName")
                .setContentText(
                    when {
                        vibrationOnly -> "تنبيه بالاهتزاز فقط"
                        playSound -> "حيّ على الصلاة.. حيّ على الفلاح (اضغط لفتح شاشة الأذان)"
                        else -> "تنبيه صامت؛ اضغط لفتح التطبيق"
                    },
                )
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(pi, playSound)
                .setContentIntent(pi)
                .setAutoCancel(true)
                .setOnlyAlertOnce(true)
                .setSilent(!playSound && !vibrationOnly)
                .apply {
                    // قبل Android O لا توجد قنوات، لذلك يُضبط صوت البديل على الإشعار نفسه.
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O && playSound) {
                        setSound(soundUri)
                    }
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O && vibrationOnly) {
                        setVibrate(vibrationPattern)
                    }
                }
                .build()

            nm.notify(9105, notification)
        } catch (_: Exception) {}
    }
}
