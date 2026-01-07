import 'package:flutter/services.dart';

/// Helper to detect if IME is composing (Vietnamese input method)
/// and prevent text formatters from breaking accent composition
class VietnameseIMEHelper {
  /// Check if the text value is currently being composed by IME
  static bool isComposing(TextEditingValue value) {
    return value.composing.isValid && value.composing.start < value.composing.end;
  }
}

/// A TextInputFormatter that skips formatting when Vietnamese IME is composing
/// This prevents the loss of characters when typing Vietnamese with accents
class IMESafeTextInputFormatter extends TextInputFormatter {
  final TextInputFormatter wrappedFormatter;

  IMESafeTextInputFormatter(this.wrappedFormatter);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If IME is composing, don't format - just return the new value
    if (VietnameseIMEHelper.isComposing(newValue)) {
      return newValue;
    }

    // Otherwise, apply the wrapped formatter
    final formatted = wrappedFormatter.formatEditUpdate(oldValue, newValue);
    
    // Ensure composing range is cleared after formatting
    return formatted.copyWith(composing: TextRange.empty);
  }
}

/// A simple formatter that just preserves IME composing state
/// Use this for plain text fields (search, notes, names) to fix Vietnamese input
class IMEPreservingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If composing, return as-is to let IME finish
    if (VietnameseIMEHelper.isComposing(newValue)) {
      return newValue;
    }
    
    // Not composing - clear the composing range
    return newValue.copyWith(composing: TextRange.empty);
  }
}
