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

    private data class ScheduledAlarm(
        val triggerAtMillis: Long,
        val voiceId: String,
        val prayerName: String,
        val inputOrder: Int
    )

    fun saveAndSchedule(context: Context, alarms: List<Map<String, Any>>) {
        val parsed = alarms.mapIndexedNotNull { index, alarm ->
            val triggerMillis = (alarm["triggerAtMillis"] as? Number)?.toLong() ?: return@mapIndexedNotNull null
            ScheduledAlarm(
                triggerAtMillis = triggerMillis,
                voiceId = alarm["voiceId"] as? String ?: "madinah",
                prayerName = alarm["prayerName"] as? String ?: "صلاة الفرض",
                inputOrder = index
            )
        }
        val normalized = normalizeAlarms(parsed)
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_ALARMS_JSON, encodeAlarms(normalized).toString())
            .apply()

        rescheduleFromStorage(context)
    }

    fun rescheduleFromStorage(context: Context): Int {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // إلغاء المعرفات السابقة 101..115 مع إبقاء أرقام الطلبات الثابتة.
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
        val alarms = normalizeAlarms(parseAlarms(rawJson))
        val now = System.currentTimeMillis()
        var scheduledCount = 0

        for (alarm in alarms) {
            if (scheduledCount >= MAX_ALARMS) break
            val triggerMillis = alarm.triggerAtMillis
            if (triggerMillis <= now) continue
            val voiceId = alarm.voiceId
            val prayerName = alarm.prayerName

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
            // AlarmClock هو الخيار الأقوى لتجاوز Doze وقيود البطارية.
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

        return scheduledCount
    }

    fun getScheduledFutureCount(context: Context): Int {
        val rawJson = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_ALARMS_JSON, null) ?: return 0
        val now = System.currentTimeMillis()
        return normalizeAlarms(parseAlarms(rawJson)).count { it.triggerAtMillis > now }
    }

    private fun normalizeAlarms(alarms: List<ScheduledAlarm>): List<ScheduledAlarm> {
        val ordered = alarms.sortedWith(
            compareBy<ScheduledAlarm> { it.triggerAtMillis }.thenBy { it.inputOrder }
        )
        val seenMinutes = HashSet<Long>()
        return ordered.filter { alarm ->
            // اختيار أقرب موعد في الدقيقة عند وجود مدخلات متقاربة، مع ثبات ترتيب التعادل.
            seenMinutes.add(alarm.triggerAtMillis / 60_000L)
        }.take(MAX_ALARMS)
    }

    private fun parseAlarms(rawJson: String): List<ScheduledAlarm> {
        return try {
            val arr = JSONArray(rawJson)
            (0 until arr.length()).mapNotNull { index ->
                val obj = arr.getJSONObject(index)
                val triggerMillis = obj.optLong("triggerAtMillis", 0L)
                if (triggerMillis <= 0L) {
                    null
                } else {
                    ScheduledAlarm(
                        triggerAtMillis = triggerMillis,
                        voiceId = obj.optString("voiceId", "madinah"),
                        prayerName = obj.optString("prayerName", "صلاة الفرض"),
                        inputOrder = index
                    )
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun encodeAlarms(alarms: List<ScheduledAlarm>): JSONArray = JSONArray().apply {
        alarms.forEach { alarm ->
            put(JSONObject().apply {
                put("triggerAtMillis", alarm.triggerAtMillis)
                put("voiceId", alarm.voiceId)
                put("prayerName", alarm.prayerName)
            })
        }
    }
}
