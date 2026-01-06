/// 경로 캐싱 서비스 / Route Caching Service
///
/// **기능 / Features**:
/// - 경로 조회 결과 인메모리 캐싱
/// - 5분 유효기간 자동 만료
/// - 중복 요청 방지
/// - 캐시 무효화 로직
///
/// **비즈니스 규칙 / Business Rule**:
/// - 동일 출발지/도착지 조합은 5분간 캐시 사용
/// - API 호출 횟수 절감으로 비용 최소화
///
/// **Context**: RouteService에서 사용
class CacheService<T> {
  /// Singleton instance
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  /// 캐시 저장소 / Cache storage
  final Map<String, _CacheEntry<T>> _cache = {};

  /// 기본 캐시 유효기간 (밀리초) / Default cache duration in milliseconds
  static const int defaultCacheDurationMs = 5 * 60 * 1000; // 5분

  /// 캐시 조회 / Get cached data
  ///
  /// **Context**: API 호출 전 캐시 확인
  ///
  /// @param key 캐시 키 / Cache key
  /// @returns 캐시된 데이터 또는 null / Cached data or null
  T? get(String key) {
    final entry = _cache[key];

    // 캐시가 없거나 만료된 경우
    if (entry == null || entry.isExpired) {
      if (entry != null) {
        // 만료된 캐시 제거 / Remove expired cache
        _cache.remove(key);
      }
      return null;
    }

    return entry.data;
  }

  /// 캐시 저장 / Set cache data
  ///
  /// **Context**: API 호출 성공 후 캐시 저장
  ///
  /// @param key 캐시 키 / Cache key
  /// @param data 저장할 데이터 / Data to cache
  /// @param durationMs 캐시 유효기간 (밀리초) / Cache duration in milliseconds
  void set(String key, T data, {int? durationMs}) {
    final expiry = DateTime.now().millisecondsSinceEpoch +
        (durationMs ?? defaultCacheDurationMs);

    _cache[key] = _CacheEntry(
      data: data,
      expiryTime: expiry,
    );
  }

  /// 특정 키의 캐시 무효화 / Invalidate specific cache
  ///
  /// **Context**: 경로 재조회 필요 시
  ///
  /// @param key 캐시 키 / Cache key
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// 모든 캐시 무효화 / Invalidate all cache
  ///
  /// **Context**: 사용자 설정 변경 시 (버퍼 시간 등)
  void invalidateAll() {
    _cache.clear();
  }

  /// 만료된 캐시 정리 / Clean up expired cache
  ///
  /// **Context**: 주기적으로 호출하여 메모리 관리
  void cleanExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _cache.removeWhere((key, entry) => entry.expiryTime < now);
  }

  /// 캐시 키 생성 (좌표 기반) / Generate cache key from coordinates
  ///
  /// **Context**: 출발지/도착지 조합으로 고유 키 생성
  ///
  /// @param originLat 출발지 위도
  /// @param originLng 출발지 경도
  /// @param destLat 도착지 위도
  /// @param destLng 도착지 경도
  /// @param option 경로 옵션 (trafast/tracomfort/traoptimal)
  /// @returns 캐시 키 문자열 / Cache key string
  ///
  /// @example
  /// final key = CacheService.generateRouteKey(
  ///   originLat: 37.5665,
  ///   originLng: 126.9780,
  ///   destLat: 37.4979,
  ///   destLng: 127.0276,
  ///   option: 'trafast',
  /// );
  /// // Result: "route_37.5665_126.9780_37.4979_127.0276_trafast"
  static String generateRouteKey({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String option = 'trafast',
  }) {
    // 소수점 4자리까지만 사용 (약 11m 오차 허용)
    // This allows ~11m position tolerance
    final originLatRounded = originLat.toStringAsFixed(4);
    final originLngRounded = originLng.toStringAsFixed(4);
    final destLatRounded = destLat.toStringAsFixed(4);
    final destLngRounded = destLng.toStringAsFixed(4);

    return 'route_${originLatRounded}_${originLngRounded}_${destLatRounded}_${destLngRounded}_$option';
  }

  /// 캐시 통계 조회 / Get cache statistics
  ///
  /// **Context**: 디버깅 및 모니터링
  ///
  /// @returns 캐시 통계 정보 / Cache statistics
  CacheStats getStats() {
    final now = DateTime.now().millisecondsSinceEpoch;
    int validCount = 0;
    int expiredCount = 0;

    for (final entry in _cache.values) {
      if (entry.expiryTime >= now) {
        validCount++;
      } else {
        expiredCount++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
    );
  }

  /// 캐시 존재 여부 확인 / Check if cache exists
  ///
  /// @param key 캐시 키 / Cache key
  /// @returns 유효한 캐시 존재 여부 / Whether valid cache exists
  bool has(String key) {
    return get(key) != null;
  }

  /// 캐시 잔여 시간 조회 (밀리초) / Get remaining cache time in milliseconds
  ///
  /// @param key 캐시 키 / Cache key
  /// @returns 잔여 시간 또는 null / Remaining time or null
  int? getRemainingTime(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = entry.expiryTime - now;

    return remaining > 0 ? remaining : null;
  }
}

/// 캐시 엔트리 내부 클래스 / Cache entry internal class
class _CacheEntry<T> {
  /// 캐시 데이터 / Cached data
  final T data;

  /// 만료 시간 (Unix timestamp, milliseconds) / Expiry time
  final int expiryTime;

  _CacheEntry({
    required this.data,
    required this.expiryTime,
  });

  /// 만료 여부 확인 / Check if expired
  bool get isExpired {
    return DateTime.now().millisecondsSinceEpoch >= expiryTime;
  }
}

/// 캐시 통계 / Cache statistics
class CacheStats {
  /// 전체 캐시 항목 수 / Total cache entries
  final int totalEntries;

  /// 유효한 캐시 항목 수 / Valid cache entries
  final int validEntries;

  /// 만료된 캐시 항목 수 / Expired cache entries
  final int expiredEntries;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries)';
  }
}
