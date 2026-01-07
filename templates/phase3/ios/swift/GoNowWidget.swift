import WidgetKit
import SwiftUI

/**
 * GoNow 홈 위젯 / GoNow Home Widget
 *
 * **기능 / Features**:
 * - 다가오는 일정 표시
 * - 시간대별 색상 시스템 (초록/주황/빨강/진한빨강)
 * - 남은 시간 카운트다운
 * - 출발 시간 표시
 *
 * **Context**: Phase 3 - WidgetKit 구현
 */

// MARK: - Widget Entry

struct GoNowEntry: TimelineEntry {
    let date: Date
    let tripId: String?
    let title: String
    let minutesRemaining: Int
    let colorPhase: String
    let departureTime: String
    let timeRemainingText: String
}

// MARK: - Timeline Provider

struct GoNowProvider: TimelineProvider {

    private let APP_GROUP = "group.com.gonow.gotimesaver"

    // 위젯이 로딩될 때 표시 / Display when widget is loading
    func placeholder(in context: Context) -> GoNowEntry {
        GoNowEntry(
            date: Date(),
            tripId: nil,
            title: "",
            minutesRemaining: 0,
            colorPhase: "green",
            departureTime: "",
            timeRemainingText: ""
        )
    }

    // 위젯 갤러리에서 표시 / Display in widget gallery
    func getSnapshot(in context: Context, completion: @escaping (GoNowEntry) -> Void) {
        let entry = GoNowEntry(
            date: Date(),
            tripId: "sample",
            title: "회의",
            minutesRemaining: 25,
            colorPhase: "green",
            departureTime: "14:30",
            timeRemainingText: "25분"
        )
        completion(entry)
    }

    // 실제 위젯 데이터 제공 / Provide actual widget data
    func getTimeline(in context: Context, completion: @escaping (Timeline<GoNowEntry>) -> Void) {
        guard let sharedDefaults = UserDefaults(suiteName: APP_GROUP) else {
            let entry = createEmptyEntry()
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
            return
        }

        let tripId = sharedDefaults.string(forKey: "tripId")

        if tripId == nil {
            // 일정 없음 / No trip
            let entry = createEmptyEntry()
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        } else {
            // 일정 있음 / Trip exists
            let title = sharedDefaults.string(forKey: "title") ?? ""
            let minutesRemaining = sharedDefaults.integer(forKey: "minutesRemaining")
            let colorPhase = sharedDefaults.string(forKey: "colorPhase") ?? "green"
            let departureTime = sharedDefaults.string(forKey: "departureTimeFormatted") ?? ""
            let timeRemainingText = sharedDefaults.string(forKey: "timeRemainingText") ?? ""

            let currentEntry = GoNowEntry(
                date: Date(),
                tripId: tripId,
                title: title,
                minutesRemaining: minutesRemaining,
                colorPhase: colorPhase,
                departureTime: departureTime,
                timeRemainingText: timeRemainingText
            )

            // 다음 업데이트 시간 계산 / Calculate next update time
            let nextUpdateInterval = getUpdateInterval(minutesRemaining: minutesRemaining)
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: nextUpdateInterval, to: Date()) ?? Date()

            // Timeline 생성 / Create timeline
            let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }

    /**
     * 빈 엔트리 생성 / Create empty entry
     */
    private func createEmptyEntry() -> GoNowEntry {
        GoNowEntry(
            date: Date(),
            tripId: nil,
            title: "",
            minutesRemaining: 0,
            colorPhase: "green",
            departureTime: "",
            timeRemainingText: ""
        )
    }

    /**
     * 업데이트 간격 계산 / Calculate update interval
     *
     * **비즈니스 규칙 / Business Rule**:
     * - 30분 이상: 15분마다
     * - 15-30분: 5분마다
     * - 15분 이하: 3분마다
     */
    private func getUpdateInterval(minutesRemaining: Int) -> Int {
        if minutesRemaining > 30 {
            return 15
        } else if minutesRemaining > 15 {
            return 5
        } else {
            return 3
        }
    }
}

// MARK: - Widget View

struct GoNowWidgetView: View {
    let entry: GoNowEntry

    var body: some View {
        if entry.tripId == nil {
            EmptyWidgetView()
        } else {
            TripWidgetView(entry: entry)
        }
    }
}

// MARK: - Empty Widget View

struct EmptyWidgetView: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5

            VStack(spacing: 8) {
                Text("📅")
                    .font(.system(size: 32))

                Text("일정이 없습니다")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))

                Text("새 일정을 추가하세요")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
        }
        .cornerRadius(16)
    }
}

// MARK: - Trip Widget View

struct TripWidgetView: View {
    let entry: GoNowEntry

    var backgroundColor: Color {
        switch entry.colorPhase {
        case "green":
            return Color(red: 0.30, green: 0.69, blue: 0.31) // #4CAF50
        case "orange":
            return Color(red: 1.0, green: 0.60, blue: 0.0) // #FF9800
        case "red":
            return Color(red: 0.96, green: 0.26, blue: 0.21) // #F44336
        case "dark_red":
            return Color(red: 0.72, green: 0.11, blue: 0.11) // #B71C1C
        default:
            return Color(red: 0.30, green: 0.69, blue: 0.31)
        }
    }

    var statusMessage: String {
        switch entry.colorPhase {
        case "green":
            return "✅ 여유있어요"
        case "orange":
            return "⚠️ 준비하세요"
        case "red":
            return "🚨 지금 출발!"
        case "dark_red":
            return "❌ 지각 위험!"
        default:
            return ""
        }
    }

    var body: some View {
        ZStack {
            backgroundColor

            VStack(alignment: .leading, spacing: 8) {
                // 제목 / Title
                Text(entry.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer().frame(height: 8)

                // 남은 시간 / Time remaining
                Text(entry.timeRemainingText)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Spacer().frame(height: 8)

                // 출발 시간 / Departure time
                HStack(spacing: 4) {
                    Text("🚗 출발:")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))

                    Text(entry.departureTime)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer().frame(height: 4)

                // 상태 메시지 / Status message
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                }

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .cornerRadius(16)
    }
}

// MARK: - Widget Configuration

@main
struct GoNowWidget: Widget {
    let kind: String = "GoNowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GoNowProvider()) { entry in
            GoNowWidgetView(entry: entry)
        }
        .configurationDisplayName("GoNow 일정")
        .description("다가오는 일정과 출발 시간을 표시합니다")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

struct GoNowWidget_Previews: PreviewProvider {
    static var previews: some View {
        // 일정 있는 경우 / With trip
        GoNowWidgetView(entry: GoNowEntry(
            date: Date(),
            tripId: "sample",
            title: "회의",
            minutesRemaining: 25,
            colorPhase: "green",
            departureTime: "14:30",
            timeRemainingText: "25분"
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))

        // 일정 없는 경우 / Without trip
        GoNowWidgetView(entry: GoNowEntry(
            date: Date(),
            tripId: nil,
            title: "",
            minutesRemaining: 0,
            colorPhase: "green",
            departureTime: "",
            timeRemainingText: ""
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
