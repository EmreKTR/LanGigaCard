import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Labeled text field matching the design's small-caps gray label style,
/// with an automatic show/hide toggle for password fields.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.required = false,
    this.controller,
    this.keyboardType,
    this.errorText,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final String? hint;
  final bool obscureText;
  final bool required;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? errorText;
  final FocusNode? focusNode;

  /// Lets forms wire up "next"/"done" so the keyboard can move between
  /// fields and submit — previously every field dead-ended.
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.required ? '${widget.label} *' : widget.label,
          style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.6),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            suffixIcon: widget.obscureText
                ? IconButton(
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    icon: Icon(_obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: colors.textMuted),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// Simple password strength meter used on RegisterScreen.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  int _score(BuildContext context) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~%^()_+\-=]').hasMatch(password)) score++;
    return score;
  }

  (Color, String) _meta(BuildContext context, int score) {
    final colors = context.appColors;
    return switch (score) {
      0 || 1 => (colors.srsAgain, 'Weak'),
      2 => (colors.srsHard, 'Fair'),
      3 => (colors.srsMedium, 'Good'),
      _ => (colors.srsEasy, 'Strong'),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;
    final score = _score(context);
    final (color, label) = _meta(context, score);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: score / 4,
                minHeight: 6,
                backgroundColor: colors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
