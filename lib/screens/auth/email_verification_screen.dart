import 'package:flutter/material.dart';
import '../../data/api/auth_api.dart';
import '../../data/auth_store.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../onboarding_setup/onboarding_setup_screen.dart';
import 'login_screen.dart';

const _codeLength = 6;

/// Shown right after "Create Account". Registering already caused the server
/// to mail a code, so this screen only submits what the learner types — the
/// code itself is never known to the app.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.firstName, required this.lastName, required this.email});

  final String firstName;
  final String lastName;
  final String email;

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _controllers = List.generate(_codeLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  String? _error;
  bool _verifying = false;
  bool _resending = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final sent = await AuthStore.api.sendVerificationCode(widget.email);
    if (!mounted) return;

    setState(() {
      _resending = false;
      _error = null;
      for (final c in _controllers) {
        c.clear();
      }
    });
    _focusNodes.first.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sent
          ? AppLocalizations.of(context).verifyResent
          : AppLocalizations.of(context).profileServerUnreachable),
    ));
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _verify() async {
    final entered = _controllers.map((c) => c.text).join();
    if (entered.length != _codeLength) {
      setState(() => _error = AppLocalizations.of(context).verifyEnterAllDigits(_codeLength));
      return;
    }
    setState(() => _verifying = true);
    final result = await AuthStore.api.verifyEmail(email: widget.email, code: entered);
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnboardingSetupScreen(firstName: widget.firstName, lastName: widget.lastName, email: widget.email),
        ),
      );
      return;
    }

    setState(() {
      _verifying = false;
      _error = switch (result.outcome) {
        // The code is dead at this point, so point at the fix rather than
        // inviting another doomed attempt.
        VerificationOutcome.tooManyAttempts => AppLocalizations.of(context).verifyTooManyAttempts,
        VerificationOutcome.networkError => AppLocalizations.of(context).commonNetworkError,
        _ => AppLocalizations.of(context).verifyIncorrect,
      };
      for (final c in _controllers) {
        c.clear();
      }
    });
    _focusNodes.first.requestFocus();
  }

  void _backToSignIn() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _backToSignIn,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text(l10n.registerBackToSignIn),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.verifyTitle, style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.verifySubtitle(widget.email),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _codeLength; i++)
                          _CodeBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            onChanged: (v) => _onDigitChanged(i, v),
                            hasError: _error != null,
                          ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: colors.danger, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Text(_error!, style: TextStyle(color: colors.danger, fontSize: 13)),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.verifyNoCode, style: TextStyle(color: colors.textSecondary)),
                        TextButton(
                          onPressed: _resending ? null : _resend,
                          child: Text(_resending ? l10n.verifySending : l10n.verifyResend),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(label: l10n.verifyAction, onPressed: _verifying ? null : _verify, loading: _verifying),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.controller, required this.focusNode, required this.onChanged, required this.hasError});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: hasError ? colors.danger : colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: hasError ? colors.danger : colors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
