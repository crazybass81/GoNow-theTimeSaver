import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// TMAP POI (Point of Interest) 검색 서비스 / TMAP POI Search Service
///
/// **기능 / Features**:
/// - TMAP POI Search API 연동
/// - 장소 이름으로 검색
/// - 좌표 정보 반환
/// - 에러 핸들링 및 재시도 로직
///
/// **Context**: 일정 추가 시 목적지 검색
/// **Business Rule**: 검색 결과는 최대 20개까지 반환
class POISearchService {
  /// Singleton instance
  static final POISearchService _instance = POISearchService._internal();
  factory POISearchService() => _instance;
  POISearchService._internal();

  /// Dio HTTP 클라이언트 / HTTP client
  late final Dio _dio;

  /// 초기화 상태 플래그 / Initialization flag
  bool _isInitialized = false;

  /// 초기화 메서드 / Initialize Dio client
  ///
  /// **Context**: 앱 시작 시 호출 (main.dart)
  void initialize() {
    if (_isInitialized) {
      print('POISearchService: Already initialized, skipping');
      return;
    }

    final appKey = dotenv.env['TMAP_APP_KEY'];

    if (appKey == null) {
      throw Exception('TMAP API key not configured in .env file');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://apis.openapi.sk.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'appKey': appKey,
        },
      ),
    );

    _isInitialized = true;
    print('POISearchService: Initialized successfully');
  }

  /// 장소 검색 / Search places
  ///
  /// **비즈니스 규칙 / Business Rule**: 최대 20개 결과 반환
  ///
  /// @param keyword 검색 키워드 (예: "강남역", "스타벅스 강남점")
  /// @param count 결과 개수 (기본 10, 최대 20)
  /// @returns List<POIResult> 검색 결과 목록
  ///
  /// @example
  /// final results = await POISearchService().searchPOI('강남역');
  Future<List<POIResult>> searchPOI({
    required String keyword,
    int count = 10,
  }) async {
    if (!_isInitialized) {
      throw Exception('POISearchService not initialized');
    }

    if (keyword.trim().isEmpty) {
      return [];
    }

    try {
      // TMAP POI Search API 호출
      // https://openapi.sk.com/products/detail?svcSeq=62
      final response = await _dio.get(
        '/tmap/pois',
        queryParameters: {
          'version': '1',
          'searchKeyword': keyword,
          'resCoordType': 'WGS84GEO',
          'reqCoordType': 'WGS84GEO',
          'count': count.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final searchPoiInfo = data['searchPoiInfo'];

        if (searchPoiInfo == null) {
          return [];
        }

        final totalCount = int.tryParse(searchPoiInfo['totalCount'] ?? '0') ?? 0;

        if (totalCount == 0) {
          return [];
        }

        final pois = searchPoiInfo['pois'];
        if (pois == null || pois['poi'] == null) {
          return [];
        }

        final poiList = pois['poi'] as List<dynamic>;

        return poiList.map((poi) {
          return POIResult(
            id: poi['id'] ?? '',
            name: poi['name'] ?? '',
            address: _buildFullAddress(poi),
            lat: double.tryParse(poi['noorLat'] ?? '0') ?? 0.0,
            lng: double.tryParse(poi['noorLon'] ?? '0') ?? 0.0,
            category: poi['mlClass'] ?? '',
            telNo: poi['telNo'],
            roadAddress: _buildRoadAddress(poi),
          );
        }).toList();
      } else {
        throw Exception('POI 검색 실패: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorType = _handleDioError(e);
      throw POISearchException(
        message: errorType.message,
        type: errorType.type,
        originalError: e,
      );
    } catch (e) {
      throw POISearchException(
        message: '예상치 못한 오류가 발생했습니다: $e',
        type: POIErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// 전체 주소 조합 / Build full address
  String _buildFullAddress(Map<String, dynamic> poi) {
    final upper = poi['upperAddrName'] ?? '';
    final middle = poi['middleAddrName'] ?? '';
    final lower = poi['lowerAddrName'] ?? '';
    final detail = poi['detailAddrName'] ?? '';

    final parts = [upper, middle, lower, detail]
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.join(' ');
  }

  /// 도로명 주소 조합 / Build road address
  String? _buildRoadAddress(Map<String, dynamic> poi) {
    final roadName = poi['roadName'];
    final buildingNo1 = poi['buildingNo1'];

    if (roadName == null || buildingNo1 == null) {
      return null;
    }

    final buildingNo2 = poi['buildingNo2'];
    final buildingNo = buildingNo2 != null && buildingNo2.isNotEmpty
        ? '$buildingNo1-$buildingNo2'
        : buildingNo1;

    return '$roadName $buildingNo';
  }

  /// Dio 에러 핸들링 / Handle Dio errors
  _ErrorInfo _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return _ErrorInfo(
          type: POIErrorType.networkTimeout,
          message: '네트워크 시간이 초과되었습니다.',
        );
      case DioExceptionType.cancel:
        return _ErrorInfo(
          type: POIErrorType.cancelled,
          message: '요청이 취소되었습니다.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return _ErrorInfo(
            type: POIErrorType.invalidApiKey,
            message: 'API 인증에 실패했습니다.',
          );
        } else if (statusCode == 429) {
          return _ErrorInfo(
            type: POIErrorType.rateLimitExceeded,
            message: 'API 호출 한도를 초과했습니다.',
          );
        } else {
          return _ErrorInfo(
            type: POIErrorType.apiError,
            message: 'API 오류가 발생했습니다 (HTTP $statusCode).',
          );
        }
      case DioExceptionType.connectionError:
        return _ErrorInfo(
          type: POIErrorType.networkError,
          message: '네트워크 연결에 실패했습니다.',
        );
      default:
        return _ErrorInfo(
          type: POIErrorType.unknown,
          message: '알 수 없는 오류가 발생했습니다.',
        );
    }
  }
}

/// POI 검색 결과 / POI search result
class POIResult {
  final String id; // POI ID
  final String name; // 장소 이름
  final String address; // 전체 주소
  final double lat; // 위도
  final double lng; // 경도
  final String category; // 카테고리 (예: "음식점", "지하철")
  final String? telNo; // 전화번호
  final String? roadAddress; // 도로명 주소

  POIResult({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.category,
    this.telNo,
    this.roadAddress,
  });

  /// 표시용 주소 (도로명 우선) / Display address
  String get displayAddress => roadAddress ?? address;

  @override
  String toString() {
    return 'POIResult(name: $name, address: $address, category: $category)';
  }
}

/// POI 검색 에러 타입 / POI search error types
enum POIErrorType {
  networkError,
  networkTimeout,
  invalidApiKey,
  rateLimitExceeded,
  apiError,
  cancelled,
  unknown,
}

/// POI 검색 예외 / POI search exception
class POISearchException implements Exception {
  final String message;
  final POIErrorType type;
  final Object? originalError;

  POISearchException({
    required this.message,
    required this.type,
    this.originalError,
  });

  String get userMessage {
    switch (type) {
      case POIErrorType.networkError:
      case POIErrorType.networkTimeout:
        return '네트워크 연결이 불안정합니다.\n인터넷 연결을 확인해주세요.';
      case POIErrorType.invalidApiKey:
        return '서비스 인증에 실패했습니다.\n잠시 후 다시 시도해주세요.';
      case POIErrorType.rateLimitExceeded:
        return 'API 호출 한도를 초과했습니다.\n잠시 후 다시 시도해주세요.';
      case POIErrorType.apiError:
        return '장소 검색 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
      case POIErrorType.cancelled:
        return '요청이 취소되었습니다.';
      case POIErrorType.unknown:
        return '예상치 못한 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.';
    }
  }

  @override
  String toString() {
    return 'POISearchException: $message (type: $type)';
  }
}

/// 에러 정보 내부 클래스 / Internal error info class
class _ErrorInfo {
  final POIErrorType type;
  final String message;

  _ErrorInfo({
    required this.type,
    required this.message,
  });
}
