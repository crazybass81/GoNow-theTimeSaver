-- Auto-create user profile trigger
-- Created: 2026-01-07
-- Description: auth.users에 신규 사용자 생성 시 자동으로 public.users에 프로필 생성

-- **배경 / Background**:
-- auth_provider.dart에 users 테이블 프로필 생성 로직이 없어서
-- 로그인은 성공하지만 schedules 삽입 시 foreign key 에러 발생
--
-- Without this trigger, login succeeds but schedule insertion fails
-- with foreign key constraint violation (users table has no profile)

-- **해결 방법 / Solution**:
-- Database trigger를 사용해서 auth.users INSERT 시 자동으로 public.users에도 프로필 생성
-- Use database trigger to auto-create profile in public.users when user is created in auth.users

-- Function: 새 사용자 프로필 생성 / Create new user profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- auth.users의 새 사용자 정보를 public.users에 복사
  -- Copy new user information from auth.users to public.users
  INSERT INTO public.users (
    id,
    email,
    display_name,
    created_at,
    updated_at,
    last_active_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),  -- 이름이 있으면 사용, 없으면 이메일 사용
    NOW(),
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$;

-- Trigger: auth.users에 INSERT 발생 시 handle_new_user 함수 실행
-- Execute handle_new_user function when INSERT occurs in auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Comment 추가 / Add comments
COMMENT ON FUNCTION public.handle_new_user() IS 'auth.users에 신규 사용자 생성 시 자동으로 public.users에 프로필 생성 / Auto-create user profile in public.users when new user is created in auth.users';
