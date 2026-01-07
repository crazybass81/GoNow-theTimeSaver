-- Add User Settings Columns to users table
-- Created: 2026-01-07
-- Description: 기본 버퍼 시간 설정 및 알림 설정 컬럼 추가

-- =============================================
-- 1. 기본 버퍼 시간 설정 컬럼 추가
-- =============================================

-- 4가지 기본 버퍼 시간
ALTER TABLE users ADD COLUMN IF NOT EXISTS default_preparation_minutes INTEGER DEFAULT 15
  CHECK (default_preparation_minutes BETWEEN 5 AND 60);

ALTER TABLE users ADD COLUMN IF NOT EXISTS default_early_arrival_buffer_minutes INTEGER DEFAULT 10
  CHECK (default_early_arrival_buffer_minutes BETWEEN 0 AND 30);

ALTER TABLE users ADD COLUMN IF NOT EXISTS default_travel_uncertainty_rate DOUBLE PRECISION DEFAULT 0.2
  CHECK (default_travel_uncertainty_rate BETWEEN 0 AND 0.5);

ALTER TABLE users ADD COLUMN IF NOT EXISTS default_previous_task_wrapup_minutes INTEGER DEFAULT 5
  CHECK (default_previous_task_wrapup_minutes BETWEEN 0 AND 20);

-- =============================================
-- 2. 알림 설정 컬럼 추가
-- =============================================

ALTER TABLE users ADD COLUMN IF NOT EXISTS notification_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS sound_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS vibration_enabled BOOLEAN DEFAULT TRUE;

-- =============================================
-- 3. 컬럼 코멘트 추가
-- =============================================

COMMENT ON COLUMN users.default_preparation_minutes IS '기본 외출 준비 시간 (5-60분)';
COMMENT ON COLUMN users.default_early_arrival_buffer_minutes IS '기본 일찍 도착 버퍼 (0-30분)';
COMMENT ON COLUMN users.default_travel_uncertainty_rate IS '기본 이동 오차율 (0-50%)';
COMMENT ON COLUMN users.default_previous_task_wrapup_minutes IS '기본 일정 마무리 시간 (0-20분)';
COMMENT ON COLUMN users.notification_enabled IS '알림 활성화 여부';
COMMENT ON COLUMN users.sound_enabled IS '알림 소리 활성화 여부';
COMMENT ON COLUMN users.vibration_enabled IS '알림 진동 활성화 여부';
