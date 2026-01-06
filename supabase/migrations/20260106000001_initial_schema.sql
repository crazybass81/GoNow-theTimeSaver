-- Go Now: Initial Database Schema
-- Created: 2026-01-06
-- Description: 사용자, 일정, 장소, 버퍼 설정, 알림, 사용 통계 테이블 생성

-- =============================================
-- 1. USERS 테이블 (사용자 프로필)
-- =============================================

CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  avatar_url TEXT,

  -- 구독 정보
  subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
  subscription_expires_at TIMESTAMPTZ,

  -- 앱 설정
  preferred_transport TEXT DEFAULT 'transit' CHECK (preferred_transport IN ('car', 'transit', 'auto')),
  default_home_location JSONB, -- {lat: number, lng: number, address: string}

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_subscription ON users(subscription_tier, subscription_expires_at);

COMMENT ON TABLE users IS '사용자 프로필 정보 (auth.users와 1:1 관계)';
COMMENT ON COLUMN users.subscription_tier IS '구독 등급: free, premium';
COMMENT ON COLUMN users.preferred_transport IS '선호 교통수단: car, transit, auto';
COMMENT ON COLUMN users.default_home_location IS '기본 집 위치 (JSON: {lat, lng, address})';

-- =============================================
-- 2. SCHEDULES 테이블 (일정)
-- =============================================

CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- 일정 기본 정보
  title TEXT NOT NULL,
  destination_address TEXT NOT NULL,
  destination_lat DOUBLE PRECISION NOT NULL,
  destination_lng DOUBLE PRECISION NOT NULL,

  -- 시간 정보
  arrival_time TIMESTAMPTZ NOT NULL, -- 도착 목표 시간
  departure_time TIMESTAMPTZ NOT NULL, -- 역산된 출발 시간

  -- 경로 정보
  transport_mode TEXT NOT NULL CHECK (transport_mode IN ('car', 'transit')),
  route_data JSONB, -- Naver API 응답 저장 {duration, distance, path, transitInfo 등}
  travel_duration_minutes INTEGER NOT NULL, -- 이동 소요 시간

  -- 버퍼 시간 (분 단위) - 4가지 독립 버퍼
  preparation_minutes INTEGER DEFAULT 15, -- 외출 준비 시간
  early_arrival_buffer_minutes INTEGER DEFAULT 10, -- 일찍 도착 버퍼
  travel_uncertainty_rate DOUBLE PRECISION DEFAULT 0.2, -- 이동 오차율 (20%)
  previous_task_wrapup_minutes INTEGER DEFAULT 5, -- 일정 마무리 시간

  -- 상태 관리
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  is_cancelled BOOLEAN DEFAULT FALSE,

  -- 알림 설정
  notification_enabled BOOLEAN DEFAULT TRUE,
  notification_sent_at TIMESTAMPTZ,

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_schedules_user_id ON schedules(user_id);
CREATE INDEX idx_schedules_arrival_time ON schedules(arrival_time);
CREATE INDEX idx_schedules_user_arrival ON schedules(user_id, arrival_time)
  WHERE is_completed = FALSE AND is_cancelled = FALSE;
CREATE INDEX idx_schedules_notification ON schedules(notification_enabled, notification_sent_at)
  WHERE is_completed = FALSE;

COMMENT ON TABLE schedules IS '사용자의 일정 정보';
COMMENT ON COLUMN schedules.preparation_minutes IS '1. 외출 준비 시간 (5~60분)';
COMMENT ON COLUMN schedules.early_arrival_buffer_minutes IS '2. 일찍 도착 버퍼 (0~30분)';
COMMENT ON COLUMN schedules.travel_uncertainty_rate IS '3. 이동 오차율 (0~50%)';
COMMENT ON COLUMN schedules.previous_task_wrapup_minutes IS '4. 일정 마무리 시간 (0~20분)';

-- =============================================
-- 3. PLACES 테이블 (자주 가는 장소)
-- =============================================

CREATE TABLE places (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- 장소 정보
  name TEXT NOT NULL, -- "회사", "집", "헬스장" 등
  address TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,

  -- 카테고리
  category TEXT CHECK (category IN ('home', 'work', 'gym', 'cafe', 'hospital', 'etc')),

  -- 사용 통계
  visit_count INTEGER DEFAULT 0,
  last_visited_at TIMESTAMPTZ,

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_places_user_id ON places(user_id);
CREATE INDEX idx_places_category ON places(category);
CREATE UNIQUE INDEX idx_places_user_name ON places(user_id, name); -- 같은 이름 중복 방지

COMMENT ON TABLE places IS '사용자의 즐겨찾기 장소';
COMMENT ON COLUMN places.category IS '장소 카테고리: home, work, gym, cafe, hospital, etc';

-- =============================================
-- 4. BUFFER_SETTINGS 테이블 (버퍼 설정 프리셋)
-- =============================================

CREATE TABLE buffer_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- 프리셋 정보
  preset_name TEXT NOT NULL, -- "평일 출근", "주말 여유", "긴급" 등
  is_default BOOLEAN DEFAULT FALSE,

  -- 4가지 버퍼 시간 (분 단위)
  preparation_minutes INTEGER DEFAULT 15 CHECK (preparation_minutes BETWEEN 5 AND 60),
  early_arrival_buffer_minutes INTEGER DEFAULT 10 CHECK (early_arrival_buffer_minutes BETWEEN 0 AND 30),
  travel_uncertainty_rate DOUBLE PRECISION DEFAULT 0.2 CHECK (travel_uncertainty_rate BETWEEN 0 AND 0.5),
  previous_task_wrapup_minutes INTEGER DEFAULT 5 CHECK (previous_task_wrapup_minutes BETWEEN 0 AND 20),

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_buffer_settings_user_id ON buffer_settings(user_id);
CREATE UNIQUE INDEX idx_buffer_settings_user_name ON buffer_settings(user_id, preset_name);
CREATE INDEX idx_buffer_settings_default ON buffer_settings(user_id, is_default) WHERE is_default = TRUE;

-- 사용자당 기본 프리셋 1개만 허용
CREATE UNIQUE INDEX idx_buffer_settings_single_default ON buffer_settings(user_id) WHERE is_default = TRUE;

COMMENT ON TABLE buffer_settings IS '사용자의 버퍼 시간 프리셋 (평일 출근, 주말 여유 등)';

-- =============================================
-- 5. NOTIFICATIONS 테이블 (알림 이력)
-- =============================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  schedule_id UUID REFERENCES schedules(id) ON DELETE SET NULL,

  -- 알림 정보
  notification_type TEXT NOT NULL CHECK (notification_type IN ('departure_reminder', 'traffic_alert', 'early_warning')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,

  -- 발송 정보
  scheduled_at TIMESTAMPTZ NOT NULL, -- 발송 예정 시간
  sent_at TIMESTAMPTZ, -- 실제 발송 시간
  is_sent BOOLEAN DEFAULT FALSE,

  -- 사용자 반응
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  is_clicked BOOLEAN DEFAULT FALSE,
  clicked_at TIMESTAMPTZ,

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_schedule_id ON notifications(schedule_id);
CREATE INDEX idx_notifications_sent ON notifications(is_sent, scheduled_at);
CREATE INDEX idx_notifications_pending ON notifications(is_sent, scheduled_at) WHERE is_sent = FALSE;

COMMENT ON TABLE notifications IS '발송된 알림 로그';
COMMENT ON COLUMN notifications.notification_type IS '알림 종류: departure_reminder, traffic_alert, early_warning';

-- =============================================
-- 6. USAGE_STATS 테이블 (사용 통계 - AI 학습용)
-- =============================================

CREATE TABLE usage_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  schedule_id UUID REFERENCES schedules(id) ON DELETE SET NULL,

  -- 실제 이동 데이터
  actual_departure_time TIMESTAMPTZ,
  actual_arrival_time TIMESTAMPTZ,
  actual_travel_duration_minutes INTEGER,

  -- 예측 vs 실제 비교
  predicted_duration_minutes INTEGER,
  duration_diff_minutes INTEGER, -- 실제 - 예측

  -- 버퍼 사용률
  buffer_used_minutes INTEGER, -- 실제로 사용한 버퍼 시간
  was_late BOOLEAN DEFAULT FALSE,
  late_by_minutes INTEGER,

  -- 환경 요인
  weather_condition TEXT, -- Phase 3에서 추가
  traffic_level TEXT CHECK (traffic_level IN ('smooth', 'slow', 'congested')),
  day_of_week INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
  time_of_day TEXT CHECK (time_of_day IN ('morning', 'afternoon', 'evening', 'night')),

  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_usage_stats_user_id ON usage_stats(user_id);
CREATE INDEX idx_usage_stats_schedule_id ON usage_stats(schedule_id);
CREATE INDEX idx_usage_stats_late ON usage_stats(was_late, created_at);
CREATE INDEX idx_usage_stats_analysis ON usage_stats(user_id, day_of_week, time_of_day);

COMMENT ON TABLE usage_stats IS 'Phase 2/3 AI 개인화에 사용할 사용 통계 데이터';

-- =============================================
-- 7. TRIGGERS (자동 updated_at 업데이트)
-- =============================================

-- updated_at 자동 업데이트 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- users 테이블 트리거
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- schedules 테이블 트리거
CREATE TRIGGER update_schedules_updated_at
BEFORE UPDATE ON schedules
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- places 테이블 트리거
CREATE TRIGGER update_places_updated_at
BEFORE UPDATE ON places
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- buffer_settings 테이블 트리거
CREATE TRIGGER update_buffer_settings_updated_at
BEFORE UPDATE ON buffer_settings
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
