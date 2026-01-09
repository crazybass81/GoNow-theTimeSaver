#!/bin/bash

# GoNow 앱 시작 속도 측정 스크립트 / App Start Speed Measurement Script
# Usage: ./measure_app_start.sh [iterations]

PACKAGE_NAME="com.gonow.gotimesaver"
ACTIVITY_NAME=".MainActivity"
ITERATIONS=${1:-10}  # 기본 10회 / Default 10 iterations

echo "=========================================="
echo "GoNow 앱 시작 속도 측정 / App Start Speed Measurement"
echo "=========================================="
echo "패키지: $PACKAGE_NAME"
echo "측정 횟수: ${ITERATIONS}회 / ${ITERATIONS} iterations"
echo ""

# 1. 디바이스 연결 확인 / Check device connection
echo "[1/3] 디바이스 연결 확인 / Checking device..."
DEVICE=$(adb devices | grep "device$" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo "❌ 디바이스가 연결되지 않았습니다 / No device connected"
    exit 1
fi
echo "✅ 디바이스 연결됨: $DEVICE / Device connected: $DEVICE"
echo ""

# 2. 앱 종료 (측정 전 클린 상태) / Kill app (clean state)
echo "[2/3] 앱 종료 (초기 상태 준비) / Killing app (preparing clean state)..."
adb shell am force-stop $PACKAGE_NAME
sleep 2
echo "✅ 앱 종료 완료 / App killed"
echo ""

# 3. Cold Start 측정 / Measure Cold Start
echo "[3/3] Cold Start 측정 중 / Measuring Cold Start..."
echo "⏳ ${ITERATIONS}회 측정... / Measuring ${ITERATIONS} times..."
echo ""

declare -a cold_start_times
declare -a warm_start_times

echo "측정 # | Cold Start (ms) | Warm Start (ms) | 상태"
echo "-------------------------------------------------------"

for i in $(seq 1 $ITERATIONS); do
    # Cold Start 측정 / Measure Cold Start
    # 앱 완전 종료 / Kill app completely
    adb shell am force-stop $PACKAGE_NAME
    sleep 3  # 완전 종료 대기 / Wait for complete shutdown

    # Cold Start 실행 및 시간 측정 / Launch and measure
    COLD_OUTPUT=$(adb shell am start-activity -W -n $PACKAGE_NAME/$ACTIVITY_NAME 2>&1)
    COLD_TIME=$(echo "$COLD_OUTPUT" | grep "TotalTime" | awk '{print $2}')

    # Warm Start 측정 / Measure Warm Start
    # 홈 버튼으로 백그라운드 이동 / Move to background
    adb shell input keyevent 3  # HOME key
    sleep 2

    # Warm Start 실행 및 시간 측정 / Launch and measure
    WARM_OUTPUT=$(adb shell am start-activity -W -n $PACKAGE_NAME/$ACTIVITY_NAME 2>&1)
    WARM_TIME=$(echo "$WARM_OUTPUT" | grep "TotalTime" | awk '{print $2}')

    # 상태 판단 / Determine status
    COLD_TARGET=2000  # 2초 / 2 seconds
    WARM_TARGET=1000  # 1초 / 1 second

    if [ $COLD_TIME -lt $COLD_TARGET ] && [ $WARM_TIME -lt $WARM_TARGET ]; then
        STATUS="✅ 통과"
    elif [ $COLD_TIME -gt $((COLD_TARGET + 1000)) ] || [ $WARM_TIME -gt $((WARM_TARGET + 500)) ]; then
        STATUS="❌ 느림"
    else
        STATUS="⚠️  주의"
    fi

    # 출력 / Print
    printf "%8d | %15d | %15d | %s\n" \
        "$i" \
        "$COLD_TIME" \
        "$WARM_TIME" \
        "$STATUS"

    # 배열에 저장 / Store in arrays
    cold_start_times[$((i-1))]=$COLD_TIME
    warm_start_times[$((i-1))]=$WARM_TIME

    # 다음 측정 전 대기 / Wait before next measurement
    sleep 2
done

echo ""
echo "=========================================="
echo "측정 완료 / Measurement Complete"
echo "=========================================="

# 통계 계산 / Calculate statistics

# Cold Start 통계 / Cold Start statistics
COLD_SUM=0
COLD_MAX=0
COLD_MIN=999999
for time in "${cold_start_times[@]}"; do
    COLD_SUM=$((COLD_SUM + time))
    if [ $time -gt $COLD_MAX ]; then COLD_MAX=$time; fi
    if [ $time -lt $COLD_MIN ]; then COLD_MIN=$time; fi
done
COLD_AVG=$((COLD_SUM / ITERATIONS))

# Warm Start 통계 / Warm Start statistics
WARM_SUM=0
WARM_MAX=0
WARM_MIN=999999
for time in "${warm_start_times[@]}"; do
    WARM_SUM=$((WARM_SUM + time))
    if [ $time -gt $WARM_MAX ]; then WARM_MAX=$time; fi
    if [ $time -lt $WARM_MIN ]; then WARM_MIN=$time; fi
done
WARM_AVG=$((WARM_SUM / ITERATIONS))

echo "📊 Cold Start 통계 / Cold Start Statistics:"
echo "   평균: ${COLD_AVG}ms ($(echo "scale=2; $COLD_AVG / 1000" | bc)초) / Avg: ${COLD_AVG}ms"
echo "   최대: ${COLD_MAX}ms ($(echo "scale=2; $COLD_MAX / 1000" | bc)초) / Max: ${COLD_MAX}ms"
echo "   최소: ${COLD_MIN}ms ($(echo "scale=2; $COLD_MIN / 1000" | bc)초) / Min: ${COLD_MIN}ms"
echo ""

echo "📊 Warm Start 통계 / Warm Start Statistics:"
echo "   평균: ${WARM_AVG}ms ($(echo "scale=2; $WARM_AVG / 1000" | bc)초) / Avg: ${WARM_AVG}ms"
echo "   최대: ${WARM_MAX}ms ($(echo "scale=2; $WARM_MAX / 1000" | bc)초) / Max: ${WARM_MAX}ms"
echo "   최소: ${WARM_MIN}ms ($(echo "scale=2; $WARM_MIN / 1000" | bc)초) / Min: ${WARM_MIN}ms"
echo ""

# 목표 달성 여부 / Check if target met
COLD_TARGET=2000
WARM_TARGET=1000

COLD_PASS="❌"
WARM_PASS="❌"

if [ $COLD_AVG -lt $COLD_TARGET ]; then
    COLD_PASS="✅"
    echo "✅ Cold Start 목표 달성! (평균 < 2초) / Cold Start target met! (avg < 2s)"
else
    echo "⚠️  Cold Start 목표 미달성 (평균 > 2초) / Cold Start target not met (avg > 2s)"
fi

if [ $WARM_AVG -lt $WARM_TARGET ]; then
    WARM_PASS="✅"
    echo "✅ Warm Start 목표 달성! (평균 < 1초) / Warm Start target met! (avg < 1s)"
else
    echo "⚠️  Warm Start 목표 미달성 (평균 > 1초) / Warm Start target not met (avg > 1s)"
fi
echo ""

# 상세 리포트 저장 / Save detailed report
REPORT_FILE="app_start_report_$(date +%Y%m%d_%H%M%S).txt"
echo "📝 상세 리포트 저장 중... / Saving detailed report..."
{
    echo "GoNow 앱 시작 속도 리포트 / App Start Speed Report"
    echo "생성 시간 / Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""
    echo "측정 설정 / Measurement Settings:"
    echo "- 패키지: $PACKAGE_NAME"
    echo "- 측정 횟수: ${ITERATIONS}회 / ${ITERATIONS} times"
    echo ""
    echo "Cold Start 통계 / Cold Start Statistics:"
    echo "- 평균: ${COLD_AVG}ms ($(echo "scale=2; $COLD_AVG / 1000" | bc)초)"
    echo "- 최대: ${COLD_MAX}ms ($(echo "scale=2; $COLD_MAX / 1000" | bc)초)"
    echo "- 최소: ${COLD_MIN}ms ($(echo "scale=2; $COLD_MIN / 1000" | bc)초)"
    echo "- 목표 달성: $COLD_PASS (< 2초)"
    echo ""
    echo "Warm Start 통계 / Warm Start Statistics:"
    echo "- 평균: ${WARM_AVG}ms ($(echo "scale=2; $WARM_AVG / 1000" | bc)초)"
    echo "- 최대: ${WARM_MAX}ms ($(echo "scale=2; $WARM_MAX / 1000" | bc)초)"
    echo "- 최소: ${WARM_MIN}ms ($(echo "scale=2; $WARM_MIN / 1000" | bc)초)"
    echo "- 목표 달성: $WARM_PASS (< 1초)"
    echo ""
    echo "상세 측정 데이터 / Detailed Measurements:"
    echo "측정 # | Cold Start (ms) | Warm Start (ms)"
    echo "--------------------------------------------"
    for i in "${!cold_start_times[@]}"; do
        printf "%6d | %15d | %15d\n" $((i+1)) "${cold_start_times[$i]}" "${warm_start_times[$i]}"
    done
    echo ""
    echo "=========================================="
} > "$REPORT_FILE"

echo "✅ 리포트 저장됨: $REPORT_FILE / Report saved: $REPORT_FILE"
echo ""

echo "=========================================="
echo "측정 완료! / Measurement Complete!"
echo "=========================================="
