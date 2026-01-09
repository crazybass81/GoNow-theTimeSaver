#!/bin/bash

# GoNow 배터리 소모 측정 스크립트 / Battery Consumption Measurement Script
# Usage: ./measure_battery.sh [duration_hours]

PACKAGE_NAME="com.gonow.gotimesaver"
DURATION_HOURS=${1:-6}  # 기본 6시간 / Default 6 hours
DURATION_SECONDS=$((DURATION_HOURS * 3600))

echo "=========================================="
echo "GoNow 배터리 소모 측정 / Battery Measurement"
echo "=========================================="
echo "패키지: $PACKAGE_NAME"
echo "측정 시간: ${DURATION_HOURS}시간 / ${DURATION_HOURS} hours"
echo ""

# 1. 디바이스 연결 확인 / Check device connection
echo "[1/5] 디바이스 연결 확인 / Checking device..."
DEVICE=$(adb devices | grep "device$" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo "❌ 디바이스가 연결되지 않았습니다 / No device connected"
    exit 1
fi
echo "✅ 디바이스 연결됨: $DEVICE / Device connected: $DEVICE"
echo ""

# 2. 앱 실행 확인 / Check app running
echo "[2/5] 앱 실행 확인 / Checking if app is running..."
APP_RUNNING=$(adb shell "ps | grep $PACKAGE_NAME")
if [ -z "$APP_RUNNING" ]; then
    echo "⚠️  앱이 실행되지 않음. 시작합니다 / App not running. Starting..."
    adb shell am start -n $PACKAGE_NAME/.MainActivity
    sleep 5
else
    echo "✅ 앱 실행 중 / App is running"
fi
echo ""

# 3. 배터리 통계 초기화 / Reset battery stats
echo "[3/5] 배터리 통계 초기화 / Resetting battery stats..."
adb shell dumpsys batterystats --reset
adb shell dumpsys batterystats --enable full-wake-history
echo "✅ 배터리 통계 초기화 완료 / Battery stats reset"
echo ""

# 4. 초기 배터리 레벨 확인 / Get initial battery level
echo "[4/5] 초기 배터리 레벨 확인 / Getting initial battery level..."
INITIAL_LEVEL=$(adb shell dumpsys battery | grep level | awk '{print $2}')
INITIAL_TIME=$(date +%s)
echo "✅ 초기 배터리: ${INITIAL_LEVEL}% / Initial battery: ${INITIAL_LEVEL}%"
echo "✅ 시작 시간: $(date '+%Y-%m-%d %H:%M:%S') / Start time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 5. 측정 대기 / Wait for duration
echo "[5/5] 배터리 소모 측정 중... / Measuring battery consumption..."
echo "⏳ ${DURATION_HOURS}시간 대기 / Waiting ${DURATION_HOURS} hours..."
echo "   (Ctrl+C로 중단 가능 / Press Ctrl+C to cancel)"
echo ""

# 매 30분마다 중간 결과 출력 / Print intermediate results every 30 minutes
INTERVAL=1800  # 30분 / 30 minutes
ELAPSED=0

while [ $ELAPSED -lt $DURATION_SECONDS ]; do
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))

    CURRENT_LEVEL=$(adb shell dumpsys battery | grep level | awk '{print $2}')
    HOURS_ELAPSED=$(echo "scale=1; $ELAPSED / 3600" | bc)
    CONSUMED=$((INITIAL_LEVEL - CURRENT_LEVEL))
    RATE=$(echo "scale=2; $CONSUMED / $HOURS_ELAPSED" | bc)

    echo "⏱️  경과: ${HOURS_ELAPSED}시간 / Elapsed: ${HOURS_ELAPSED}h"
    echo "   현재 배터리: ${CURRENT_LEVEL}% / Current: ${CURRENT_LEVEL}%"
    echo "   소모량: ${CONSUMED}% / Consumed: ${CONSUMED}%"
    echo "   시간당 소모율: ${RATE}%/h / Rate: ${RATE}%/h"
    echo ""
done

# 6. 최종 결과 / Final results
echo "=========================================="
echo "측정 완료 / Measurement Complete"
echo "=========================================="

FINAL_LEVEL=$(adb shell dumpsys battery | grep level | awk '{print $2}')
FINAL_TIME=$(date +%s)
TOTAL_TIME=$(((FINAL_TIME - INITIAL_TIME) / 3600))
TOTAL_CONSUMED=$((INITIAL_LEVEL - FINAL_LEVEL))
HOURLY_RATE=$(echo "scale=2; $TOTAL_CONSUMED / $TOTAL_TIME" | bc)

echo "⏱️  총 측정 시간: ${TOTAL_TIME}시간 / Total time: ${TOTAL_TIME}h"
echo "🔋 초기 배터리: ${INITIAL_LEVEL}% / Initial: ${INITIAL_LEVEL}%"
echo "🔋 최종 배터리: ${FINAL_LEVEL}% / Final: ${FINAL_LEVEL}%"
echo "📊 총 소모량: ${TOTAL_CONSUMED}% / Total consumed: ${TOTAL_CONSUMED}%"
echo "📊 시간당 소모율: ${HOURLY_RATE}%/h / Hourly rate: ${HOURLY_RATE}%/h"
echo ""

# 7. 목표 달성 여부 / Check if target met
TARGET_RATE=2.0
if (( $(echo "$HOURLY_RATE < $TARGET_RATE" | bc -l) )); then
    echo "✅ 목표 달성! (< ${TARGET_RATE}%/h) / Target met! (< ${TARGET_RATE}%/h)"
else
    echo "⚠️  목표 미달성 (> ${TARGET_RATE}%/h) / Target not met (> ${TARGET_RATE}%/h)"
fi
echo ""

# 8. 상세 통계 저장 / Save detailed stats
REPORT_FILE="battery_report_$(date +%Y%m%d_%H%M%S).txt"
echo "📝 상세 리포트 저장 중... / Saving detailed report..."
adb shell dumpsys batterystats $PACKAGE_NAME > "$REPORT_FILE"
echo "✅ 리포트 저장됨: $REPORT_FILE / Report saved: $REPORT_FILE"
echo ""

echo "=========================================="
echo "측정 완료! / Measurement Complete!"
echo "=========================================="
