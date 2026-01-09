# GitHub UI Implementation Reference Guide

**Purpose**: Ready-to-implement code snippets extracted from GitHub repository  
**Source**: https://github.com/khyapple/go_now  
**Date**: 2026-01-09

---

## 1. Password Strength Indicator (Signup Screen)

### Location to Add
File: `lib/screens/auth/signup_screen.dart` (Step 1 - after password input)

### State Variables to Add
```dart
// Add to _SignupScreenState at class level (lines 39-41)
bool _hasMinLength = false;
bool _hasUpperCase = false;
bool _hasLowerCase = false;
bool _hasNumber = false;
bool _hasSpecialChar = false;
```

### Listener Setup
```dart
// Add to initState() - GitHub lines 47-51
@override
void initState() {
  super.initState();
  _passwordController.addListener(_checkPasswordRequirements);
}

// Add method to _SignupScreenState - GitHub lines 53-63
void _checkPasswordRequirements() {
  final password = _passwordController.text;
  setState(() {
    _hasMinLength = password.length >= 8;
    _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    _hasLowerCase = password.contains(RegExp(r'[a-z]'));
    _hasNumber = password.contains(RegExp(r'[0-9]'));
    _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  });
}
```

### UI Widget (Add after password input field)
```dart
// Add to _buildStep1() - GitHub lines 480-487
if (_passwordController.text.isNotEmpty) ...[
  const SizedBox(height: 16),
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPasswordRequirement('8자 이상', _hasMinLength),
        _buildPasswordRequirement('영문 대문자 포함', _hasUpperCase),
        _buildPasswordRequirement('영문 소문자 포함', _hasLowerCase),
        _buildPasswordRequirement('숫자 포함', _hasNumber),
        _buildPasswordRequirement('특수문자 포함', _hasSpecialChar),
      ],
    ),
  ),
],
```

### Helper Widget Method
```dart
// Add to _SignupScreenState - GitHub lines 579-600
Widget _buildPasswordRequirement(String text, bool isMet) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isMet ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isMet ? Colors.green[700] : Colors.red[600],
          ),
        ),
      ],
    ),
  );
}
```

---

## 2. Login Screen Divider Separator

### Location to Add
File: `lib/screens/auth/login_screen.dart` (Between password form and social buttons)

### Current Code Location
Between lines 255 and 289

### Code to Add
```dart
// GitHub lines 212-228
const SizedBox(height: 32),

// 구분선 / Divider
Row(
  children: [
    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '또는',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    ),
    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
  ],
),

const SizedBox(height: 24),

// 소셜 로그인 버튼들
// [Existing social buttons follow]
```

### Theme-Aware Adaptation (Recommended)
```dart
// Use theme for better integration
Row(
  children: [
    Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '또는',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    ),
    Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
  ],
)
```

---

## 3. Social Login Button Helper Widget

### Location to Add
File: `lib/screens/auth/login_screen.dart`

### Usage in Build Method
```dart
// Replace individual OutlinedButton.icon() calls with:
_buildSocialLoginButton(
  label: 'Google로 계속하기',
  backgroundColor: Colors.white,
  textColor: Colors.black87,
  borderColor: Colors.grey[300],
  onPressed: _isLoading ? null : () => _handleSocialLogin('Google'),
),
const SizedBox(height: 12),

_buildSocialLoginButton(
  label: 'Apple로 계속하기',
  backgroundColor: Colors.black,
  textColor: Colors.white,
  onPressed: _isLoading ? null : () => _handleSocialLogin('Apple'),
),
const SizedBox(height: 12),

_buildSocialLoginButton(
  label: 'Kakao로 계속하기',
  backgroundColor: const Color(0xFFFEE500),
  textColor: Colors.black87,
  borderColor: const Color(0xFFFEE500),
  onPressed: _isLoading ? null : () => _handleSocialLogin('Kakao'),
),
```

### Helper Method Implementation
```dart
// GitHub lines 271-303
Widget _buildSocialLoginButton({
  required String label,
  required Color backgroundColor,
  required Color textColor,
  Color? borderColor,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
```

---

## 4. Time Items Management System (Critical Implementation)

### File Structure to Create

```
lib/screens/settings/
  - settings_screen.dart (existing)
  - time_items_screen.dart (NEW)
  - _add_item_dialog.dart (optional: extract for reusability)
```

### Main Time Items Screen
**File**: `lib/screens/settings/time_items_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 준비시간/마무리시간 항목 관리 화면
/// Time Items Management Screen - Add/Edit/Delete operations
///
/// **Context**: Settings screen에서 접근
class TimeItemsScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(List<Map<String, dynamic>>) onSave;
  final String userEmail;

  const TimeItemsScreen({
    required this.title,
    required this.items,
    required this.onSave,
    required this.userEmail,
    super.key,
  });

  @override
  State<TimeItemsScreen> createState() => _TimeItemsScreenState();
}

class _TimeItemsScreenState extends State<TimeItemsScreen> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, dynamic>>.from(widget.items);
  }

  // GitHub lines 101-103: Calculate total time
  int _getTotalTime() {
    return _items.fold(0, (sum, item) => sum + (item['minutes'] as int));
  }

  // GitHub lines 512-524: Add item
  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (name, minutes, emoji) {
          setState(() {
            _items.add({'name': name, 'minutes': minutes, 'emoji': emoji});
            widget.onSave(_items);
          });
        },
      ),
    );
  }

  // GitHub lines 526-541: Edit item
  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        initialName: _items[index]['name'],
        initialMinutes: _items[index]['minutes'],
        initialEmoji: _items[index]['emoji'],
        onAdd: (name, minutes, emoji) {
          setState(() {
            _items[index] = {'name': name, 'minutes': minutes, 'emoji': emoji};
            widget.onSave(_items);
          });
        },
      ),
    );
  }

  // GitHub lines 543-548: Delete item
  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      widget.onSave(_items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            // GitHub lines 574-662: List or empty state
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '항목을 추가해주세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                item['emoji'] ?? '⏰',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${item['minutes']}분',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    color: Colors.grey[600]),
                                onPressed: () => _editItem(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red[400]),
                                onPressed: () => _deleteItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // GitHub lines 665-691: Add button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text(
                  '항목 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Add Item Dialog
```dart
// Continue in same file or extract to _add_item_dialog.dart

class _AddItemDialog extends StatefulWidget {
  final String? initialName;
  final int? initialMinutes;
  final String? initialEmoji;
  final Function(String, int, String) onAdd;

  const _AddItemDialog({
    this.initialName,
    this.initialMinutes,
    this.initialEmoji,
    required this.onAdd,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _minutesController;
  late String _selectedEmoji;

  // GitHub lines 721-724: Available emojis
  final List<String> _availableEmojis = [
    '⏰', '🛁', '👔', '💄', '🍳', '☕', '🚗', '🚌', '🚶', '🏃',
    '📝', '💼', '🎯', '📱', '💻', '📚', '🎨', '🎵', '🏋️', '🧘',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _minutesController =
        TextEditingController(text: widget.initialMinutes?.toString() ?? '');
    _selectedEmoji = widget.initialEmoji ?? '⏰';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // GitHub lines 742-762: Save validation
  void _save() {
    final name = _nameController.text.trim();
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('항목 이름을 입력해주세요')),
      );
      return;
    }

    if (minutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시간은 1분 이상이어야 합니다')),
      );
      return;
    }

    widget.onAdd(name, minutes, _selectedEmoji);
    Navigator.of(context).pop();
  }

  // GitHub lines 764-814: Emoji picker
  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이모지 선택'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _availableEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _availableEmojis[index];
              final isSelected = emoji == _selectedEmoji;
              return InkWell(
                onTap: () {
                  setState(() => _selectedEmoji = emoji);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? '항목 추가' : '항목 수정'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // GitHub lines 826-856: Emoji selector
          InkWell(
            onTap: _showEmojiPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '이모지를 선택하세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // GitHub lines 858-870: Name input
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '항목 이름',
              hintText: '예: 씻기, 회의 준비',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          // GitHub lines 872-885: Minutes input
          TextField(
            controller: _minutesController,
            decoration: InputDecoration(
              labelText: '시간 (분)',
              hintText: '예: 30',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
              suffixText: '분',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      // GitHub lines 888-897: Dialog actions
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소', style: TextStyle(color: Colors.grey[600])),
        ),
        TextButton(
          onPressed: _save,
          child: Text('저장', style: TextStyle(color: Colors.blue[600])),
        ),
      ],
    );
  }
}
```

### Integration with Settings Screen
```dart
// Add to SettingsScreen - in _buildAppSettingsSection():

_buildSettingTile(
  theme: theme,
  icon: Icons.schedule_outlined,
  title: '준비시간',
  subtitle: _prepTimeItems.isEmpty
    ? '항목 없음'
    : '총 ${_getTotalTime(_prepTimeItems)}분 (${_prepTimeItems.length}개 항목)',
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimeItemsScreen(
          title: '준비시간',
          items: _prepTimeItems,
          userEmail: authProvider.currentUser?.email ?? '',
          onSave: (items) {
            setState(() {
              _prepTimeItems = items;
              _savePrepTimeItems();
            });
          },
        ),
      ),
    );
  },
),
const SizedBox(height: 16),

_buildSettingTile(
  theme: theme,
  icon: Icons.timer_outlined,
  title: '마무리시간',
  subtitle: _finishTimeItems.isEmpty
    ? '항목 없음'
    : '총 ${_getTotalTime(_finishTimeItems)}분 (${_finishTimeItems.length}개 항목)',
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimeItemsScreen(
          title: '마무리시간',
          items: _finishTimeItems,
          userEmail: authProvider.currentUser?.email ?? '',
          onSave: (items) {
            setState(() {
              _finishTimeItems = items;
              _saveFinishTimeItems();
            });
          },
        ),
      ),
    );
  },
),
```

---

## Implementation Checklist

- [ ] Password Strength Indicator
  - [ ] Add state variables
  - [ ] Create listener in initState
  - [ ] Implement _checkPasswordRequirements()
  - [ ] Add UI after password input
  - [ ] Implement _buildPasswordRequirement()
  - [ ] Test all 5 requirements

- [ ] Login Screen Divider
  - [ ] Add Row with dividers
  - [ ] Implement theme-aware styling
  - [ ] Verify spacing and alignment

- [ ] Social Button Helper
  - [ ] Extract _buildSocialLoginButton() method
  - [ ] Update all button calls
  - [ ] Test all variants

- [ ] Time Items System
  - [ ] Create TimeItemsScreen widget
  - [ ] Create _AddItemDialog widget
  - [ ] Implement emoji picker
  - [ ] Add CRUD operations
  - [ ] Integrate with settings
  - [ ] Test persistence
  - [ ] Test emoji selection

---

## Testing Guide

### Password Strength Tests
```dart
// Test cases
'Pass123'         // Should show: min length ✓, upper ✓, lower ✓, number ✓, special ✗
'password'        // Should show: min length ✓, upper ✗, lower ✓, number ✗, special ✗
'Password1!'      // Should show: All ✓
''                // Should show: Nothing (conditional display)
```

### Time Items Tests
```dart
// Add item: {"name": "씻기", "minutes": 15, "emoji": "🛁"}
// Edit item: Change minutes to 20
// Delete item: Remove from list
// Verify total time calculation
// Test persistence via SharedPreferences
// Test emoji selection from grid
```

---

## See Also

- Full Analysis: `claudedocs/UI_GAP_ANALYSIS.md`
- Summary: `claudedocs/GITHUB_UI_GAP_SUMMARY.md`
- GitHub Reference: https://github.com/khyapple/go_now
