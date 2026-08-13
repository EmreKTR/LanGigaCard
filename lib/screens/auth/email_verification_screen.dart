import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../onboarding_setup/onboarding_setup_screen.dart';
import 'login_screen.dart';

const _codeLength = 6;

/// Shown right after "Create Account". There's no real backend/email
/// service in this project, so the 6-digit code is generated locally
/// (and printed to the debug console) and "verification" is simulated —
/// entering the matching code moves on to the onboarding wizard.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.firstName, required this.lastName, required this.email});

  final String firstName;
  final String lastName;
  final String email;

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late String _sentCode = _generateCode();
  final _controllers = List.generate(_codeLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  String? _error;
  bool _verifying = false;

  String _generateCode() {
    // TEMPORARY: hardcoded so the flow can be tested end-to-end without a
    // real email service. Swap back to a random code once one exists.
    const code = '123456';
    debugPrint('[LanGigaCards] Email verification code for ${widget.email}: $code');
    return code;
  }

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

  void _resend() {
    setState(() {
      _sentCode = _generateCode();
      _error = null;
      for (final c in _controllers) {
        c.clear();
      }
    });
    _focusNodes.first.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A new code was sent to your email')));
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
      setState(() => _error = 'Enter all $_codeLength digits');
      return;
    }
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    if (entered == _sentCode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnboardingSetupScreen(firstName: widget.firstName, lastName: widget.lastName, email: widget.email),
        ),
      );
      return;
    }
    setState(() {
      _verifying = false;
      _error = 'Incorrect code, please try again';
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
                    label: const Text('Back to sign in'),
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
                    Text('Verify Your Email', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'We sent a 6-digit code to ${widget.email}. Enter it below to confirm your account.',
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
                        Text("Didn't get a code?", style: TextStyle(color: colors.textSecondary)),
                        TextButton(onPressed: _resend, child: const Text('Resend code')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(label: 'Verify', onPressed: _verifying ? null : _verify, loading: _verifying),
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
