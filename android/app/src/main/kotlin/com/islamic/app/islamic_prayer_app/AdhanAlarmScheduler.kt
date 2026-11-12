package com.islamic.app.islamic_prayer_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

object AdhanAlarmScheduler {
    private const val PREFS_NAME = "firdaws_adhan_scheduler_prefs"
    private const val KEY_ALARMS_JSON = "saved_prayer_alarms_json"
    private const val MAX_ALARMS = 15

    fun saveAndSchedule(context: Context, alarms: List<Map<String, Any>>) {
        val arr = JSONArray()
        for (a in alarms.take(MAX_ALARMS)) {
            val triggerMillis = (a["triggerAtMillis"] as? Number)?.toLong() ?: continue
            val voiceId = a["voiceId"] as? String ?: "madinah"
            val prayerName = a["prayerName"] as? String ?: "صلاة الفرض"
            val obj = JSONObject().apply {
                put("triggerAtMillis", triggerMillis)
                put("voiceId", voiceId)
                put("prayerName", prayerName)
            }
            arr.put(obj)
        }
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_ALARMS_JSON, arr.toString())
            .apply()

        rescheduleFromStorage(context)
    }

    fun rescheduleFromStorage(context: Context): Int {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // إلغاء المعرفات السابقة 101..115
        for (req in 101 until (101 + MAX_ALARMS)) {
            val cancelIntent = Intent(context, AdhanAlarmReceiver::class.java)
            val pi = PendingIntent.getBroadcast(
                context,
                req,
                cancelIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            am.cancel(pi)
        }

        val rawJson = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_ALARMS_JSON, null) ?: return 0

        val now = System.currentTimeMillis()
        var scheduledCount = 0

        try {
            val arr = JSONArray(rawJson)
            for (i in 0 until arr.length()) {
                if (scheduledCount >= MAX_ALARMS) break
                val obj = arr.getJSONObject(i)
                val triggerMillis = obj.optLong("triggerAtMillis", 0L)
                if (triggerMillis <= now) continue
                val voiceId = obj.optString("voiceId", "madinah")
                val prayerName = obj.optString("prayerName", "صلاة الفرض")

                val receiverIntent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                    putExtra(AdhanPlaybackService.EXTRA_VOICE_ID, voiceId)
                    putExtra(AdhanPlaybackService.EXTRA_PRAYER_NAME, prayerName)
                }
                val reqCode = 101 + scheduledCount
                val pi = PendingIntent.getBroadcast(
                    context,
                    reqCode,
                    receiverIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                val showIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("open_adhan_alarm", true)
                    putExtra("voice_id", voiceId)
                    putExtra("prayer_name", prayerName)
                }
                val showPending = PendingIntent.getActivity(
                    context,
                    501 + scheduledCount,
                    showIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                var placed = false
                // استخدام AlarmClock (الأقوى لاختراق وضع Doze وتقييد البطارية على أندرويد)
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        val canExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || am.canScheduleExactAlarms()
                        if (canExact) {
                            val info = AlarmManager.AlarmClockInfo(triggerMillis, showPending)
                            am.setAlarmClock(info, pi)
                            placed = true
                        }
                    }
                } catch (_: Exception) {}

                if (!placed) {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && am.canScheduleExactAlarms()) {
                            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerMillis, pi)
                            placed = true
                        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerMillis, pi)
                            placed = true
                        } else {
                            am.setExact(AlarmManager.RTC_WAKEUP, triggerMillis, pi)
                            placed = true
                        }
                    } catch (_: Exception) {
                        try {
                            am.set(AlarmManager.RTC_WAKEUP, triggerMillis, pi)
                            placed = true
                        } catch (_: Exception) {}
                    }
                }
                if (placed) scheduledCount++
            }
        } catch (_: Exception) {}

        return scheduledCount
    }

    fun getScheduledFutureCount(context: Context): Int {
        val rawJson = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_ALARMS_JSON, null) ?: return 0
        val now = System.currentTimeMillis()
        var cnt = 0
        try {
            val arr = JSONArray(rawJson)
            for (i in 0 until arr.length()) {
                val t = arr.getJSONObject(i).optLong("triggerAtMillis", 0L)
                if (t > now) cnt++
            }
        } catch (_: Exception) {}
        return cnt
    }
}
