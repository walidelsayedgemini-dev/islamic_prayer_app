package com.islamic.app.islamic_prayer_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.database.ContentObserver
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationCompat

class AdhanPlaybackService : Service() {

    companion object {
        const val ACTION_START_ADHAN = "com.islamic.app.ACTION_START_ADHAN"
        const val ACTION_STOP_ADHAN = "com.islamic.app.ACTION_STOP_ADHAN"
        const val EXTRA_VOICE_ID = "voice_id"
        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val CHANNEL_ID = "firdaws_adhan_alarm_channel"
        const val NOTIF_ID = 9001

        @Volatile
        var isRinging: Boolean = false
            private set

        @Volatile
        var activeVoiceId: String = "madinah"
            private set

        @Volatile
        var activePrayerName: String = "صلاة الفرض"
            private set

        var onStateChangedListener: ((Boolean, String, String) -> Unit)? = null
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioManager: AudioManager? = null
    private var lastAlarmVolume: Int = -1
    private var lastMusicVolume: Int = -1
    private var volumeObserver: ContentObserver? = null
    private var volumeReceiver: BroadcastReceiver? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP_ADHAN -> {
                stopAdhanPlayback()
                return START_NOT_STICKY
            }
            ACTION_START_ADHAN, null -> {
                val voiceId = intent?.getStringExtra(EXTRA_VOICE_ID) ?: "madinah"
                val prayerName = intent?.getStringExtra(EXTRA_PRAYER_NAME) ?: "موعد الصلاة"
                startAdhanPlayback(voiceId, prayerName)
            }
        }
        return START_STICKY
    }

    private fun startAdhanPlayback(voiceId: String, prayerName: String) {
        stopMediaAndObserversOnly()

        activeVoiceId = voiceId
        activePrayerName = prayerName
        isRinging = true

        createNotificationChannel()
        val notification = buildInsistentNotification(voiceId, prayerName)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIF_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIF_ID, notification)
        }

        // إيقاظ الشاشة مؤقتاً
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "Firdaws::AdhanWakeLock"
            ).apply {
                acquire(10 * 60 * 1000L)
            }
        } catch (_: Exception) {}

        // إعداد مراقب زر رفع الصوت (حتّى لو كان الهاتف مقفلاً أو داخل أي تطبيق)
        audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        audioManager?.let { am ->
            val maxAlarm = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            val curAlarm = am.getStreamVolume(AudioManager.STREAM_ALARM)
            // إذا كان مستوى صوت المنبه في أقصى درجة (100%)، نخفضه درجة واحدة غير محسوسة
            // حتى يضمن الضغط على زر رفع الصوت من الجنب زيادة حقيقية تلتقطها الخدمة وتوقف الأذان فوراً
            if (curAlarm >= maxAlarm && maxAlarm > 2) {
                try {
                    am.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarm - 1, 0)
                } catch (_: Exception) {}
            } else if (curAlarm == 0 && maxAlarm > 2) {
                try {
                    am.setStreamVolume(AudioManager.STREAM_ALARM, (maxAlarm * 3) / 4, 0)
                } catch (_: Exception) {}
            }
            lastAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
            lastMusicVolume = am.getStreamVolume(AudioManager.STREAM_MUSIC)
        }

        registerVolumeUpStopListeners()

        // تشغيل ملف الأذان المختار من res/raw بتكرار متواصل (Looping)
        try {
            val resName = "adhan_$voiceId"
            var resId = resources.getIdentifier(resName, "raw", packageName)
            if (resId == 0) {
                resId = resources.getIdentifier("adhan_madinah", "raw", packageName)
            }
            if (resId != 0) {
                val player = MediaPlayer()
                val uri = Uri.parse("android.resource://$packageName/$resId")
                player.setDataSource(applicationContext, uri)
                player.setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                player.isLooping = true
                player.prepare()
                player.start()
                mediaPlayer = player
            }
        } catch (_: Exception) {}

        onStateChangedListener?.invoke(true, voiceId, prayerName)
    }

    private fun registerVolumeUpStopListeners() {
        val handler = Handler(Looper.getMainLooper())
        volumeObserver = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean) {
                super.onChange(selfChange)
                checkIfVolumeIncreased()
            }
        }
        try {
            contentResolver.registerContentObserver(
                Settings.System.CONTENT_URI,
                true,
                volumeObserver!!
            )
        } catch (_: Exception) {}

        volumeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == "android.media.VOLUME_CHANGED_ACTION") {
                    val stream = intent.getIntExtra("android.media.EXTRA_VOLUME_STREAM_TYPE", -1)
                    val newVal = intent.getIntExtra("android.media.EXTRA_VOLUME_STREAM_VALUE", -1)
                    val prevVal = intent.getIntExtra("android.media.EXTRA_PREV_VOLUME_STREAM_VALUE", -1)
                    if (newVal > prevVal && prevVal >= 0 &&
                        (stream == AudioManager.STREAM_ALARM ||
                            stream == AudioManager.STREAM_MUSIC ||
                            stream == AudioManager.STREAM_RING)
                    ) {
                        stopAdhanPlayback()
                    } else {
                        checkIfVolumeIncreased()
                    }
                }
            }
        }
        try {
            val filter = IntentFilter("android.media.VOLUME_CHANGED_ACTION")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(volumeReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(volumeReceiver, filter)
            }
        } catch (_: Exception) {}
    }

    private fun checkIfVolumeIncreased() {
        if (!isRinging) return
        val am = audioManager ?: return
        val curAlarm = am.getStreamVolume(AudioManager.STREAM_ALARM)
        val curMusic = am.getStreamVolume(AudioManager.STREAM_MUSIC)
        if ((lastAlarmVolume >= 0 && curAlarm > lastAlarmVolume) ||
            (lastMusicVolume >= 0 && curMusic > lastMusicVolume)
        ) {
            stopAdhanPlayback()
        } else {
            lastAlarmVolume = curAlarm
            lastMusicVolume = curMusic
        }
    }

    private fun buildInsistentNotification(voiceId: String, prayerName: String): Notification {
        val fullScreenIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("open_adhan_alarm", true)
            putExtra("voice_id", voiceId)
            putExtra("prayer_name", prayerName)
        }
        val fullScreenPending = PendingIntent.getActivity(
            this,
            9002,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, AdhanPlaybackService::class.java).apply {
            action = ACTION_STOP_ADHAN
        }
        val stopPending = PendingIntent.getService(
            this,
            9003,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notif = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("🕌 حان الآن موعد $prayerName")
            .setContentText("حيّ على الصلاة — لإيقاف الأذان ارفع الصوت من الجنب (+) أو اسحب الإشعار واضغط إلغاء")
            .setStyle(
                NotificationCompat.BigTextStyle().bigText(
                    "حيّ على الصلاة.. حيّ على الفلاح 🕌✨\n" +
                        "صوت الأذان سيبقى متواصلاً حتى ترفع الصوت من الجنب (+) أو تسحب وتضغط «إلغاء»."
                )
            )
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .setAutoCancel(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(fullScreenPending)
            .setFullScreenIntent(fullScreenPending, true)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "إلغاء الأذان 🛑", stopPending)
            .build()

        notif.flags = notif.flags or Notification.FLAG_INSISTENT or Notification.FLAG_NO_CLEAR
        return notif
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val existing = nm.getNotificationChannel(CHANNEL_ID)
            if (existing == null) {
                val ch = NotificationChannel(
                    CHANNEL_ID,
                    "منبه الأذان المتواصل",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "تنبيه الأذان بصوت المؤذن المختار حتى الإلغاء أو رفع الصوت"
                    setSound(null, null) // الصوت يدار عبر MediaPlayer للاستمرارية والـ loop
                    enableVibration(true)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                nm.createNotificationChannel(ch)
            }
        }
    }

    private fun stopMediaAndObserversOnly() {
        volumeObserver?.let {
            try {
                contentResolver.unregisterContentObserver(it)
            } catch (_: Exception) {}
        }
        volumeObserver = null

        volumeReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: Exception) {}
        }
        volumeReceiver = null

        mediaPlayer?.let {
            try {
                if (it.isPlaying) it.stop()
            } catch (_: Exception) {}
            try {
                it.release()
            } catch (_: Exception) {}
        }
        mediaPlayer = null
    }

    fun stopAdhanPlayback() {
        isRinging = false
        stopMediaAndObserversOnly()
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
        } catch (_: Exception) {}
        wakeLock = null

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }
        } catch (_: Exception) {}
        onStateChangedListener?.invoke(false, activeVoiceId, activePrayerName)
        stopSelf()
    }

    override fun onDestroy() {
        stopMediaAndObserversOnly()
        isRinging = false
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
