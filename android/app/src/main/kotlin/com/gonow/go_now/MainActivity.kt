package com.gonow.go_now

import android.content.Context
import android.content.SharedPreferences
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.gonow.gotimesaver.GoNowWidgetProvider
import java.util.concurrent.TimeUnit

/**
 * GoNow 앱의 메인 액티비티 / Main Activity for GoNow app
 *
 * **역할 / Role**:
 * - Flutter와 Android 네이티브 간 MethodChannel 통신
 * - 위젯 데이터 업데이트 처리
 * - WorkManager 스케줄링 관리
 *
 * **Context**: Phase 3 - Android 위젯 구현
 */
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.gonow.widget"
    private val PREFS_NAME = "gonow_widget_prefs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    try {
                        val tripId = call.argument<String>("tripId")
                        val title = call.argument<String>("title")
                        val minutesRemaining = call.argument<Int>("minutesRemaining")
                        val colorPhase = call.argument<String>("colorPhase")
                        val departureTimeFormatted = call.argument<String>("departureTimeFormatted")
                        val arrivalTimeFormatted = call.argument<String>("arrivalTimeFormatted")
                        val timeRemainingText = call.argument<String>("timeRemainingText")
                        val travelDurationMinutes = call.argument<Int>("travelDurationMinutes")

                        // SharedPreferences에 위젯 데이터 저장 / Save widget data to SharedPreferences
                        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        prefs.edit().apply {
                            putString("tripId", tripId)
                            putString("title", title)
                            putInt("minutesRemaining", minutesRemaining ?: 0)
                            putString("colorPhase", colorPhase)
                            putString("departureTimeFormatted", departureTimeFormatted)
                            putString("arrivalTimeFormatted", arrivalTimeFormatted)
                            putString("timeRemainingText", timeRemainingText)
                            putInt("travelDurationMinutes", travelDurationMinutes ?: 0)
                            putLong("lastUpdated", System.currentTimeMillis())
                            apply()
                        }

                        // 위젯 갱신 트리거 / Trigger widget refresh
                        GoNowWidgetProvider.updateWidget(this)

                        // WorkManager 스케줄링 / Schedule WorkManager
                        scheduleWidgetUpdates(minutesRemaining ?: 30)

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UPDATE_FAILED", "Failed to update widget: ${e.message}", null)
                    }
                }

                "clearWidget" -> {
                    try {
                        // SharedPreferences 클리어 / Clear SharedPreferences
                        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                        prefs.edit().clear().apply()

                        // 위젯 갱신 / Refresh widget
                        GoNowWidgetProvider.updateWidget(this)

                        // WorkManager 작업 취소 / Cancel WorkManager tasks
                        WorkManager.getInstance(this).cancelUniqueWork("gonow_widget_update")

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CLEAR_FAILED", "Failed to clear widget: ${e.message}", null)
                    }
                }

                "forceRefresh" -> {
                    try {
                        GoNowWidgetProvider.updateWidget(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("REFRESH_FAILED", "Failed to refresh widget: ${e.message}", null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * WorkManager 스케줄링 / Schedule WorkManager updates
     *
     * **비즈니스 규칙 / Business Rule**:
     * - 30분 이상: 15분마다 업데이트
     * - 15-30분: 5분마다 업데이트
     * - 15분 이하: 3분마다 업데이트
     */
    private fun scheduleWidgetUpdates(minutesRemaining: Int) {
        val interval = when {
            minutesRemaining > 30 -> 15L
            minutesRemaining > 15 -> 5L
            else -> 3L
        }

        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
            .setRequiresBatteryNotLow(false)
            .build()

        val workRequest = PeriodicWorkRequestBuilder<com.gonow.gotimesaver.WidgetUpdateWorker>(
            interval, TimeUnit.MINUTES
        )
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "gonow_widget_update",
            ExistingPeriodicWorkPolicy.UPDATE,
            workRequest
        )
    }
}
