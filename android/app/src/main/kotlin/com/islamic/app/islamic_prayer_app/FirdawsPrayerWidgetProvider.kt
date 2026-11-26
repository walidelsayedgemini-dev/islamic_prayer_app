package com.islamic.app.islamic_prayer_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class FirdawsPrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateAll(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_UPDATE_NEXT_PRAYER,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_DATE_CHANGED -> {
                val manager = AppWidgetManager.getInstance(context)
                updateAll(
                    context,
                    manager,
                    manager.getAppWidgetIds(
                        ComponentName(context, FirdawsPrayerWidgetProvider::class.java),
                    ),
                )
            }
        }
    }

    companion object {
        const val PREFS_NAME = "firdaws_prayer_widget_v1"
        const val ACTION_UPDATE_NEXT_PRAYER = "com.islamic.app.ACTION_UPDATE_NEXT_PRAYER_WIDGET"
        private const val KEY_CITY = "city_name"
        private const val KEY_PRAYER = "next_prayer_name"
        private const val KEY_TIME = "next_prayer_time_millis"
        private const val KEY_TIME_LABEL = "next_prayer_time_label"
        private const val KEY_PRAYERS_JSON = "future_prayers_json"
        private const val NEXT_PRAYER_REQUEST_CODE = 16001

        private data class PrayerEntry(
            val name: String,
            val timeMillis: Long,
            val timeLabel: String,
        )

        fun saveAndUpdate(
            context: Context,
            manager: AppWidgetManager,
            widgetIds: IntArray,
            cityName: String,
            prayerName: String,
            prayerTimeMillis: Long,
            prayerTimeLabel: String,
            futurePrayers: List<Map<String, Any>>,
        ) {
            val encodedPrayers = JSONArray()
            futurePrayers.forEach { entry ->
                val name = entry["prayerName"] as? String ?: return@forEach
                val at = (entry["prayerTimeMillis"] as? Number)?.toLong() ?: return@forEach
                if (at <= 0L) return@forEach
                encodedPrayers.put(
                    JSONObject()
                        .put("prayerName", name)
                        .put("prayerTimeMillis", at)
                        .put("timeLabel", entry["timeLabel"] as? String ?: ""),
                )
            }

            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_CITY, cityName)
                .putString(KEY_PRAYER, prayerName)
                .putLong(KEY_TIME, prayerTimeMillis)
                .putString(KEY_TIME_LABEL, prayerTimeLabel)
                .putString(KEY_PRAYERS_JSON, encodedPrayers.toString())
                .apply()
            updateAll(context, manager, widgetIds)
        }

        fun updateAll(
            context: Context,
            manager: AppWidgetManager,
            widgetIds: IntArray,
        ) {
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            if (widgetIds.isEmpty()) {
                cancelNextPrayerUpdate(context)
                return
            }

            val cityName = preferences.getString(KEY_CITY, null)
            val nowMillis = System.currentTimeMillis()
            val nextPrayer = readFuturePrayers(preferences.getString(KEY_PRAYERS_JSON, null))
                .filter { it.timeMillis > nowMillis }
                .minByOrNull { it.timeMillis }

            val prayerName = nextPrayer?.name
                ?: preferences.getString(KEY_PRAYER, null)
            val prayerTimeMillis = nextPrayer?.timeMillis
                ?: preferences.getLong(KEY_TIME, 0L)
            val prayerTimeLabel = nextPrayer?.timeLabel?.takeIf { it.isNotBlank() }
                ?: preferences.getString(KEY_TIME_LABEL, null)

            if (nextPrayer != null) {
                preferences.edit()
                    .putString(KEY_PRAYER, nextPrayer.name)
                    .putLong(KEY_TIME, nextPrayer.timeMillis)
                    .putString(KEY_TIME_LABEL, nextPrayer.timeLabel)
                    .apply()
            }

            widgetIds.forEach { widgetId ->
                val views = RemoteViews(context.packageName, R.layout.firdaws_prayer_widget)
                views.setTextViewText(
                    R.id.widget_city,
                    cityName?.takeIf { it.isNotBlank() } ?: "افتح الفردوس لتحديد مدينتك",
                )
                views.setTextViewText(
                    R.id.widget_next_prayer,
                    prayerName?.takeIf { it.isNotBlank() }?.let { "الصلاة القادمة: $it" }
                        ?: "الصلاة القادمة",
                )

                if (prayerTimeMillis > nowMillis) {
                    val displayTime = prayerTimeLabel?.takeIf { it.isNotBlank() }
                        ?: SimpleDateFormat("hh:mm a", Locale("ar")).format(Date(prayerTimeMillis))
                    views.setTextViewText(R.id.widget_prayer_time, displayTime)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        val remainingMillis = prayerTimeMillis - nowMillis
                        val base = SystemClock.elapsedRealtime() + remainingMillis
                        views.setChronometerCountDown(R.id.widget_countdown, true)
                        views.setChronometer(
                            R.id.widget_countdown,
                            base,
                            "متبقٍ %s",
                            true,
                        )
                        views.setViewVisibility(R.id.widget_countdown, View.VISIBLE)
                    } else {
                        views.setTextViewText(R.id.widget_countdown, "افتح الفردوس لتحديث العداد")
                        views.setViewVisibility(R.id.widget_countdown, View.VISIBLE)
                    }
                } else {
                    views.setTextViewText(R.id.widget_prayer_time, "—")
                    views.setTextViewText(R.id.widget_countdown, "افتح الفردوس لمزامنة المواقيت")
                    views.setViewVisibility(R.id.widget_countdown, View.VISIBLE)
                }

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val launchPendingIntent = PendingIntent.getActivity(
                    context,
                    widgetId,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, launchPendingIntent)
                manager.updateAppWidget(widgetId, views)
            }

            scheduleNextPrayerUpdate(context, prayerTimeMillis)
        }

        private fun readFuturePrayers(raw: String?): List<PrayerEntry> {
            if (raw.isNullOrBlank()) return emptyList()
            return try {
                val array = JSONArray(raw)
                (0 until array.length()).mapNotNull { index ->
                    val item = array.optJSONObject(index) ?: return@mapNotNull null
                    val at = item.optLong("prayerTimeMillis", 0L)
                    if (at <= 0L) return@mapNotNull null
                    PrayerEntry(
                        name = item.optString("prayerName", "الصلاة القادمة"),
                        timeMillis = at,
                        timeLabel = item.optString("timeLabel", ""),
                    )
                }
            } catch (_: Exception) {
                emptyList()
            }
        }

        private fun scheduleNextPrayerUpdate(context: Context, triggerAtMillis: Long) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, FirdawsPrayerWidgetProvider::class.java).apply {
                action = ACTION_UPDATE_NEXT_PRAYER
                setPackage(context.packageName)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                NEXT_PRAYER_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            try {
                alarmManager.cancel(pendingIntent)
                if (triggerAtMillis <= System.currentTimeMillis()) return
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent,
                    )
                } else {
                    alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
                }
            } catch (_: Exception) {}
        }

        private fun cancelNextPrayerUpdate(context: Context) {
            try {
                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val intent = Intent(context, FirdawsPrayerWidgetProvider::class.java).apply {
                    action = ACTION_UPDATE_NEXT_PRAYER
                    setPackage(context.packageName)
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    NEXT_PRAYER_REQUEST_CODE,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            } catch (_: Exception) {}
        }
    }
}
