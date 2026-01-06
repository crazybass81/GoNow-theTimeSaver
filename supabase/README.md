# Supabase 설정 가이드

## 📋 개요

Go Now 프로젝트의 Supabase 데이터베이스 스키마 및 설정 파일입니다.

## 🚀 빠른 시작

### 1. Supabase 프로젝트 생성

1. https://supabase.com 접속
2. "New Project" 클릭
3. 프로젝트 이름: `GoNow-Production`
4. Database Password 설정 (안전한 곳에 저장)
5. Region: `Northeast Asia (Seoul)` 선택
6. 생성 완료 (약 2분 소요)

### 2. 데이터베이스 마이그레이션 실행

Supabase Dashboard → SQL Editor → New Query에서 다음 순서대로 실행:

#### Step 1: 테이블 생성
```sql
-- migrations/20260106000001_initial_schema.sql 내용 복사 & 실행
```

#### Step 2: RLS 정책 활성화
```sql
-- migrations/20260106000002_enable_rls.sql 내용 복사 & 실행
```

#### Step 3: Storage 버킷 설정
```sql
-- migrations/20260106000003_storage_setup.sql 내용 복사 & 실행
```

### 3. API 키 및 URL 확인

Supabase Dashboard → Settings → API

- **Project URL**: `https://xxxxx.supabase.co`
- **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- **service_role key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (서버용)

### 4. 환경 변수 설정

프로젝트 루트에 `.env` 파일 생성:

```bash
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Naver API
NAVER_MAPS_CLIENT_ID=your_client_id
NAVER_MAPS_CLIENT_SECRET=your_client_secret

# Seoul Open API
SEOUL_BUS_API_KEY=your_api_key
```

⚠️ **중요**: `.env` 파일은 `.gitignore`에 포함되어 있으므로 Git에 커밋되지 않습니다.

## 📊 데이터베이스 구조

### 테이블 목록

| 테이블 | 설명 | 관계 |
|--------|------|------|
| `users` | 사용자 프로필 | auth.users와 1:1 |
| `schedules` | 일정 정보 | users와 1:N |
| `places` | 자주 가는 장소 | users와 1:N |
| `buffer_settings` | 버퍼 시간 프리셋 | users와 1:N |
| `notifications` | 알림 이력 | users, schedules와 연결 |
| `usage_stats` | 사용 통계 (AI 학습용) | users, schedules와 연결 |

### ER Diagram

```
┌─────────────┐      ┌──────────────┐      ┌─────────────────┐
│ auth.users  │──1:1─│    users     │──1:N─│   schedules     │
│ (Supabase)  │      │ (프로필)     │      │   (일정)        │
└─────────────┘      └──────────────┘      └─────────────────┘
                            │                       │
                           1:N                     N:1
                            │                       │
                     ┌──────────────┐      ┌──────────────┐
                     │buffer_settings│      │    places    │
                     │ (버퍼 설정)   │      │  (자주 가는  │
                     └──────────────┘      │    장소)     │
                                            └──────────────┘
                     ┌──────────────┐
                     │notifications │
                     │ (알림 이력)  │
                     └──────────────┘
```

## 🔒 보안 기능

### Row Level Security (RLS)

모든 테이블에 RLS가 활성화되어 있으며, 사용자는 **본인의 데이터만** 접근 가능합니다.

### Storage 보안

- **avatars** 버킷: 프로필 이미지 저장
  - 조회: 모든 사용자 가능 (public)
  - 업로드/수정/삭제: 본인만 가능

## ✅ 테스트 방법

### 1. Supabase Studio에서 테스트

Dashboard → Table Editor에서:

1. `users` 테이블에 테스트 데이터 삽입
2. `schedules` 테이블에 일정 추가
3. RLS 정책이 올바르게 작동하는지 확인

### 2. SQL 쿼리 테스트

```sql
-- 테이블 생성 확인
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- RLS 정책 확인
SELECT tablename, policyname
FROM pg_policies
WHERE schemaname = 'public';

-- 인덱스 확인
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public';
```

## 📝 Migration 파일 설명

| 파일 | 설명 | 실행 순서 |
|------|------|----------|
| `20260106000001_initial_schema.sql` | 6개 테이블 + 인덱스 + 트리거 생성 | 1번 |
| `20260106000002_enable_rls.sql` | 모든 테이블 RLS 정책 설정 | 2번 |
| `20260106000003_storage_setup.sql` | Storage 버킷 및 정책 설정 | 3번 |

## 🛠️ 문제 해결

### "relation does not exist" 오류
→ Migration을 순서대로 실행했는지 확인

### RLS 정책 오류
→ `auth.uid()`가 올바른 사용자 ID를 반환하는지 확인

### Storage 업로드 실패
→ 파일 경로가 `{user_id}/filename.ext` 형식인지 확인

## 📚 참고 문서

- [Supabase 공식 문서](https://supabase.com/docs)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [Row Level Security 가이드](https://supabase.com/docs/guides/auth/row-level-security)
