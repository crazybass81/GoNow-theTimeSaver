# Archived Test Results - 2025-01-07

## Archive Reason
These test results have been archived because they are superseded by the TMAP API migration tests.

## Archived Files

### test_results.txt
- **Date**: Previous session (before 2025-01-07)
- **Type**: E2E (End-to-End) test results
- **Status**: 23/23 tests passed
- **Context**: Tests ran before TMAP API migration
- **Superseded by**: E2E tests are still valid but not re-run in this session

### unit_test_results.txt
- **Date**: Previous session (before TMAP migration)
- **Type**: Unit test results
- **Tests**: 303 total tests
- **Issues**: 2 compilation failures in route_service_integration_test.dart
- **Errors**:
  - Outdated test code using `getRoute()` instead of `calculateRoute()`
  - Reference to non-existent model file
- **Superseded by**: `tmap_full_unit_test_results.txt` (305 tests, all passing)

### unit_test_results_fixed.txt
- **Date**: After fixing compilation errors, before TMAP migration
- **Type**: Unit test results
- **Context**: Tests after fixing route_service_integration_test.dart but with `skip: true`
- **Superseded by**: `tmap_full_unit_test_results.txt` (305 tests, all passing with TMAP API)

## Current Active Test Results

For current test results, see:
- `/test_results_2025_01_07/tmap_integration_test_results.txt` - Integration tests with TMAP API (4/4 passed)
- `/test_results_2025_01_07/tmap_full_unit_test_results.txt` - Full unit test suite (305/305 passed)
- `/docs/TEST_RESULTS_2025_01_07.md` - Complete test result documentation

## Key Changes Since These Results

1. **API Migration**: Naver Directions API → TMAP Routes API
2. **Test Updates**: All integration tests updated for TMAP
3. **All Tests Passing**: 305/305 unit tests + 4/4 integration tests
4. **Device Testing**: Successfully deployed to SM A136S (Android 14)

---

**Archive Date**: 2025-01-07
**Reason**: Superseded by TMAP migration test results
**Status**: Historical reference only
