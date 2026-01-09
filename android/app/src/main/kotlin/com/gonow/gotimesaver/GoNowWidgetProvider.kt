package com.gonow.gotimesaver

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import com.gonow.go_now.R

/**
 * GoNow 홈 위젯 Provider / GoNow Home Widget Provider
 *
 * **기능 / Features**:
 * - 원형 프로그레스 표시 (CircularTimerWidget 디자인)
 * - 투명 배경
 * - 시간대별 프로그레스 색상
 * - RemoteViews 기반
 *
 * **Context**: Phase 3 - 안드로이드 홈 위젯 (Glance → RemoteViews 전환)
 */
class GoNowWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "gonow_widget_prefs"

        /**
         * 위젯 강제 갱신 / Force refresh widget
         */
        fun updateWidget(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, GoNowWidgetProvider::class.java)
            )

            val provider = GoNowWidgetProvider()
            provider.onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // SharedPreferences에서 데이터 읽기
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val tripId = prefs.getString("tripId", null)

        val views = if (tripId == null) {
            // 일정이 없을 때
            createEmptyWidget(context)
        } else {
            // 일정이 있을 때
            val title = prefs.getString("title", "") ?: ""
            val minutesRemaining = prefs.getInt("minutesRemaining", 0)
            val colorPhase = prefs.getString("colorPhase", "green") ?: "green"
            val departureTime = prefs.getString("departureTimeFormatted", "") ?: ""
            val arrivalTime = prefs.getString("arrivalTimeFormatted", "") ?: ""
            val timeRemainingText = prefs.getString("timeRemainingText", "") ?: ""
            val travelDurationMinutes = prefs.getInt("travelDurationMinutes", 0)

            createTripWidget(
                context,
                title,
                minutesRemaining,
                colorPhase,
                departureTime,
                arrivalTime,
                timeRemainingText,
                travelDurationMinutes
            )
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    /**
     * 빈 위젯 생성 / Create empty widget
     */
    private fun createEmptyWidget(context: Context): RemoteViews {
        return RemoteViews(context.packageName, R.layout.widget_initial_layout)
    }

    /**
     * 일정 표시 위젯 생성 / Create trip display widget
     */
    private fun createTripWidget(
        context: Context,
        title: String,
        minutesRemaining: Int,
        colorPhase: String,
        departureTime: String,
        arrivalTime: String,
        timeRemainingText: String,
        travelDurationMinutes: Int
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        // 프로그레스 색상 결정
        val progressColor = when (colorPhase) {
            "green" -> Color.parseColor("#4CAF50")
            "orange" -> Color.parseColor("#FF9800")
            "red" -> Color.parseColor("#F44336")
            "dark_red" -> Color.parseColor("#B71C1C")
            else -> Color.parseColor("#2196F3") // primary
        }

        // 프로그레스 값 계산 (0.0 ~ 1.0)
        // minutesRemaining이 0에 가까워질수록 progress는 1.0에 가까워짐
        val totalDuration = minutesRemaining + travelDurationMinutes
        val progress = if (totalDuration > 0) {
            1.0f - (minutesRemaining.toFloat() / totalDuration.toFloat())
        } else {
            1.0f
        }.coerceIn(0f, 1f)

        // 원형 프로그레스 이미지 생성
        val progressBitmap = createCircularProgressBitmap(
            size = 250,
            progress = progress,
            progressColor = progressColor,
            context = context
        )
        views.setImageViewBitmap(R.id.circular_progress, progressBitmap)

        // 텍스트 업데이트
        views.setTextViewText(R.id.time_remaining_text, timeRemainingText)
        views.setTextViewText(R.id.arrival_time_text, "$arrivalTime 도착")

        return views
    }

    /**
     * 원형 프로그레스 비트맵 생성 / Create circular progress bitmap
     */
    private fun createCircularProgressBitmap(
        size: Int,
        progress: Float,
        progressColor: Int,
        context: Context
    ): android.graphics.Bitmap {
        val density = context.resources.displayMetrics.density
        val sizePx = (size * density).toInt()
        val strokeWidth = 12f * density

        val bitmap = android.graphics.Bitmap.createBitmap(sizePx, sizePx, android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(bitmap)

        val centerX = sizePx / 2f
        val centerY = sizePx / 2f
        val radius = (sizePx / 2f) - (strokeWidth / 2f)

        val rect = android.graphics.RectF(
            centerX - radius,
            centerY - radius,
            centerX + radius,
            centerY + radius
        )

        // 배경 원형 페인트
        val backgroundPaint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply {
            style = android.graphics.Paint.Style.STROKE
            this.strokeWidth = strokeWidth
            color = Color.parseColor("#E0E0E0") // AppColors.divider
            strokeCap = android.graphics.Paint.Cap.ROUND
        }

        // 진행 원형 페인트
        val progressPaint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply {
            style = android.graphics.Paint.Style.STROKE
            this.strokeWidth = strokeWidth
            color = progressColor
            strokeCap = android.graphics.Paint.Cap.ROUND
        }

        // 배경 원형 그리기
        canvas.drawCircle(centerX, centerY, radius, backgroundPaint)

        // 진행 원형 그리기 (시계 방향, 12시 방향 시작)
        if (progress > 0f) {
            val sweepAngle = 360f * progress
            canvas.drawArc(rect, -90f, sweepAngle, false, progressPaint)
        }

        return bitmap
    }

    override fun onEnabled(context: Context) {
        // 첫 위젯이 생성될 때
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        // 마지막 위젯이 삭제될 때
        super.onDisabled(context)
    }
}
