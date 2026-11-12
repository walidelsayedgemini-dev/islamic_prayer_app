package com.islamic.app.islamic_prayer_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class AdhanBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val act = intent.action ?: return
        if (act == Intent.ACTION_BOOT_COMPLETED ||
            act == Intent.ACTION_MY_PACKAGE_REPLACED ||
            act == Intent.ACTION_TIME_CHANGED ||
            act == Intent.ACTION_TIMEZONE_CHANGED ||
            act == "android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED" ||
            act == "android.intent.action.QUICKBOOT_POWERON" ||
            act == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            AdhanAlarmScheduler.rescheduleFromStorage(context)
        }
    }
}
