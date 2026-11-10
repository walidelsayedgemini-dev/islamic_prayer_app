package com.islamic.app.islamic_prayer_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class SalawatAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val rescheduleMins = intent.getIntExtra(
            SalawatOverlayService.EXTRA_RESCHEDULE_MINUTES,
            0
        )
        val serviceIntent = Intent(context, SalawatOverlayService::class.java).apply {
            putExtra(SalawatOverlayService.EXTRA_RESCHEDULE_MINUTES, rescheduleMins)
        }
        try {
            context.startService(serviceIntent)
        } catch (_: Exception) {}
    }
}
