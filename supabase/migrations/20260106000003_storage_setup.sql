-- Go Now: Storage Buckets Setup
-- Created: 2026-01-06
-- Description: 프로필 이미지 저장용 버킷 및 RLS 정책 설정

-- =============================================
-- 1. AVATARS 버킷 생성
-- =============================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- =============================================
-- 2. AVATARS 버킷 RLS 정책
-- =============================================

-- 본인 아바타 업로드 가능
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 모든 사용자가 아바타 조회 가능 (public)
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- 본인 아바타 업데이트 가능
CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- 본인 아바타 삭제 가능
CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
