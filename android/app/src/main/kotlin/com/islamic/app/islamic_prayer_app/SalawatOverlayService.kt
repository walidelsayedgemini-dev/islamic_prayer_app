package com.islamic.app.islamic_prayer_app

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import java.util.Random

class SalawatOverlayService : Service() {

    companion object {
        const val PREFS_NAME = "FlutterSharedPreferences"
        const val KEY_TAPPED_COUNT = "flutter.salawat_native_taps"
        const val KEY_STYLE_SEQ = "flutter.salawat_style_seq"
        const val EXTRA_RESCHEDULE_MINUTES = "reschedule_minutes"

        private data class SalawatVisualTheme(
            val title: String,
            val subtitle: String,
            val badge: String,
            val bgStart: Int,
            val bgEnd: Int,
            val borderColor: Int,
            val titleColor: Int,
            val subColor: Int,
            val cornerRadiusDp: Float
        )

        private val themes = listOf(
            SalawatVisualTheme(
                title = "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ ﷺ",
                subtitle = "✨ المس الشريط للاختفاء وكسب أجر الصلاة على الحبيب 🌸",
                badge = "🕌 نفحة نبوية",
                bgStart = Color.parseColor("#0B3B2E"),
                bgEnd = Color.parseColor("#115E46"),
                borderColor = Color.parseColor("#FBBF24"),
                titleColor = Color.parseColor("#FFFFFF"),
                subColor = Color.parseColor("#D1FAE5"),
                cornerRadiusDp = 24f
            ),
            SalawatVisualTheme(
                title = "صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ تَسْلِيماً كَثِيراً 💛",
                subtitle = "من صلّى عليّ صلاةً صلّى الله عليه بها عشراً 🌿 • المس للإغلاق",
                badge = "🌟 صلاة وعشر",
                bgStart = Color.parseColor("#451A03"),
                bgEnd = Color.parseColor("#78350F"),
                borderColor = Color.parseColor("#FDE047"),
                titleColor = Color.parseColor("#FFFBEB"),
                subColor = Color.parseColor("#FDE68A"),
                cornerRadiusDp = 28f
            ),
            SalawatVisualTheme(
                title = "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ 🤍",
                subtitle = "كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ 🕋 • المس للإخفاء الفوري",
                badge = "💫 الإبراهيمية",
                bgStart = Color.parseColor("#0F172A"),
                bgEnd = Color.parseColor("#1E3A8A"),
                borderColor = Color.parseColor("#38BDF8"),
                titleColor = Color.parseColor("#F8FAFC"),
                subColor = Color.parseColor("#BAE6FD"),
                cornerRadiusDp = 20f
            ),
            SalawatVisualTheme(
                title = "عَطِّرْ لِسَانَكَ بِالصَّلَاةِ عَلَى الشَّفِيعِ ﷺ 🌺",
                subtitle = "اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَيْهِ 🤲 • المس هنا للانصراف",
                badge = "🌹 عطر المجالس",
                bgStart = Color.parseColor("#500724"),
                bgEnd = Color.parseColor("#831843"),
                borderColor = Color.parseColor("#F472B6"),
                titleColor = Color.parseColor("#FFF1F2"),
                subColor = Color.parseColor("#FBCFE8"),
                cornerRadiusDp = 32f
            ),
            SalawatVisualTheme(
                title = "أَوْلَى النَّاسِ بِي يَوْمَ الْقِيَامَةِ أَكْثَرُهُمْ عَلَيَّ صَلَاةً 👑",
                subtitle = "اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ ✨ • المس للإغلاق فوراً",
                badge = "👑 القرب المحمدي",
                bgStart = Color.parseColor("#2E1065"),
                bgEnd = Color.parseColor("#581C87"),
                borderColor = Color.parseColor("#C084FC"),
                titleColor = Color.parseColor("#FAF5FF"),
                subColor = Color.parseColor("#E9D5FF"),
                cornerRadiusDp = 22f
            ),
            SalawatVisualTheme(
                title = "بِالصَّلَاةِ عَلَى النَّبِيِّ ﷺ تَنْفَرِجُ الْكُرُوبُ 🌊✨",
                subtitle = "إِذًا تُكْفَى هَمَّكَ وَيُغْفَرُ ذَنْبُكَ 💚 • لمسة واحدة وتختفي",
                badge = "🕊️ كفاية الهمّ",
                bgStart = Color.parseColor("#042F2E"),
                bgEnd = Color.parseColor("#0F766E"),
                borderColor = Color.parseColor("#5EEAD4"),
                titleColor = Color.parseColor("#F0FDFA"),
                subColor = Color.parseColor("#CCFBF1"),
                cornerRadiusDp = 26f
            ),
            SalawatVisualTheme(
                title = "اللَّهُمَّ صَلِّ عَلَى صَاحِبِ الْحَوْضِ الْمَوْرُودِ ﷺ ⛲",
                subtitle = "اسْقِنَا مِنْ حَوْضِهِ شَرْبَةً لَا نَظْمَأُ بَعْدَهَا 🤍 • المس للإغلاق",
                badge = "💧 الحوض المورود",
                bgStart = Color.parseColor("#082F49"),
                bgEnd = Color.parseColor("#0369A1"),
                borderColor = Color.parseColor("#7DD3FC"),
                titleColor = Color.parseColor("#F0F9FF"),
                subColor = Color.parseColor("#E0F2FE"),
                cornerRadiusDp = 30f
            ),
            SalawatVisualTheme(
                title = "زَيِّنْ دَقَائِقَكَ بِذِكْرِ الْحَبِيبِ الْمُصْطَفَى ﷺ 🌙⭐",
                subtitle = "صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ عَدَدَ مَا ذَكَرَهُ الذَّاكِرُونَ ✨",
                badge = "🌙 نور الفردوس",
                bgStart = Color.parseColor("#18181B"),
                bgEnd = Color.parseColor("#27272A"),
                borderColor = Color.parseColor("#D4AF37"),
                titleColor = Color.parseColor("#FEF3C7"),
                subColor = Color.parseColor("#FDE68A"),
                cornerRadiusDp = 18f
            )
        )
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val autoHideRunnable = Runnable { removeOverlayAndStop() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val intervalMin = intent?.getIntExtra(EXTRA_RESCHEDULE_MINUTES, 0) ?: 0
        if (intervalMin > 0) {
            scheduleNextInterval(intervalMin)
        }

        val canOverlay = Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
        if (canOverlay) {
            showFloatingSalawatBanner()
        } else {
            showFallbackSalawatNotification()
            stopSelf()
        }
        return START_NOT_STICKY
    }

    private fun nextTheme(): SalawatVisualTheme {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val prevSeq = try {
            prefs.getInt(KEY_STYLE_SEQ, -1)
        } catch (_: Exception) {
            -1
        }
        val randomOffset = Random().nextInt(themes.size)
        val idx = if (prevSeq < 0) {
            randomOffset
        } else {
            (prevSeq + 1 + Random().nextInt(themes.size - 1)) % themes.size
        }
        prefs.edit().putInt(KEY_STYLE_SEQ, idx).apply()
        return themes[idx]
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            resources.displayMetrics
        ).toInt()
    }

    private fun showFloatingSalawatBanner() {
        removeOverlayOnly()

        val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager = wm
        val style = nextTheme()

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutDirection = View.LAYOUT_DIRECTION_RTL
            setPadding(dpToPx(18f), dpToPx(12f), dpToPx(18f), dpToPx(12f))
            background = GradientDrawable(
                GradientDrawable.Orientation.TL_BR,
                intArrayOf(style.bgStart, style.bgEnd)
            ).apply {
                cornerRadius = dpToPx(style.cornerRadiusDp).toFloat()
                setStroke(dpToPx(1.8f), style.borderColor)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                elevation = dpToPx(12f).toFloat()
            }
        }

        val badgeView = TextView(this).apply {
            text = style.badge
            setTextColor(style.borderColor)
            textSize = 11.5f
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
        }

        val titleView = TextView(this).apply {
            text = style.title
            setTextColor(style.titleColor)
            textSize = 15.5f
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
            setPadding(0, dpToPx(3f), 0, dpToPx(3f))
        }

        val subView = TextView(this).apply {
            text = style.subtitle
            setTextColor(style.subColor)
            textSize = 11f
            gravity = Gravity.CENTER
        }

        container.addView(badgeView)
        container.addView(titleView)
        container.addView(subView)

        val windowType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            windowType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            // موضع متغير بلطف في كل مرة لمظهر حيوي وجميل
            y = dpToPx(44f + Random().nextInt(38).toFloat())
        }

        // مجرد ما الإشعار يُلمَس يتسجل الذكر ويختفي فوراً بسلاسة
        container.setOnTouchListener { v, event ->
            if (event.action == MotionEvent.ACTION_DOWN || event.action == MotionEvent.ACTION_UP) {
                incrementNativeSalawatCount()
                v.animate()
                    .scaleX(0.86f)
                    .scaleY(0.86f)
                    .alpha(0f)
                    .setDuration(140)
                    .withEndAction { removeOverlayAndStop() }
                    .start()
                true
            } else {
                false
            }
        }

        overlayView = container
        try {
            container.alpha = 0f
            container.scaleX = 0.88f
            container.scaleY = 0.88f
            wm.addView(container, params)
            container.animate()
                .alpha(1f)
                .scaleX(1f)
                .scaleY(1f)
                .setDuration(260)
                .start()

            // إغلاق تلقائي بعد 12 ثانية إن لم يُلمَس
            mainHandler.removeCallbacks(autoHideRunnable)
            mainHandler.postDelayed(autoHideRunnable, 12000L)
        } catch (_: Exception) {
            showFallbackSalawatNotification()
            stopSelf()
        }
    }

    private fun incrementNativeSalawatCount() {
        try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val prev = prefs.getLong(KEY_TAPPED_COUNT, 0L)
            prefs.edit().putLong(KEY_TAPPED_COUNT, prev + 1L).apply()
        } catch (_: Exception) {}
    }

    private fun showFallbackSalawatNotification() {
        val style = nextTheme()
        val chId = "firdaws_salawat_floating_ch"
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (nm.getNotificationChannel(chId) == null) {
                val ch = NotificationChannel(
                    chId,
                    "تذكير الصلاة على النبي ﷺ",
                    NotificationManager.IMPORTANCE_HIGH
                )
                nm.createNotificationChannel(ch)
            }
        }
        val tapIntent = Intent(this, MainActivity::class.java)
        val pending = PendingIntent.getActivity(
            this,
            7701,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notif = NotificationCompat.Builder(this, chId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(style.title)
            .setContentText(style.subtitle)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pending)
            .build()
        nm.notify(7700 + Random().nextInt(50), notif)
    }

    private fun scheduleNextInterval(intervalMinutes: Int) {
        try {
            val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, SalawatAlarmReceiver::class.java).apply {
                putExtra(EXTRA_RESCHEDULE_MINUTES, intervalMinutes)
            }
            val pending = PendingIntent.getBroadcast(
                this,
                8800,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val triggerAt = System.currentTimeMillis() + intervalMinutes * 60_000L
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pending)
            } else {
                am.set(AlarmManager.RTC_WAKEUP, triggerAt, pending)
            }
        } catch (_: Exception) {}
    }

    private fun removeOverlayOnly() {
        mainHandler.removeCallbacks(autoHideRunnable)
        overlayView?.let { view ->
            try {
                windowManager?.removeViewImmediate(view)
            } catch (_: Exception) {}
        }
        overlayView = null
    }

    private fun removeOverlayAndStop() {
        removeOverlayOnly()
        stopSelf()
    }

    override fun onDestroy() {
        removeOverlayOnly()
        super.onDestroy()
    }
}
