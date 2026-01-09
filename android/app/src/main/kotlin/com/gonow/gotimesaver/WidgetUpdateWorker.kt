package com.gonow.gotimesaver

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

/**
 * 위젯 자동 업데이트 Worker / Widget auto-update worker
 *
 * **역할 / Role**:
 * - 백그라운드에서 주기적으로 위젯 갱신
 * - SharedPreferences 데이터 기반 업데이트
 * - 배터리 효율적인 업데이트 전략
 *
 * **비즈니스 규칙 / Business Rule**:
 * - 데이터가 없으면 작업 건너뛰기
 * - 마지막 업데이트 시간 확인
 * - 위젯 갱신만 수행 (API 호출 없음)
 *
 * **Context**: Phase 3 - WorkManager 백그라운드 작업
 */
class WidgetUpdateWorker(
    private val context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val PREFS_NAME = "gonow_widget_prefs"
        private const val TAG = "WidgetUpdateWorker"
    }

    override suspend fun doWork(): Result {
        return try {
            // SharedPreferences에서 위젯 데이터 확인 / Check widget data from SharedPreferences
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val tripId = prefs.getString("tripId", null)

            if (tripId == null) {
                // 데이터 없음, 작업 종료 / No data, finish work
                android.util.Log.d(TAG, "No trip data, skipping update")
                return Result.success()
            }

            // 마지막 업데이트 시간 확인 / Check last update time
            val lastUpdated = prefs.getLong("lastUpdated", 0)
            val currentTime = System.currentTimeMillis()
            val timeSinceUpdate = (currentTime - lastUpdated) / 1000 / 60 // 분 단위

            android.util.Log.d(TAG, "Time since last update: $timeSinceUpdate minutes")

            // 남은 시간 재계산 / Recalculate remaining time
            val originalMinutesRemaining = prefs.getInt("minutesRemaining", 0)
            val updatedMinutesRemaining = originalMinutesRemaining - timeSinceUpdate.toInt()

            // 색상 단계 재계산 / Recalculate color phase
            val colorPhase = when {
                updatedMinutesRemaining > 30 -> "green"
                updatedMinutesRemaining > 15 -> "orange"
                updatedMinutesRemaining > 0 -> "red"
                else -> "dark_red"
            }

            // 시간 텍스트 재계산 / Recalculate time text
            val timeRemainingText = formatTimeRemaining(updatedMinutesRemaining)

            // SharedPreferences 업데이트 / Update SharedPreferences
            prefs.edit().apply {
                putInt("minutesRemaining", updatedMinutesRemaining)
                putString("colorPhase", colorPhase)
                putString("timeRemainingText", timeRemainingText)
                putLong("lastUpdated", currentTime)
                apply()
            }

            // 위젯 갱신 / Refresh widget
            GoNowWidgetProvider.updateWidget(context)

            android.util.Log.d(TAG, "Widget updated successfully: $updatedMinutesRemaining minutes remaining")

            Result.success()
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to update widget: ${e.message}", e)
            Result.failure()
        }
    }

    /**
     * 남은 시간 포맷팅 / Format remaining time
     *
     * **포맷 규칙 / Format rules**:
     * - 60분 이상: "Xh Ym"
     * - 60분 미만: "Xm"
     * - 0분 이하: "지각!"
     */
    private fun formatTimeRemaining(minutes: Int): String {
        return when {
            minutes <= 0 -> "지각!"
            minutes < 60 -> "${minutes}분"
            else -> {
                val hours = minutes / 60
                val mins = minutes % 60
                if (mins == 0) {
                    "${hours}시간"
                } else {
                    "${hours}시간 ${mins}분"
                }
            }
        }
    }
}
