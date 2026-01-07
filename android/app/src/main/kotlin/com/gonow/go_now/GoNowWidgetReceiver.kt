package com.gonow.go_now

import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import com.gonow.gotimesaver.GoNowWidget

/**
 * GoNow 위젯 리시버 / GoNow Widget Receiver
 *
 * **기능 / Features**:
 * - Glance 위젯 시스템과 통합
 * - 위젯 업데이트 요청 처리
 * - WorkManager 스케줄링 트리거
 *
 * **Context**: Android 홈 화면 위젯 진입점
 */
class GoNowWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = GoNowWidget()
}
