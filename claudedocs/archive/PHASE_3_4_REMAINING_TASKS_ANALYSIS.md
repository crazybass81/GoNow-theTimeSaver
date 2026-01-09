# Phase 3, 4 미완료 작업 분석 및 구현 계획

**작성일**: 2026-01-09
**목적**: Phase 5 진입 전 Phase 3, 4의 미완료 작업 식별 및 구현 가능 항목 선별

---

## 📊 현재 상태 요약

### Phase 3: Widgets & Notifications (80% 완료)
- ✅ Android 네이티브 위젯 완료
- ✅ Flutter 레이어 완료
- ⏳ iOS 네이티브 위젯 대기 (Xcode 필요)
- ⏳ 통합 테스트 대기

### Phase 4: Integration & QA (100% 완료)
- ✅ E2E 테스트 23개 작성 및 통과
- ✅ TMAP API 통합 테스트 4개 통과
- ✅ UI 패턴 일관성 100% 달성
- ⏳ 실제 환경 테스트 (Phase 5로 이관)
- ⏳ 성능 최적화 (Phase 5로 이관)
- ⏳ Alpha 테스트 (Phase 5로 이관)

---

## 🔍 미완료 작업 상세 분석

### 1. iOS 네이티브 위젯 (Phase 3)

**상태**: ⏳ Xcode 작업 필요
**난이도**: 중상
**소요 시간**: 20-25분

**작업 내용**:
- WidgetKit Extension 생성
- App Groups 설정 (group.com.gonow.gotimesaver)
- UserDefaults 공유
- SwiftUI 위젯 UI 구현
- Timeline Provider 구현

**구현 가능 여부**: ❌ Xcode GUI 필요 (CLI로 불가)
**우선순위**: Phase 5 iOS 배포 전 필수

---

### 2. 코드 내 TODO 항목

**상태**: ⏳ 12개 TODO 발견
**난이도**: 다양 (하~중)
**소요 시간**: 항목당 10-30분

#### TODO 목록

**🔴 Priority: HIGH (Phase 5 필수)**

1. **비밀번호 변경 API 연동**
   - 파일: `lib/screens/settings/change_password_screen.dart:294`
   - 내용: Supabase 비밀번호 변경 API 호출
   - 난이도: 하
   - 구현 가능: ✅

2. **프로필 업데이트 API 연동**
   - 파일: `lib/screens/settings/edit_profile_screen.dart:191`
   - 내용: Supabase 프로필 업데이트 API 호출
   - 난이도: 하
   - 구현 가능: ✅

3. **일정 저장 API 연동**
   - 파일: `lib/screens/schedule/add_schedule_screen.dart:112`
   - 내용: Supabase에 일정 저장
   - 난이도: 중
   - 구현 가능: ✅

**🟡 Priority: MEDIUM (Phase 5 권장)**

4. **장소 검색 기능**
   - 파일: `lib/screens/schedule/add_schedule_screen.dart:238`
   - 내용: TMAP POI 검색 API 연동
   - 난이도: 중
   - 구현 가능: ✅

5. **출발 시간 실시간 계산**
   - 파일: `lib/screens/schedule/add_schedule_screen.dart:494`
   - 내용: RouteService + SchedulerService 통합
   - 난이도: 중상
   - 구현 가능: ✅

6. **비밀번호 찾기 화면**
   - 파일: `lib/screens/auth/login_screen.dart:282`
   - 내용: 비밀번호 재설정 화면 구현
   - 난이도: 중
   - 구현 가능: ✅

**🟢 Priority: LOW (Phase 6 고려)**

7. **Kakao OAuth**
   - 파일: `lib/screens/auth/signup_screen.dart:236`, `login_screen.dart:135`
   - 내용: Kakao 소셜 로그인 (SDK 설정 필요)
   - 난이도: 중상
   - 구현 가능: ⚠️ (외부 서비스 설정 필요)

8. **약관 상세 보기**
   - 파일: `lib/screens/auth/signup_screen.dart:821`, `852`
   - 내용: 이용약관/개인정보처리방침 상세 화면
   - 난이도: 하
   - 구현 가능: ✅ (이미 Legal screens 구현됨)

9. **일정 편집 화면**
   - 파일: `lib/screens/calendar/calendar_screen.dart:345`
   - 내용: schedule_edit_screen.dart 구현
   - 난이도: 중
   - 구현 가능: ✅

---

### 3. 성능 측정 도구 (Phase 4)

**상태**: ⏳ 대기
**난이도**: 중
**소요 시간**: 1-2시간

**작업 내용**:
- 배터리 소모 측정 스크립트 (Android/iOS)
- 메모리 사용량 모니터링
- 앱 시작 속도 측정
- 네트워크 요청 프로파일링

**구현 가능 여부**: ✅ Shell 스크립트 + Dart 코드
**우선순위**: Phase 5 성능 최적화 전 필수

---

### 4. 통합 테스트 추가 (Phase 3/4)

**상태**: ⏳ 일부 완료
**난이도**: 중
**소요 시간**: 2-3시간

**작업 내용**:
- 위젯 + 알림 통합 테스트
- 실제 환경 시나리오 테스트
- 네트워크 오류 시나리오
- 배터리 절약 모드 테스트

**구현 가능 여부**: ✅
**우선순위**: Phase 5 전 권장

---

### 5. E2E 테스트 실행 (Phase 4)

**상태**: ✅ 23개 테스트 작성 완료, 실행 필요
**난이도**: 하
**소요 시간**: 30분

**작업 내용**:
- `flutter test integration_test/` 실행
- 실패한 테스트 수정
- 커버리지 리포트 생성

**구현 가능 여부**: ✅
**우선순위**: Phase 5 전 필수

---

## 🎯 지금 구현 가능한 작업 목록

### Tier 1: 즉시 구현 가능 (1-2시간)

1. **E2E 테스트 실행 및 검증** (30분)
   - `flutter test integration_test/`
   - 결과 리포트 생성
   - 실패 테스트 수정

2. **약관 연결** (10분)
   - signup_screen.dart TODO 제거
   - Legal screens로 네비게이션 연결

3. **성능 측정 스크립트 작성** (1시간)
   - Android 배터리 측정: `adb shell dumpsys batterystats`
   - 메모리 측정: `adb shell dumpsys meminfo`
   - 앱 시작 속도: `adb shell am start-activity -W`

### Tier 2: API 연동 (Phase 5 백엔드 통합과 함께)

4. **비밀번호 변경 API** (20분)
   ```dart
   final response = await Supabase.instance.client.auth.updateUser(
     UserAttributes(password: newPassword)
   );
   ```

5. **프로필 업데이트 API** (20분)
   ```dart
   final response = await Supabase.instance.client
     .from('users')
     .update({'name': name, 'phone': phone})
     .eq('id', userId);
   ```

6. **일정 저장 API** (30분)
   ```dart
   final response = await Supabase.instance.client
     .from('schedules')
     .insert(trip.toJson());
   ```

### Tier 3: 신규 화면 구현 (선택적)

7. **비밀번호 찾기 화면** (40분)
   - forgot_password_screen.dart 생성
   - Supabase password reset 이메일 발송
   - 재설정 플로우 구현

8. **일정 편집 화면** (1시간)
   - schedule_edit_screen.dart 생성
   - 기존 AddScheduleScreen 재사용
   - UPDATE API 연동

9. **장소 검색 기능** (1시간)
   - TMAP POI Search API 연동
   - 검색 결과 리스트 UI
   - 최근 검색 저장

---

## 📋 권장 구현 순서

### Step 1: 검증 및 측정 도구 (Phase 5 준비)
```bash
1. E2E 테스트 실행 및 결과 확인 (30분)
2. 성능 측정 스크립트 작성 (1시간)
3. 약관 연결 TODO 제거 (10분)
```
**예상 소요**: 1시간 40분

### Step 2: 간단한 TODO 제거 (코드 품질 개선)
```bash
4. 약관 네비게이션 연결 (10분)
5. 검색어 초기화 로직 (5분)
```
**예상 소요**: 15분

### Step 3: Phase 5 백엔드 통합 작업
```bash
6. 비밀번호 변경 API (20분)
7. 프로필 업데이트 API (20분)
8. 일정 저장 API (30분)
9. 장소 검색 API (1시간)
10. 출발 시간 계산 통합 (30분)
```
**예상 소요**: 2시간 40분

### Step 4: 선택적 신규 화면 (Phase 5-6)
```bash
11. 비밀번호 찾기 화면 (40분)
12. 일정 편집 화면 (1시간)
```
**예상 소요**: 1시간 40분

---

## 🚀 추천 실행 계획

### 옵션 A: 최소한 (Phase 5 진입 전)
- Step 1 (검증 및 측정 도구): 1시간 40분
- Step 2 (간단한 TODO): 15분
- **총 소요**: 약 2시간

### 옵션 B: 권장 (Phase 5 시작)
- Step 1-3: 4시간 35분
- **총 소요**: 약 4.5시간

### 옵션 C: 완전 (Phase 5-6)
- Step 1-4 모두: 6시간 15분
- **총 소요**: 약 6시간

---

## ✅ 구현 우선순위 매트릭스

| 작업 | 중요도 | 난이도 | 소요 | Phase | 순위 |
|------|--------|--------|------|-------|------|
| E2E 테스트 실행 | 🔴 | 하 | 30분 | 4 | 1 |
| 성능 측정 스크립트 | 🔴 | 중 | 1시간 | 4 | 2 |
| 약관 연결 | 🟡 | 하 | 10분 | 4 | 3 |
| 비밀번호 변경 API | 🔴 | 하 | 20분 | 5 | 4 |
| 프로필 업데이트 API | 🔴 | 하 | 20분 | 5 | 5 |
| 일정 저장 API | 🔴 | 중 | 30분 | 5 | 6 |
| 장소 검색 API | 🟡 | 중 | 1시간 | 5 | 7 |
| 비밀번호 찾기 | 🟡 | 중 | 40분 | 5 | 8 |
| 일정 편집 화면 | 🟢 | 중 | 1시간 | 5-6 | 9 |
| iOS 위젯 | 🟡 | 중상 | 25분 | 5 | 10 |

---

## 🎯 최종 권장사항

**Phase 5 진입 전 필수 작업** (옵션 A):
1. ✅ E2E 테스트 실행 및 검증
2. ✅ 성능 측정 스크립트 작성
3. ✅ 간단한 TODO 제거

**Phase 5 백엔드 통합과 함께** (옵션 B):
4. ✅ Supabase API 연동 (비밀번호, 프로필, 일정)
5. ✅ TMAP API 추가 연동 (장소 검색)
6. ✅ 실시간 계산 통합

**Phase 5-6 추가 기능** (옵션 C):
7. ✅ 비밀번호 찾기 화면
8. ✅ 일정 편집 화면
9. ⏳ iOS 위젯 (Xcode 작업)

**다음 단계**: 옵션 A (2시간) 또는 옵션 B (4.5시간) 선택 후 구현 시작

---

**작성자**: Claude Code
**검토 필요**: Phase 5 시작 전
**다음 업데이트**: 구현 완료 후

---

**Made with 🤖 [Claude Code](https://claude.com/claude-code)**
