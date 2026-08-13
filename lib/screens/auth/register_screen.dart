import 'package:flutter/material.dart';
import '../../data/api/auth_api.dart';
import '../../data/auth_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import 'email_verification_screen.dart';

/// Collects the learner's personal details and registers the account
/// locally. Languages and study preferences are gathered afterwards by the
/// onboarding wizard, reached via [EmailVerificationScreen].
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  // Whether Step 1's "Continue" was pressed while invalid — once true, every
  // field's error shows regardless of individual focus history.
  bool _step1Submitted = false;
  bool _firstNameTouched = false;
  bool _lastNameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  bool _creating = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _firstNameFocusNode.addListener(() => _onFocusLost(_firstNameFocusNode, () => _firstNameTouched = true));
    _lastNameFocusNode.addListener(() => _onFocusLost(_lastNameFocusNode, () => _lastNameTouched = true));
    _emailFocusNode.addListener(() => _onFocusLost(_emailFocusNode, () => _emailTouched = true));
    _passwordFocusNode.addListener(() => _onFocusLost(_passwordFocusNode, () => _passwordTouched = true));
    _confirmFocusNode.addListener(() => _onFocusLost(_confirmFocusNode, () => _confirmTouched = true));
  }

  void _onFocusLost(FocusNode node, VoidCallback markTouched) {
    if (!node.hasFocus) setState(markTouched);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  bool get _step1Valid =>
      _firstNameController.text.isNotEmpty &&
      _lastNameController.text.isNotEmpty &&
      _emailController.text.contains('@') &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmController.text;

  String? get _firstNameError =>
      (_step1Submitted || _firstNameTouched) && _firstNameController.text.isEmpty ? 'This field is required' : null;

  String? get _lastNameError =>
      (_step1Submitted || _lastNameTouched) && _lastNameController.text.isEmpty ? 'This field is required' : null;

  String? get _emailError =>
      (_step1Submitted || _emailTouched) && !_emailController.text.contains('@') ? 'Please enter a valid email address' : null;

  String? get _passwordError =>
      (_step1Submitted || _passwordTouched) && _passwordController.text.length < 8 ? 'Password must be at least 8 characters' : null;

  String? get _confirmError =>
      (_step1Submitted || _confirmTouched) && _passwordController.text != _confirmController.text
          ? "Passwords don't match"
          : null;

  /// Registers the account against the real backend, then hands off to
  /// email verification and the onboarding wizard, which is where the
  /// language pair and study preferences are actually collected.
  Future<void> _createAccount() async {
    if (_creating) return;
    if (!_step1Valid) {
      setState(() => _step1Submitted = true);
      return;
    }

    setState(() {
      _creating = true;
      _errorText = null;
    });

    // Tracks whether we're about to leave this screen, so the `finally`
    // below never resets `_creating` right before navigating away (that
    // would flash the button back to its idle state for a frame). Anything
    // that throws before this is set still gets `_creating` reset, so the
    // button can never get stuck disabled.
    var didNavigateAway = false;
    try {
      final email = _emailController.text.trim();
      final result = await AuthStore.api.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: email,
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
      if (!mounted) return;

      if (!result.isSuccess) {
        setState(() {
          _creating = false;
          _errorText = switch (result.outcome) {
            AuthOutcome.emailTaken => 'An account with this email already exists.',
            AuthOutcome.networkError => "Can't reach the server. Check your connection and try again.",
            _ => result.message ?? 'Something went wrong. Please try again.',
          };
        });
        return;
      }

      didNavigateAway = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: email,
          ),
        ),
      );
    } finally {
      if (!didNavigateAway && mounted && _creating) {
        setState(() => _creating = false);
      }
    }
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
                    onPressed: () => Navigator.of(context).maybePop(),
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
                    Text('Create Account', style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Your details — languages and study preferences come next.',
                      style: TextStyle(color: colors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (_errorText != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: colors.danger, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(_errorText!, style: TextStyle(color: colors.danger, fontSize: 13))),
                          ],
                        ),
                      ),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _firstNameController,
                        _lastNameController,
                        _emailController,
                        _passwordController,
                        _confirmController,
                      ]),
                      builder: (context, _) => _PersonalDetailsStep(
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmController: _confirmController,
                        firstNameFocusNode: _firstNameFocusNode,
                        lastNameFocusNode: _lastNameFocusNode,
                        emailFocusNode: _emailFocusNode,
                        passwordFocusNode: _passwordFocusNode,
                        confirmFocusNode: _confirmFocusNode,
                        firstNameError: _firstNameError,
                        lastNameError: _lastNameError,
                        emailError: _emailError,
                        passwordError: _passwordError,
                        confirmError: _confirmError,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryButton(
                label: 'Create Account',
                loading: _creating,
                onPressed: _createAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _PersonalDetailsStep extends StatelessWidget {
  const _PersonalDetailsStep({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.firstNameFocusNode,
    required this.lastNameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmFocusNode,
    required this.firstNameError,
    required this.lastNameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmError,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  final FocusNode firstNameFocusNode;
  final FocusNode lastNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmFocusNode;

  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'First Name',
                required: true,
                hint: 'Sarah',
                controller: firstNameController,
                focusNode: firstNameFocusNode,
                errorText: firstNameError,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: 'Last Name',
                required: true,
                hint: 'Johnson',
                controller: lastNameController,
                focusNode: lastNameFocusNode,
                errorText: lastNameError,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Email Address',
          required: true,
          hint: 'sarah@example.com',
          controller: emailController,
          focusNode: emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Password',
          required: true,
          hint: 'Min. 8 characters',
          obscureText: true,
          controller: passwordController,
          focusNode: passwordFocusNode,
          errorText: passwordError,
        ),
        PasswordStrengthMeter(password: passwordController.text),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Confirm Password',
          required: true,
          hint: 'Re-enter your password',
          obscureText: true,
          controller: confirmController,
          focusNode: confirmFocusNode,
          errorText: confirmError,
        ),
      ],
    );
  }
}

