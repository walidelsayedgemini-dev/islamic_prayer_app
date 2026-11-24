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
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.core.app.NotificationCompat

class AdhanPlaybackService : Service() {

    companion object {
        const val ACTION_START_ADHAN = "com.islamic.app.ACTION_START_ADHAN"
        const val ACTION_STOP_ADHAN = "com.islamic.app.ACTION_STOP_ADHAN"
        const val EXTRA_VOICE_ID = "voice_id"
        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val EXTRA_FORCE_RESTART = "forceRestart"
        const val EXTRA_MODE = "alert_mode"
        const val EXTRA_VOLUME_PERCENT = "volume_percent"
        const val CHANNEL_ID = "firdaws_adhan_v4_service"
        const val NOTIF_ID = 9001

        private const val LEGACY_CHANNEL_ID = "firdaws_adhan_alarm_channel"
        private const val LEGACY_ADHAN_SOUND_CHANNEL_PREFIX = "firdaws_adhan_ch_"
        private const val LEGACY_FALLBACK_CHANNEL_PREFIX = "firdaws_adhan_fallback_"
        private const val LEGACY_PRE_ADHAN_CHANNEL_ID = "pre_adhan_voice_v2"

        @Volatile
        var isRinging: Boolean = false
            private set

        @Volatile
        var activeVoiceId: String = "madinah"
            private set

        @Volatile
        var activePrayerName: String = "صلاة الفرض"
            private set

        @Volatile
        var activeVolumePercent: Int = 100
            private set

        var onStateChangedListener: ((Boolean, String, String) -> Unit)? = null
        var onPlaybackCompletedListener: ((String, String) -> Unit)? = null

        // حذف قنوات الأذان القديمة فقط، مع إبقاء قنوات التطبيق الأخرى كما هي.
        fun cleanupLegacyAdhanChannels(notificationManager: NotificationManager) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            try {
                notificationManager.notificationChannels
                    .filter {
                        it.id == LEGACY_CHANNEL_ID ||
                            it.id == LEGACY_PRE_ADHAN_CHANNEL_ID ||
                            it.id.startsWith(LEGACY_ADHAN_SOUND_CHANNEL_PREFIX) ||
                            it.id.startsWith(LEGACY_FALLBACK_CHANNEL_PREFIX)
                    }
                    .forEach { notificationManager.deleteNotificationChannel(it.id) }
            } catch (_: Exception) {}
        }
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioManager: AudioManager? = null
    private var lastAlarmVolume: Int = -1
    private var lastMusicVolume: Int = -1
    private var originalAlarmVolume: Int? = null
    private var temporaryAlarmVolume: Int? = null
    private var volumeObserver: ContentObserver? = null
    private var volumeReceiver: BroadcastReceiver? = null
    private var vibrationStopRunnable: Runnable? = null
    private var activeVibrator: Vibrator? = null

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
                val forceRestart = intent?.getBooleanExtra(EXTRA_FORCE_RESTART, false) == true
                val mode = intent?.getStringExtra(EXTRA_MODE) ?: "adhan"
                val volumePercent = intent?.getIntExtra(EXTRA_VOLUME_PERCENT, 100) ?: 100
                if (mode == "vibrationOnly") {
                    startVibrationOnly(
                        voiceId,
                        prayerName,
                        forceRestart,
                        volumePercent.coerceIn(0, 100),
                    )
                } else {
                    startAdhanPlayback(
                        voiceId,
                        prayerName,
                        forceRestart,
                        volumePercent.coerceIn(0, 100),
                    )
                }
            }
        }
        return START_NOT_STICKY
    }

    private fun startAdhanPlayback(
        voiceId: String,
        prayerName: String,
        forceRestart: Boolean,
        volumePercent: Int,
    ) {
        // الطلبات المتكررة لا تعيد بدء المقطع؛ التجربة اليدوية وحدها يمكنها فرض إعادة التشغيل.
        if (isRinging && !forceRestart) return

        stopMediaAndObserversOnly()
        releaseWakeLock()
        restoreTemporaryAlarmVolume()

        activeVoiceId = voiceId
        activePrayerName = prayerName
        activeVolumePercent = volumePercent.coerceIn(0, 100)
        isRinging = true

        createNotificationChannel()
        val notification = buildAdhanNotification(voiceId, prayerName)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIF_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIF_ID, notification)
        }

        // إبقاء المعالج مستيقظاً أثناء المقطع فقط؛ ينتهي القفل تلقائياً بعد المهلة القصوى.
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "Firdaws::AdhanWakeLock"
            ).apply {
                acquire(10 * 60 * 1000L)
            }
        } catch (_: Exception) {}

        // مراقبة زر رفع الصوت لإيقاف الأذان حتى عند قفل الهاتف.
        audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        audioManager?.let { am ->
            val maxAlarm = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            val curAlarm = am.getStreamVolume(AudioManager.STREAM_ALARM)
            originalAlarmVolume = curAlarm
            temporaryAlarmVolume = null
            // يغيّر المستوى مؤقتًا فقط حتى تعمل وسيلة الإيقاف بزر الصوت، ثم يعيده عند النهاية.
            if (curAlarm >= maxAlarm && maxAlarm > 2) {
                try {
                    am.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarm - 1, 0)
                    temporaryAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
                } catch (_: Exception) {}
            } else if (curAlarm == 0 && maxAlarm > 2) {
                try {
                    am.setStreamVolume(AudioManager.STREAM_ALARM, (maxAlarm * 3) / 4, 0)
                    temporaryAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
                } catch (_: Exception) {}
            }
            lastAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
            lastMusicVolume = am.getStreamVolume(AudioManager.STREAM_MUSIC)
        }

        registerVolumeUpStopListeners()

        // تشغيل ملف الأذان مرة واحدة؛ نهاية الصوت لا توقف الخدمة ولا تغيّر حالة الرنين.
        var player: MediaPlayer? = null
        try {
            val resName = "adhan_$voiceId"
            var resId = resources.getIdentifier(resName, "raw", packageName)
            if (resId == 0) {
                resId = resources.getIdentifier("adhan_madinah", "raw", packageName)
            }
            if (resId != 0) {
                val currentPlayer = MediaPlayer()
                player = currentPlayer
                val uri = Uri.parse("android.resource://$packageName/$resId")
                currentPlayer.setDataSource(applicationContext, uri)
                currentPlayer.setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                val playerVolume = volumePercent.coerceIn(0, 100) / 100f
                currentPlayer.setVolume(playerVolume, playerVolume)
                currentPlayer.isLooping = false
                currentPlayer.setOnCompletionListener { completedPlayer ->
                    if (mediaPlayer !== completedPlayer || !isRinging) return@setOnCompletionListener
                    mediaPlayer = null
                    try {
                        completedPlayer.release()
                    } catch (_: Exception) {}
                    isRinging = false
                    stopMediaAndObserversOnly()
                    releaseWakeLock()
                    restoreTemporaryAlarmVolume()
                    removeForegroundNotification()
                    try {
                        onPlaybackCompletedListener?.invoke(activeVoiceId, activePrayerName)
                    } catch (_: Exception) {}
                    stopSelf()
                }
                currentPlayer.prepare()
                mediaPlayer = currentPlayer
                currentPlayer.start()
            } else {
                stopAdhanPlayback()
                return
            }
        } catch (_: Exception) {
            try {
                player?.release()
            } catch (_: Exception) {}
            if (mediaPlayer === player) mediaPlayer = null
            stopAdhanPlayback()
            return
        }

        onStateChangedListener?.invoke(true, voiceId, prayerName)
    }

    private fun startVibrationOnly(
        voiceId: String,
        prayerName: String,
        forceRestart: Boolean,
        volumePercent: Int,
    ) {
        if (isRinging && !forceRestart) return
        stopMediaAndObserversOnly()
        releaseWakeLock()
        restoreTemporaryAlarmVolume()
        activeVoiceId = voiceId
        activePrayerName = prayerName
        activeVolumePercent = volumePercent.coerceIn(0, 100)
        isRinging = true
        createNotificationChannel()
        val notification = buildAdhanNotification(voiceId, prayerName, vibrationOnly = true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIF_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(NOTIF_ID, notification)
        }

        activeVibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        try {
            val pattern = longArrayOf(0, 500, 300, 500, 300, 900)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activeVibrator?.vibrate(VibrationEffect.createWaveform(pattern, -1))
            } else {
                @Suppress("DEPRECATION")
                activeVibrator?.vibrate(pattern, -1)
            }
        } catch (_: Exception) {}

        onStateChangedListener?.invoke(true, voiceId, prayerName)
        val stopRunnable = Runnable {
            if (isRinging && activePrayerName == prayerName) {
                isRinging = false
                stopMediaAndObserversOnly()
                releaseWakeLock()
                restoreTemporaryAlarmVolume()
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        stopForeground(STOP_FOREGROUND_DETACH)
                    } else {
                        @Suppress("DEPRECATION")
                        stopForeground(false)
                    }
                } catch (_: Exception) {}
                onStateChangedListener?.invoke(false, activeVoiceId, activePrayerName)
                stopSelf()
            }
        }
        vibrationStopRunnable = stopRunnable
        Handler(Looper.getMainLooper()).postDelayed(stopRunnable, 3_000L)
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

    private fun buildAdhanNotification(
        voiceId: String,
        prayerName: String,
        vibrationOnly: Boolean = false,
    ): Notification {
        val fullScreenIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("open_adhan_alarm", !vibrationOnly)
            putExtra("voice_id", voiceId)
            putExtra("prayer_name", prayerName)
            putExtra("volume_percent", activeVolumePercent)
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

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(
                if (vibrationOnly) "تنبيه صلاة: $prayerName" else "🕌 حان الآن موعد $prayerName",
            )
            .setContentText(
                if (vibrationOnly) "تنبيه بالاهتزاز فقط" else "حيّ على الصلاة — لإيقاف الأذان ارفع الصوت من الجنب (+) أو اسحب الإشعار واضغط إلغاء",
            )
            .setStyle(
                NotificationCompat.BigTextStyle().bigText(
                    if (vibrationOnly) {
                        "تنبيه صلاة بالاهتزاز فقط — يمكنك فتح التطبيق لمراجعة الإعدادات."
                    } else {
                        "حيّ على الصلاة.. حيّ على الفلاح 🕌✨\n" +
                            "صوت الأذان مرة واحدة؛ أوقف الخدمة برفع الصوت من الجنب (+) أو بالسحب والضغط على «إلغاء»."
                    }
                )
            )
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(false)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(fullScreenPending)
            .setFullScreenIntent(fullScreenPending, !vibrationOnly)
            .setDeleteIntent(stopPending)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "إلغاء الأذان 🛑", stopPending)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            cleanupLegacyAdhanChannels(nm)
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "منبه الأذان (الإصدار 4)",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "إشعار خدمة الأذان؛ الصوت يصدر من مشغل الوسائط فقط"
                    setSound(null, null)
                    enableVibration(false)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                nm.createNotificationChannel(channel)
            }
        }
    }

    private fun stopMediaAndObserversOnly() {
        vibrationStopRunnable?.let {
            Handler(Looper.getMainLooper()).removeCallbacks(it)
        }
        vibrationStopRunnable = null
        try {
            activeVibrator?.cancel()
        } catch (_: Exception) {}
        activeVibrator = null

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

    private fun releaseWakeLock() {
        try {
            wakeLock?.let { if (it.isHeld) it.release() }
        } catch (_: Exception) {}
        wakeLock = null
    }

    private fun restoreTemporaryAlarmVolume() {
        val original = originalAlarmVolume
        val temporary = temporaryAlarmVolume
        val manager = audioManager
        if (original != null && temporary != null && manager != null) {
            try {
                if (manager.getStreamVolume(AudioManager.STREAM_ALARM) == temporary) {
                    manager.setStreamVolume(AudioManager.STREAM_ALARM, original, 0)
                }
            } catch (_: Exception) {}
        }
        originalAlarmVolume = null
        temporaryAlarmVolume = null
    }

    private fun removeForegroundNotification() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }
        } catch (_: Exception) {}
    }

    fun stopAdhanPlayback() {
        isRinging = false
        stopMediaAndObserversOnly()
        releaseWakeLock()
        restoreTemporaryAlarmVolume()
        removeForegroundNotification()
        onStateChangedListener?.invoke(false, activeVoiceId, activePrayerName)
        stopSelf()
    }

    override fun onDestroy() {
        stopMediaAndObserversOnly()
        releaseWakeLock()
        restoreTemporaryAlarmVolume()
        isRinging = false
        super.onDestroy()
    }
}
