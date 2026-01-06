-- Go Now: Row Level Security (RLS) Policies
-- Created: 2026-01-06
-- Description: 모든 테이블에 RLS 정책 적용 (본인 데이터만 접근 가능)

-- =============================================
-- 1. USERS 테이블 RLS
-- =============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
ON users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

COMMENT ON POLICY "Users can view own profile" ON users IS '사용자는 본인 프로필만 조회 가능';
COMMENT ON POLICY "Users can update own profile" ON users IS '사용자는 본인 프로필만 수정 가능';

-- =============================================
-- 2. SCHEDULES 테이블 RLS
-- =============================================

ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own schedules"
ON schedules FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own schedules"
ON schedules FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own schedules"
ON schedules FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own schedules"
ON schedules FOR DELETE
USING (auth.uid() = user_id);

COMMENT ON POLICY "Users can view own schedules" ON schedules IS '사용자는 본인 일정만 조회 가능';
COMMENT ON POLICY "Users can insert own schedules" ON schedules IS '사용자는 본인 일정만 추가 가능';
COMMENT ON POLICY "Users can update own schedules" ON schedules IS '사용자는 본인 일정만 수정 가능';
COMMENT ON POLICY "Users can delete own schedules" ON schedules IS '사용자는 본인 일정만 삭제 가능';

-- =============================================
-- 3. PLACES 테이블 RLS
-- =============================================

ALTER TABLE places ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own places"
ON places FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

COMMENT ON POLICY "Users can manage own places" ON places IS '사용자는 본인 장소만 CRUD 가능';

-- =============================================
-- 4. BUFFER_SETTINGS 테이블 RLS
-- =============================================

ALTER TABLE buffer_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own buffer settings"
ON buffer_settings FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

COMMENT ON POLICY "Users can manage own buffer settings" ON buffer_settings IS '사용자는 본인 버퍼 설정만 CRUD 가능';

-- =============================================
-- 5. NOTIFICATIONS 테이블 RLS
-- =============================================

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (auth.uid() = user_id);

COMMENT ON POLICY "Users can view own notifications" ON notifications IS '사용자는 본인 알림만 조회 가능';
COMMENT ON POLICY "Users can update own notifications" ON notifications IS '사용자는 본인 알림만 수정 가능 (읽음/클릭 처리)';

-- =============================================
-- 6. USAGE_STATS 테이블 RLS
-- =============================================

ALTER TABLE usage_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own usage stats"
ON usage_stats FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own usage stats"
ON usage_stats FOR INSERT
WITH CHECK (auth.uid() = user_id);

COMMENT ON POLICY "Users can view own usage stats" ON usage_stats IS '사용자는 본인 통계만 조회 가능';
COMMENT ON POLICY "Users can insert own usage stats" ON usage_stats IS '사용자는 본인 통계만 추가 가능';
