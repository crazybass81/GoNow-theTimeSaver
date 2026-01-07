package com.gonow.gotimesaver

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

/**
 * GoNow 홈 위젯 / GoNow Home Widget
 *
 * **기능 / Features**:
 * - 다가오는 일정 표시
 * - 시간대별 색상 시스템 (초록/주황/빨강/진한빨강)
 * - 남은 시간 카운트다운
 * - 출발 시간 표시
 *
 * **Context**: Phase 3 - Jetpack Glance 위젯 구현
 */
class GoNowWidget : GlanceAppWidget() {

    companion object {
        private const val PREFS_NAME = "gonow_widget_prefs"

        /**
         * 위젯 강제 갱신 / Force refresh widget
         */
        fun updateWidget(context: Context) {
            val glanceId = GlanceAppWidgetManager(context)
                .getGlanceIds(GoNowWidget::class.java)
                .firstOrNull()

            glanceId?.let {
                GoNowWidget().update(context, it)
            }
        }
    }

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val tripId = prefs.getString("tripId", null)

            if (tripId == null) {
                EmptyWidget()
            } else {
                TripWidget(
                    title = prefs.getString("title", "") ?: "",
                    minutesRemaining = prefs.getInt("minutesRemaining", 0),
                    colorPhase = prefs.getString("colorPhase", "green") ?: "green",
                    departureTime = prefs.getString("departureTimeFormatted", "") ?: "",
                    timeRemainingText = prefs.getString("timeRemainingText", "") ?: ""
                )
            }
        }
    }

    /**
     * 빈 위젯 UI / Empty widget UI
     */
    @Composable
    private fun EmptyWidget() {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(Color(0xFFF5F5F5))
                .padding(16.dp)
                .cornerRadius(16.dp),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "📅",
                    style = TextStyle(
                        fontSize = 32.sp
                    )
                )
                Spacer(modifier = GlanceModifier.height(8.dp))
                Text(
                    text = "일정이 없습니다",
                    style = TextStyle(
                        fontSize = 14.sp,
                        color = ColorProvider(Color(0xFF666666))
                    )
                )
                Spacer(modifier = GlanceModifier.height(4.dp))
                Text(
                    text = "새 일정을 추가하세요",
                    style = TextStyle(
                        fontSize = 12.sp,
                        color = ColorProvider(Color(0xFF999999))
                    )
                )
            }
        }
    }

    /**
     * 일정 표시 위젯 UI / Trip display widget UI
     *
     * **시간대별 색상 / Color phases**:
     * - 30분 이상: 초록색 (여유)
     * - 15-30분: 주황색 (준비)
     * - 0-15분: 빨간색 (긴급)
     * - 지각: 진한 빨간색 (초과)
     */
    @Composable
    private fun TripWidget(
        title: String,
        minutesRemaining: Int,
        colorPhase: String,
        departureTime: String,
        timeRemainingText: String
    ) {
        val backgroundColor = when (colorPhase) {
            "green" -> Color(0xFF4CAF50)
            "orange" -> Color(0xFFFF9800)
            "red" -> Color(0xFFF44336)
            "dark_red" -> Color(0xFFB71C1C)
            else -> Color(0xFF4CAF50)
        }

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(backgroundColor)
                .padding(16.dp)
                .cornerRadius(16.dp)
                .clickable {
                    // 앱 열기 액션 추가 가능
                }
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Top,
                horizontalAlignment = Alignment.Start
            ) {
                // 제목 / Title
                Text(
                    text = title,
                    style = TextStyle(
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(Color.White)
                    )
                )

                Spacer(modifier = GlanceModifier.height(8.dp))

                // 남은 시간 / Time remaining
                Text(
                    text = timeRemainingText,
                    style = TextStyle(
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(Color.White)
                    )
                )

                Spacer(modifier = GlanceModifier.height(8.dp))

                // 출발 시간 / Departure time
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "🚗 출발: ",
                        style = TextStyle(
                            fontSize = 14.sp,
                            color = ColorProvider(Color.White.copy(alpha = 0.9f))
                        )
                    )
                    Text(
                        text = departureTime,
                        style = TextStyle(
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold,
                            color = ColorProvider(Color.White)
                        )
                    )
                }

                Spacer(modifier = GlanceModifier.height(4.dp))

                // 상태 메시지 / Status message
                val statusMessage = when (colorPhase) {
                    "green" -> "✅ 여유있어요"
                    "orange" -> "⚠️ 준비하세요"
                    "red" -> "🚨 지금 출발!"
                    "dark_red" -> "❌ 지각 위험!"
                    else -> ""
                }

                if (statusMessage.isNotEmpty()) {
                    Text(
                        text = statusMessage,
                        style = TextStyle(
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = ColorProvider(Color.White.copy(alpha = 0.95f))
                        )
                    )
                }
            }
        }
    }
}

/**
 * 위젯 BroadcastReceiver / Widget BroadcastReceiver
 */
class GoNowWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = GoNowWidget()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        // 위젯 업데이트 로직
    }
}
