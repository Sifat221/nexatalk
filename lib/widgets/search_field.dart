import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_typography.dart';

/// Glassmorphic search input field with debounce support and clear action.
class SearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const SearchField({
    super.key,
    this.hintText = 'Search conversations',
    required this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _internalController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _hasText = _internalController.text.isNotEmpty;
    _internalController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final has = _internalController.text.isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _clear() {
    _internalController.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: AppRadius.roundedL,
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _internalController,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.primaryCyan,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textTertiary),
                  onPressed: _clear,
                )
              : null,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
