#!/bin/bash

# GoNow 메모리 사용량 측정 스크립트 / Memory Usage Measurement Script
# Usage: ./measure_memory.sh [duration_minutes]

PACKAGE_NAME="com.gonow.gotimesaver"
DURATION_MINUTES=${1:-30}  # 기본 30분 / Default 30 minutes
DURATION_SECONDS=$((DURATION_MINUTES * 60))

echo "=========================================="
echo "GoNow 메모리 사용량 측정 / Memory Measurement"
echo "=========================================="
echo "패키지: $PACKAGE_NAME"
echo "측정 시간: ${DURATION_MINUTES}분 / ${DURATION_MINUTES} minutes"
echo ""

# 1. 디바이스 연결 확인 / Check device connection
echo "[1/4] 디바이스 연결 확인 / Checking device..."
DEVICE=$(adb devices | grep "device$" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo "❌ 디바이스가 연결되지 않았습니다 / No device connected"
    exit 1
fi
echo "✅ 디바이스 연결됨: $DEVICE / Device connected: $DEVICE"
echo ""

# 2. 앱 실행 확인 / Check app running
echo "[2/4] 앱 실행 확인 / Checking if app is running..."
PID=$(adb shell "ps | grep $PACKAGE_NAME" | awk '{print $2}')
if [ -z "$PID" ]; then
    echo "⚠️  앱이 실행되지 않음. 시작합니다 / App not running. Starting..."
    adb shell am start -n $PACKAGE_NAME/.MainActivity
    sleep 5
    PID=$(adb shell "ps | grep $PACKAGE_NAME" | awk '{print $2}')
fi
echo "✅ 앱 실행 중 (PID: $PID) / App is running (PID: $PID)"
echo ""

# 3. 초기 메모리 측정 / Get initial memory
echo "[3/4] 초기 메모리 사용량 측정 / Getting initial memory usage..."
INITIAL_MEMINFO=$(adb shell dumpsys meminfo $PACKAGE_NAME | grep "TOTAL")
INITIAL_TOTAL=$(echo "$INITIAL_MEMINFO" | awk '{print $2}')
INITIAL_TOTAL_MB=$(echo "scale=2; $INITIAL_TOTAL / 1024" | bc)

echo "✅ 초기 메모리: ${INITIAL_TOTAL}KB (${INITIAL_TOTAL_MB}MB)"
echo "   시작 시간: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 4. 주기적 측정 / Periodic measurement
echo "[4/4] 메모리 사용량 모니터링 중... / Monitoring memory usage..."
echo "⏳ ${DURATION_MINUTES}분 동안 매 1분마다 측정 / Measuring every 1 minute for ${DURATION_MINUTES} minutes"
echo ""

# 결과 저장 배열 / Arrays to store results
declare -a timestamps
declare -a memory_values
declare -a memory_mb_values

INTERVAL=60  # 1분 / 1 minute
ELAPSED=0
MEASUREMENT_COUNT=0

echo "시간(분) | 메모리(MB) | 변화량(MB) | 상태"
echo "--------------------------------------------"

while [ $ELAPSED -lt $DURATION_SECONDS ]; do
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
    MINUTES_ELAPSED=$((ELAPSED / 60))

    # 현재 메모리 측정 / Measure current memory
    PID=$(adb shell "ps | grep $PACKAGE_NAME" | awk '{print $2}')
    if [ -z "$PID" ]; then
        echo "⚠️  앱이 종료됨 / App terminated"
        break
    fi

    MEMINFO=$(adb shell dumpsys meminfo $PACKAGE_NAME | grep "TOTAL")
    CURRENT_TOTAL=$(echo "$MEMINFO" | awk '{print $2}')
    CURRENT_TOTAL_MB=$(echo "scale=2; $CURRENT_TOTAL / 1024" | bc)

    # 변화량 계산 / Calculate delta
    DELTA=$(echo "$CURRENT_TOTAL - $INITIAL_TOTAL" | bc)
    DELTA_MB=$(echo "scale=2; $DELTA / 1024" | bc)

    # 상태 판단 / Determine status
    if (( $(echo "$CURRENT_TOTAL_MB < 50" | bc -l) )); then
        STATUS="✅ 정상"
    elif (( $(echo "$CURRENT_TOTAL_MB < 70" | bc -l) )); then
        STATUS="⚠️  주의"
    else
        STATUS="❌ 높음"
    fi

    # 출력 / Print
    printf "%7d | %10s | %10s | %s\n" \
        "$MINUTES_ELAPSED" \
        "$CURRENT_TOTAL_MB" \
        "$DELTA_MB" \
        "$STATUS"

    # 배열에 저장 / Store in arrays
    timestamps[$MEASUREMENT_COUNT]=$MINUTES_ELAPSED
    memory_values[$MEASUREMENT_COUNT]=$CURRENT_TOTAL
    memory_mb_values[$MEASUREMENT_COUNT]=$CURRENT_TOTAL_MB
    MEASUREMENT_COUNT=$((MEASUREMENT_COUNT + 1))
done

echo ""
echo "=========================================="
echo "측정 완료 / Measurement Complete"
echo "=========================================="

# 통계 계산 / Calculate statistics
FINAL_TOTAL=${memory_values[$((MEASUREMENT_COUNT - 1))]}
FINAL_TOTAL_MB=${memory_mb_values[$((MEASUREMENT_COUNT - 1))]}

# 평균 계산 / Calculate average
SUM=0
for val in "${memory_values[@]}"; do
    SUM=$((SUM + val))
done
AVG=$((SUM / MEASUREMENT_COUNT))
AVG_MB=$(echo "scale=2; $AVG / 1024" | bc)

# 최대/최소 / Max/Min
MAX=${memory_values[0]}
MIN=${memory_values[0]}
for val in "${memory_values[@]}"; do
    if [ $val -gt $MAX ]; then MAX=$val; fi
    if [ $val -lt $MIN ]; then MIN=$val; fi
done
MAX_MB=$(echo "scale=2; $MAX / 1024" | bc)
MIN_MB=$(echo "scale=2; $MIN / 1024" | bc)

echo "📊 통계 / Statistics:"
echo "   초기: ${INITIAL_TOTAL_MB}MB / Initial: ${INITIAL_TOTAL_MB}MB"
echo "   최종: ${FINAL_TOTAL_MB}MB / Final: ${FINAL_TOTAL_MB}MB"
echo "   평균: ${AVG_MB}MB / Average: ${AVG_MB}MB"
echo "   최대: ${MAX_MB}MB / Max: ${MAX_MB}MB"
echo "   최소: ${MIN_MB}MB / Min: ${MIN_MB}MB"
echo ""

# 목표 달성 여부 / Check if target met
TARGET_MB=50
if (( $(echo "$AVG_MB < $TARGET_MB" | bc -l) )); then
    echo "✅ 목표 달성! (평균 < ${TARGET_MB}MB) / Target met! (avg < ${TARGET_MB}MB)"
else
    echo "⚠️  목표 미달성 (평균 > ${TARGET_MB}MB) / Target not met (avg > ${TARGET_MB}MB)"
fi
echo ""

# 상세 리포트 저장 / Save detailed report
REPORT_FILE="memory_report_$(date +%Y%m%d_%H%M%S).txt"
echo "📝 상세 리포트 저장 중... / Saving detailed report..."
{
    echo "GoNow 메모리 사용량 리포트 / Memory Usage Report"
    echo "생성 시간 / Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""
    echo "측정 설정 / Measurement Settings:"
    echo "- 패키지: $PACKAGE_NAME"
    echo "- 측정 시간: ${DURATION_MINUTES}분 / ${DURATION_MINUTES} minutes"
    echo "- 측정 간격: 1분 / 1 minute"
    echo "- 측정 횟수: ${MEASUREMENT_COUNT}회 / ${MEASUREMENT_COUNT} times"
    echo ""
    echo "통계 / Statistics:"
    echo "- 초기: ${INITIAL_TOTAL_MB}MB"
    echo "- 최종: ${FINAL_TOTAL_MB}MB"
    echo "- 평균: ${AVG_MB}MB"
    echo "- 최대: ${MAX_MB}MB"
    echo "- 최소: ${MIN_MB}MB"
    echo ""
    echo "상세 측정 데이터 / Detailed Measurements:"
    echo "시간(분) | 메모리(MB)"
    echo "--------------------"
    for i in "${!timestamps[@]}"; do
        printf "%7d | %10s\n" "${timestamps[$i]}" "${memory_mb_values[$i]}"
    done
    echo ""
    echo "=========================================="
    echo "상세 메모리 정보 / Detailed Memory Info:"
    echo "=========================================="
    adb shell dumpsys meminfo $PACKAGE_NAME
} > "$REPORT_FILE"

echo "✅ 리포트 저장됨: $REPORT_FILE / Report saved: $REPORT_FILE"
echo ""

echo "=========================================="
echo "측정 완료! / Measurement Complete!"
echo "=========================================="
