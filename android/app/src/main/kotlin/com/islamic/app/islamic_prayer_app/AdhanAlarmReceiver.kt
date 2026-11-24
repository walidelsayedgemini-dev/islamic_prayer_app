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
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (_: Exception) {
            // بديل صامت على مستوى الخدمة؛ لهذا الإشعار قناة مستقلة ذات صوت مرة واحدة.
            postFallbackSoundNotification(context, voiceId, prayerName)
        }
    }

    private fun postFallbackSoundNotification(context: Context, voiceId: String, prayerName: String) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            AdhanPlaybackService.cleanupLegacyAdhanChannels(nm)
            val chId = "firdaws_adhan_v4_fallback_$voiceId"
            val resId = context.resources.getIdentifier("adhan_$voiceId", "raw", context.packageName)
            val soundUri = if (resId != 0) {
                Uri.parse("android.resource://${context.packageName}/$resId")
            } else {
                null
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && nm.getNotificationChannel(chId) == null) {
                val channel = NotificationChannel(
                    chId,
                    "تنبيه الأذان الاحتياطي ($voiceId)",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    if (soundUri != null) {
                        setSound(
                            soundUri,
                            AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_ALARM)
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .build()
                        )
                    }
                    enableVibration(true)
                }
                nm.createNotificationChannel(channel)
            }

            val fullIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_adhan_alarm", true)
                putExtra("voice_id", voiceId)
                putExtra("prayer_name", prayerName)
            }
            val pi = PendingIntent.getActivity(
                context,
                9105,
                fullIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notification = NotificationCompat.Builder(context, chId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("🕌 حان الآن موعد $prayerName")
                .setContentText("حيّ على الصلاة.. حيّ على الفلاح (اضغط لفتح شاشة الأذان)")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(pi, true)
                .setContentIntent(pi)
                .setAutoCancel(true)
                .setOnlyAlertOnce(true)
                .apply {
                    // قبل Android O لا توجد قنوات، لذلك يُضبط صوت البديل على الإشعار نفسه.
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O && soundUri != null) {
                        setSound(soundUri)
                    }
                }
                .build()

            nm.notify(9105, notification)
        } catch (_: Exception) {}
    }
}
