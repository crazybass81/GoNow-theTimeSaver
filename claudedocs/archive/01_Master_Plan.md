# Go Now: The Time Saver - 전략적 마스터 플랜

**문서 버전**: 2.0
**작성일**: 2026-01-06
**최종 업데이트**: 2026-01-06 (의사결정 반영)
**프로젝트 타입**: ADHD 특화 시간 관리 앱 (Flutter 기반)
**MVP 목표일**: 2026년 1월 31일 (25일)

---

## 📋 Executive Summary / 요약

**핵심 가치 제안 / Core Value Proposition** (Updated):
- 기존 캘린더 앱의 근본적 한계 해결: "계획하기"와 "실행하기" 사이의 간극
- ADHD 성향 사용자를 위한 **인지적 보철(Cognitive Prosthetics)** 제공
- **최종 방향**: 역산 스케줄링 + 실시간 교통 데이터 + 시각적 알람 + 대중교통 + 홈 위젯
- **패널티 시스템 폐기**: 긍정적 사용자 경험과 법적 리스크 회피 우선

**타깃 시장** (Updated):
- **주 타깃**: 20~40대 직장인, 프리랜서 (생산성 앱 포지셔닝)
- **부 타깃**: ADHD 성향 사용자 (자연스럽게 유입)

**시장 기회**:
- 신경다양성(Neurodivergent) 생산성 앱 시장 성장
- 기존 솔루션(Tiimo, Forfeit, Waze)의 기능적 공백 존재
- **한국 시장 선점**: 네이버 Maps API 활용 (Google Maps 제약)

**의사결정 사항**:
- ✅ **포지셔닝**: 생산성 앱 (의료 기기 아님)
- ✅ **메시지**: "절대 안 늦는 습관 만들기"
- ✅ **MVP 팀**: 바이브코딩 개발자 2명
- ✅ **일정**: 2026년 1월 31일까지 (25일)

---

## 🎯 1. 시장 분석 / Market Analysis

### 1.1 타깃 사용자의 문제 정의

**시간맹(Time Blindness)이란?**
- 시간의 흐름을 감각적으로 인지하지 못하는 증상
- ADHD의 주요 증상 중 하나
- "오후 2시 회의"라는 추상적 정보 → 구체적 실행 단계로 변환 불가

**기존 캘린더 앱의 3대 실패 요인**:
1. **준비 시간 누락**: 이동 시간만 표시, 외출 준비 시간 미고려
2. **정적인 알림**: 교통 상황 변화 반영 불가
3. **강제성 부재**: 알림 무시 시 즉각적 불이익 없음 → ADHD 뇌 무반응

### 1.2 경쟁사 분석

| 경쟁 앱 | 핵심 가치 | ADHD 적합성 | 결정적 한계 |
|---------|-----------|-------------|-------------|
| **Tiimo** | 시각적 타임라인 + 루틴 관리 | ⭐⭐⭐⭐ | 실시간 교통 반영 없음 |
| **Owaves** | 24시간 원형 시계 기반 일과 | ⭐⭐⭐ | 계획 도구일 뿐, 실행 유도 약함 |
| **Forfeit** | 사진 인증 실패 시 금전 차감 | ⭐⭐⭐⭐⭐ | 지각 방지/이동 경로에 특화 안 됨 |
| **Lifestack** | 웨어러블 에너지 관리 | ⭐⭐ | 이동 로지스틱스 기능 부재 |
| **네이버/카카오맵** | 길 찾기 + 소요시간 | ⭐ | 준비 시간 포함 역산 불가 |

**🎯 시장 공백 (Market Gap)**:
> "Tiimo의 시각화 + Waze의 실시간성 + Forfeit의 강제성"을 결합한 통합 솔루션 부재

### 1.3 한국 시장 특수성

**Google Maps의 한계**:
- 지도 데이터 국외 반출 규제로 인한 기능 제한
- 도보 길찾기, 실시간 턴바이턴 내비게이션 불가
- 대중교통 정보 부정확

**필수 로컬 API**:
- **네이버 클라우드 플랫폼 (NCP)**: Driving API, 실시간 교통
- **카카오 모빌리티**: 소셜 연동(카톡 알림톡, 위치 공유)

**전략적 기회**:
- 카카오톡 API 활용 → "지각 위기 시 친구에게 자동 알림" 소셜 프레셔
- 네이버/카카오 택시 호출 딥링크 연동 → 긴급 상황 대응

---

## 🧠 2. 행동 경제학적 설계 / Behavioral Design

### 2.1 계획 오류(Planning Fallacy) 극복

**문제**: 사람들은 미래 과제 소요 시간을 과소평가 (ADHD는 더 심함)

**해결책: 역산 스케줄링 (Backward Planning)**
```
[사용자 입력] "오후 2시 회의 장소 도착"
         ↓
[시스템 자동 계산]
- 이동 시간: 25분 (실시간 교통 반영)
- 주차 시간: 5분
- 외출 준비: 15분 (사용자 설정)
- 여유 시간: 5분 (버퍼)
         ↓
[최종 출력] "🚨 1시 10분까지 집을 나가야 합니다"
```

**인지적 보철(Cognitive Prosthetics)**:
- 전두엽 기능 대체: 복잡한 시간 계산을 시스템이 대신 수행
- 결과만 제시: 사용자는 카운트다운만 보면 됨 → 인지 부하 최소화

### 2.2 긍정적 강화 (Positive Reinforcement) ⭐ 최종 방향

**패널티 방식 폐기 이유**:
- 법적 리스크: 사행성 규제, 앱스토어 IAP 정책
- 사용자 반발: 억울한 실패 시 불만 폭증
- 핵심 가치 훼손: 시간 관리 보조 → 금전적 압박

**대안: 게임화(Gamification) - 긍정적 강화만 사용**:
- ✅ **연속 성공(Streak)**: 30일 연속 정시 출발 → 배지, 칭호 획득
- ✅ **아바타 성장**: 성공 횟수에 따라 가상 캐릭터/집 성장
- ✅ **시각적 만족감**: ADHD 사용자에게 효과적인 즉각적 피드백
- ✅ **소셜 공유**: 성공 기록 SNS 공유 (선택적)
- ✅ **주간 리포트**: 성공률, 절약한 시간 통계 제공

**심리적 메커니즘**:
- 즉각적 긍정 피드백 → 도파민 분비 → 습관 강화
- 손실 회피 대신 성취감과 자부심 활용
- 장기적 습관 형성에 더 효과적

---

## 💼 3. 비즈니스 모델 / Business Model ⭐ 패널티 폐기

### 3.1 수익 구조 (최종 방향)

**Primary Revenue: 프리미엄 구독 (Freemium 모델)**
- **무료 플랜**:
  - 일 3개 일정 제한
  - 기본 알림
  - 광고 표시 (비침해적)

- **프리미엄 플랜** (월 4,900원 / 연 49,000원):
  - ✅ 무제한 일정 관리
  - ✅ 광고 제거
  - ✅ 고급 통계 및 패턴 분석
  - ✅ AI 기반 준비 시간 추천
  - ✅ 우선 고객 지원
  - ✅ 데이터 백업 및 동기화

**Secondary Revenue**:
- **제휴 수수료**: 카카오 택시/T맵 호출 딥링크 커미션
- **B2B 라이선스**: 기업 출퇴근 관리 솔루션
- **데이터 인사이트**: 익명화된 교통 패턴 데이터 판매 (선택적)

**수익 예측** (Phase 2 기준):
- MAU 10,000명 기준
- 유료 전환율 10% = 1,000명
- 월 구독 수익: 4,900원 × 1,000명 = 4,900,000원/월
- 연간: 58,800,000원

### 3.2 앱스토어 정책 준수 ✅

**Apple/Google 정책 완전 준수**:
- ✅ In-App Purchase (IAP) 사용
- ✅ 앱스토어 30% 수수료 수용
- ✅ 외부 PG 사용 없음 → 심사 리스크 제로
- ✅ 사행성 규제 해당 없음
- ✅ 소비자 보호법 이슈 없음

**폐기된 외부 PG 방식**:
- ❌ Stripe/토스페이먼츠 연동 (앱스토어 정책 위반)
- ❌ 페널티 결제 시스템 (법적 리스크)
- ❌ 외부 웹사이트 결제 우회 (Apple 정책 위반)

---

## 🗺️ 4. 전략적 로드맵 / Strategic Roadmap

### Phase 1: MVP - "Time Blindness Prosthetic" (25일)

**목표**: 핵심 가치 검증 + 빠른 시장 출시

**기능**:
- ✅ Flutter 기반 UI
- ✅ 네이버 지도 API 연동 (소요 시간 산출)
- ✅ 역산 스케줄링 알고리즘
- ✅ 로컬 푸시 알림 (서버 불필요)
- ✅ 준비 시간 사용자 설정
- ⭐ 대중교통 지원 (버스/지하철 실시간 정보)
- ⭐ 홈 위젯 (Android/iOS)

**기술 스택**:
- Flutter 3.x
- Naver Cloud Platform Maps API
- Naver Transit API
- flutter_local_notifications
- Android: Jetpack Glance Widget
- iOS: WidgetKit

**성공 지표** (Updated):
- MAU 500명
- 앱스토어 평점 4.5+ (최소 50개 리뷰)
- D7 리텐션 40%+
- 정시 출발 성공률 75%+

**출시 목표**: 2026년 1월 31일

---

### Phase 2: "The Stick" - 페널티 시스템 (3개월)

**목표**: 수익 모델 도입 및 행동 교정 강화

**추가 기능**:
- ✅ 지오펜싱 (flutter_background_geolocation)
- ✅ Stripe 결제 연동 (서약금 시스템)
- ✅ 페널티 판정 서버 구축
- ✅ 억울한 실패 방지: Grace Period (5분 유예)
- ✅ 환불/소명 프로세스

**기술 스택**:
- Backend: Node.js (Express) 또는 Django
- Payment: Stripe API
- DB: PostgreSQL (사용자/거래 이력)

**법적 검증**:
- 앱스토어 심사 통과 확인
- 소비자 보호법 준수 (환불 규정 명시)

---

### Phase 3: "Deep Integration" - 플랫폼 확장 (6개월)

**목표**: iOS/Android 네이티브 최적화 및 소셜 기능

**추가 기능**:
- ✅ iOS Live Activities (Dynamic Island)
  - 실시간 교통 변화 반영
- ✅ 카카오톡 알림톡 API 연동
  - 지각 위기 시 친구에게 자동 알림 (소셜 프레셔)
- ✅ 웨어러블 확장 (Apple Watch, Galaxy Watch)
- ✅ AI 기반 준비 시간 추천
- ✅ 고급 통계 및 패턴 분석

**기술 스택**:
- iOS: SwiftUI (ActivityKit)
- Kakao Developers API (알림톡)
- Machine Learning: TensorFlow Lite

**성장 목표**:
- MAU 10,000명
- 유료 전환율 15%
- 페널티 발생률 30% (건강한 긴장감 유지)

---

## 📊 5. 성공 지표 / Success Metrics

### 5.1 핵심 지표 (North Star Metrics)

| 지표 | Phase 1 목표 | Phase 2 목표 | Phase 3 목표 |
|------|--------------|--------------|--------------|
| **정시 출발 성공률** | 75% | 80% | 85% |
| **MAU** | 500 | 1,000 | 10,000 |
| **유료 전환율** | - | 10% | 15% |
| **앱 삭제율** | <30% | <20% | <15% |
| **페널티 수익** | - | $500/월 | $5,000/월 |
| **앱스토어 평점** | 4.5+ | 4.6+ | 4.7+ |
| **D7 리텐션** | 40%+ | 45%+ | 50%+ |

### 5.2 사용자 만족도

- **NPS (Net Promoter Score)**: 목표 40+ (Phase 3)
- **사용자 리텐션**:
  - D1: 60%
  - D7: 40%
  - D30: 25%

---

## ⚠️ 6. 리스크 및 대응 전략 / Risk Management

### 6.1 기술적 리스크

| 리스크 | 발생 확률 | 영향도 | 대응 전략 |
|--------|-----------|--------|-----------|
| GPS 오차로 인한 억울한 페널티 | 높음 | 치명적 | Grace Period 5분 + 소명 프로세스 |
| 배터리 과다 소모로 앱 삭제 | 중간 | 높음 | Adaptive Geofencing (Motion Detection) |
| iOS Live Activities 제한 | 낮음 | 중간 | 안드로이드 먼저 출시 후 iOS 대응 |

### 6.2 법적/규제 리스크

| 리스크 | 발생 확률 | 영향도 | 대응 전략 |
|--------|-----------|--------|-----------|
| 앱스토어 심사 거절 (IAP 이슈) | 중간 | 치명적 | Forfeit 선례 연구 + 사전 상담 |
| 사행성 규제 적용 | 낮음 | 치명적 | "성공=원금보존" 구조 + 법률 자문 |
| 소비자 피해 소송 | 낮음 | 높음 | 명확한 약관 + 환불 정책 |

### 6.3 비즈니스 리스크

| 리스크 | 발생 확률 | 영향도 | 대응 전략 |
|--------|-----------|--------|-----------|
| API 비용 폭증 (구글 가격 인상) | 높음 | 높음 | 네이버 API 우선 사용 + Adaptive Polling |
| 페널티 반발로 사용자 이탈 | 중간 | 중간 | 게임화 강화 + 긍정적 강화 병행 |
| 경쟁사 복제 | 높음 | 중간 | 특허 출원 + 한국 시장 선점 |

---

## 🎓 7. 참고 자료 / References

### 학술 논문
1. Kahneman, D., & Tversky, A. (1979). Prospect Theory: An Analysis of Decision under Risk
2. Buehler, R., Griffin, D., & Ross, M. (1994). Exploring the "Planning Fallacy"
3. Barkley, R. A. (2012). Executive Functions: What They Are, ADHD, and How They Develop

### 경쟁사 및 시장 조사
4. Tiimo App - Visual Daily Planner
5. Owaves - Circadian Rhythm Planner
8. Forfeit - Habit Formation with Financial Stakes
9. Beeminder - Goal Tracking with Money on the Line

### 기술 문서
10. Google Maps Platform - Korea Restrictions
13. Naver Cloud Platform - Maps API Documentation
14. Kakao Developers - Mobility API
22. Android Background Location Limits
29. Apple ActivityKit Documentation

---

**다음 단계 (Next Steps)**:
1. 📋 기획 질문 체크리스트 작성 → `02_Planning_Questions.md` 참조
2. 🏗️ 기술 아키텍처 설계 → `03_Technical_Architecture.md` 참조
3. 💰 PoC(Proof of Concept) 예산 및 일정 수립
4. 👥 개발팀 구성 (Flutter, Backend, iOS Native)

---

**문서 관리**:
- 주 검토 주기: 2주
- 담당자: [TBD]
- 최종 승인: [TBD]
