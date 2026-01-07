import UIKit
import Flutter

/**
 * GoNow 앱의 AppDelegate / AppDelegate for GoNow app
 *
 * **역할 / Role**:
 * - Flutter와 iOS 네이티브 간 MethodChannel 통신
 * - 위젯 데이터 업데이트 처리
 * - UserDefaults를 통한 App Group 데이터 공유
 *
 * **Context**: Phase 3 - iOS 위젯 구현
 */
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private let CHANNEL = "com.gonow.widget"
    private let APP_GROUP = "group.com.gonow.gotimesaver"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller = window?.rootViewController as! FlutterViewController

        // MethodChannel 설정 / Setup MethodChannel
        let widgetChannel = FlutterMethodChannel(
            name: CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )

        widgetChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "AppDelegate not available", details: nil))
                return
            }

            switch call.method {
            case "updateWidget":
                self.handleUpdateWidget(call: call, result: result)

            case "clearWidget":
                self.handleClearWidget(result: result)

            case "forceRefresh":
                self.handleForceRefresh(result: result)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /**
     * 위젯 업데이트 처리 / Handle widget update
     *
     * **비즈니스 규칙 / Business Rule**:
     * - App Group UserDefaults에 데이터 저장
     * - WidgetCenter를 통해 위젯 갱신
     */
    private func handleUpdateWidget(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        // Flutter에서 전달받은 데이터 / Data from Flutter
        let tripId = args["tripId"] as? String ?? ""
        let title = args["title"] as? String ?? ""
        let minutesRemaining = args["minutesRemaining"] as? Int ?? 0
        let colorPhase = args["colorPhase"] as? String ?? "green"
        let departureTimeFormatted = args["departureTimeFormatted"] as? String ?? ""
        let timeRemainingText = args["timeRemainingText"] as? String ?? ""

        // App Group UserDefaults에 저장 / Save to App Group UserDefaults
        if let sharedDefaults = UserDefaults(suiteName: APP_GROUP) {
            sharedDefaults.set(tripId, forKey: "tripId")
            sharedDefaults.set(title, forKey: "title")
            sharedDefaults.set(minutesRemaining, forKey: "minutesRemaining")
            sharedDefaults.set(colorPhase, forKey: "colorPhase")
            sharedDefaults.set(departureTimeFormatted, forKey: "departureTimeFormatted")
            sharedDefaults.set(timeRemainingText, forKey: "timeRemainingText")
            sharedDefaults.set(Date(), forKey: "lastUpdated")
            sharedDefaults.synchronize()

            // 위젯 갱신 / Refresh widget
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }

            result(true)
        } else {
            result(FlutterError(
                code: "SHARED_DEFAULTS_ERROR",
                message: "Failed to access App Group UserDefaults",
                details: nil
            ))
        }
    }

    /**
     * 위젯 클리어 처리 / Handle widget clear
     */
    private func handleClearWidget(result: @escaping FlutterResult) {
        if let sharedDefaults = UserDefaults(suiteName: APP_GROUP) {
            sharedDefaults.removeObject(forKey: "tripId")
            sharedDefaults.removeObject(forKey: "title")
            sharedDefaults.removeObject(forKey: "minutesRemaining")
            sharedDefaults.removeObject(forKey: "colorPhase")
            sharedDefaults.removeObject(forKey: "departureTimeFormatted")
            sharedDefaults.removeObject(forKey: "timeRemainingText")
            sharedDefaults.removeObject(forKey: "lastUpdated")
            sharedDefaults.synchronize()

            // 위젯 갱신 / Refresh widget
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }

            result(true)
        } else {
            result(FlutterError(
                code: "SHARED_DEFAULTS_ERROR",
                message: "Failed to access App Group UserDefaults",
                details: nil
            ))
        }
    }

    /**
     * 위젯 강제 갱신 / Force refresh widget
     */
    private func handleForceRefresh(result: @escaping FlutterResult) {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            result(true)
        } else {
            result(FlutterError(
                code: "UNSUPPORTED_VERSION",
                message: "WidgetKit requires iOS 14.0 or later",
                details: nil
            ))
        }
    }
}
