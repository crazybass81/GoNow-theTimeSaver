/// Time Item 모델 / Time Item Model
///
/// **기능 / Features**:
/// - 준비시간/마무리시간 항목 데이터
/// - Supabase DB와 매핑
///
/// **Context**: 일정 생성 시 사용되는 시간 항목 관리
class TimeItem {
  final String? id;
  final String userId;
  final String name;
  final int minutes;
  final String emoji;
  final String type; // 'preparation' or 'completion'
  final DateTime? createdAt;

  TimeItem({
    this.id,
    required this.userId,
    required this.name,
    required this.minutes,
    required this.emoji,
    required this.type,
    this.createdAt,
  });

  /// Supabase에서 가져온 데이터를 모델로 변환 / Convert from Supabase
  factory TimeItem.fromJson(Map<String, dynamic> json) {
    return TimeItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      minutes: json['minutes'] as int,
      emoji: json['emoji'] as String,
      type: json['type'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Supabase에 저장할 데이터로 변환 / Convert to Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'minutes': minutes,
      'emoji': emoji,
      'type': type,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// 로컬 UI용 간단한 Map 변환 / Convert to simple map for local UI
  Map<String, dynamic> toSimpleMap() {
    return {
      'name': name,
      'minutes': minutes,
      'emoji': emoji,
    };
  }

  /// 간단한 Map에서 TimeItem 생성 (type과 userId 필요) / Create from simple map
  factory TimeItem.fromSimpleMap(
    Map<String, dynamic> map,
    String userId,
    String type,
  ) {
    return TimeItem(
      userId: userId,
      name: map['name'] as String,
      minutes: map['minutes'] as int,
      emoji: map['emoji'] as String,
      type: type,
    );
  }

  /// 복사본 생성 / Create a copy with optional field updates
  TimeItem copyWith({
    String? id,
    String? userId,
    String? name,
    int? minutes,
    String? emoji,
    String? type,
    DateTime? createdAt,
  }) {
    return TimeItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      minutes: minutes ?? this.minutes,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
