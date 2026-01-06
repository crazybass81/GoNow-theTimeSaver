import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 인증 상태 / Authentication State
enum AuthStatus {
  /// 인증되지 않음 / Not authenticated
  unauthenticated,

  /// 인증 중 / Authenticating
  authenticating,

  /// 인증됨 / Authenticated
  authenticated,
}

/// 인증 상태 관리 Provider / Authentication State Management Provider
///
/// **기능 / Features**:
/// - 이메일/비밀번호 로그인/회원가입
/// - 소셜 로그인 (Google, Apple, Kakao)
/// - 로그아웃
/// - 인증 상태 관리
/// - 사용자 정보 관리
///
/// **Context**: Provider 패턴을 사용한 전역 상태 관리
class AuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  AuthStatus _status = AuthStatus.unauthenticated;
  User? _currentUser;
  String? _errorMessage;

  /// 현재 인증 상태 / Current authentication status
  AuthStatus get status => _status;

  /// 현재 로그인된 사용자 / Current logged-in user
  User? get currentUser => _currentUser;

  /// 에러 메시지 / Error message
  String? get errorMessage => _errorMessage;

  /// 로그인 여부 / Whether user is logged in
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initializeAuthState();
  }

  /// 초기 인증 상태 확인 / Initialize authentication state
  void _initializeAuthState() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
    }

    // 인증 상태 변경 리스너 등록 / Register auth state change listener
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _currentUser = session.user;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// 이메일/비밀번호 로그인 / Email/Password Login
  ///
  /// **Context**: 로그인 화면에서 호출
  ///
  /// @param email - 사용자 이메일 / User email
  /// @param password - 사용자 비밀번호 / User password
  /// @returns 성공 여부 / Success status
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _currentUser = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        throw Exception('로그인에 실패했습니다');
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// 이메일/비밀번호 회원가입 / Email/Password Signup
  ///
  /// **Context**: 회원가입 화면에서 호출
  ///
  /// @param email - 사용자 이메일 / User email
  /// @param password - 사용자 비밀번호 / User password
  /// @param name - 사용자 이름 (선택) / User name (optional)
  /// @param phone - 전화번호 (선택) / Phone number (optional)
  /// @returns 성공 여부 / Success status
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.session != null) {
        _currentUser = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        // 이메일 확인 필요한 경우 / Email verification required
        _status = AuthStatus.unauthenticated;
        _errorMessage = '이메일 확인이 필요합니다. 메일함을 확인해주세요.';
        notifyListeners();
        return true; // 회원가입 자체는 성공
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// 소셜 로그인 / Social Login
  ///
  /// **Context**: 로그인/회원가입 화면에서 호출
  ///
  /// @param provider - 소셜 로그인 제공자 (google, apple, kakao)
  /// @returns 성공 여부 / Success status
  Future<bool> signInWithProvider({
    required OAuthProvider provider,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithOAuth(provider);

      if (response) {
        // OAuth는 비동기로 처리되므로 onAuthStateChange에서 처리됨
        // OAuth is handled asynchronously, processed in onAuthStateChange
        return true;
      } else {
        throw Exception('소셜 로그인에 실패했습니다');
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// 로그아웃 / Logout
  ///
  /// **Context**: 설정 화면, 사이드바 등에서 호출
  ///
  /// @returns 성공 여부 / Success status
  Future<bool> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// 비밀번호 재설정 이메일 발송 / Send password reset email
  ///
  /// **Context**: 비밀번호 찾기 화면에서 호출
  ///
  /// @param email - 사용자 이메일 / User email
  /// @returns 성공 여부 / Success status
  Future<bool> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// 사용자 프로필 업데이트 / Update user profile
  ///
  /// **Context**: 프로필 수정 화면에서 호출
  ///
  /// @param name - 사용자 이름 / User name
  /// @param phone - 전화번호 / Phone number
  /// @returns 성공 여부 / Success status
  Future<bool> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (phone != null) 'phone': phone,
          },
        ),
      );

      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// 에러 메시지 변환 / Convert error message
  ///
  /// **Context**: Supabase 에러를 사용자 친화적 메시지로 변환
  ///
  /// @param error - 에러 객체 / Error object
  /// @returns 한글 에러 메시지 / Korean error message
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return '잘못된 요청입니다. 입력 정보를 확인해주세요.';
        case '401':
          return '이메일 또는 비밀번호가 올바르지 않습니다.';
        case '422':
          return '이미 가입된 이메일입니다.';
        case '429':
          return '너무 많은 요청을 보냈습니다. 잠시 후 다시 시도해주세요.';
        default:
          return error.message;
      }
    }
    return error.toString();
  }

  /// 에러 메시지 초기화 / Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
