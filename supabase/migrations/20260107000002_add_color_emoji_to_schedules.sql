-- 스케줄 테이블에 UI 디자인 필드 추가 / Add UI design fields to schedules table
--
-- **변경 사항 / Changes**:
-- - color 컬럼 추가 (6가지 카테고리 색상) / Add color column (6 category colors)
-- - emoji 컬럼 추가 (일정 아이콘) / Add emoji column (schedule icon)
--
-- **기본값 / Defaults**:
-- - color: 'blue' (기본 스케줄 색상)
-- - emoji: '🚗' (기본 이동 아이콘)
--
-- **후진 호환성 / Backward Compatibility**:
-- - 기존 레코드는 자동으로 기본값 적용
-- - 앱의 이전 버전도 정상 작동 (nullable 아님, 기본값 있음)

-- Color 컬럼 추가 (6가지 스케줄 카테고리 색상)
ALTER TABLE schedules
ADD COLUMN color TEXT DEFAULT 'blue' NOT NULL;

-- Color 값 제약 조건 (6가지 허용 색상만 가능)
ALTER TABLE schedules
ADD CONSTRAINT check_schedules_color
CHECK (color IN ('red', 'blue', 'green', 'orange', 'purple', 'teal'));

-- Emoji 컬럼 추가 (일정 아이콘)
ALTER TABLE schedules
ADD COLUMN emoji TEXT DEFAULT '🚗' NOT NULL;

-- 색상 컬럼 인덱스 추가 (색상별 일정 조회 최적화)
CREATE INDEX idx_schedules_color ON schedules(color);

-- 색상별 일정 통계를 위한 복합 인덱스
CREATE INDEX idx_schedules_user_color ON schedules(user_id, color)
WHERE is_completed = FALSE AND is_cancelled = FALSE;

-- 마이그레이션 완료 확인을 위한 코멘트
COMMENT ON COLUMN schedules.color IS 'Schedule category color (red, blue, green, orange, purple, teal) for UI display';
COMMENT ON COLUMN schedules.emoji IS 'Schedule icon emoji for visual identification';
