import 'package:flutter/material.dart';
import '../../data/api/auth_api.dart';
import '../../data/auth_store.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import '../main_shell.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _signingIn = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
    _restoreRememberedEmail();
  }

  /// "Remember me" only ever stores the email — never the password — so a
  /// returning user finds the field prefilled and the box already ticked.
  Future<void> _restoreRememberedEmail() async {
    final email = await AuthStore.loadRememberedEmail();
    if (email == null || !mounted) return;
    setState(() {
      _emailController.text = email;
      _rememberMe = true;
    });
  }

  void _clearError() {
    if (_errorText != null) setState(() => _errorText = null);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _errorText = null;
    });

    // Tracks whether we're about to leave this screen, so the `finally`
    // below never resets `_signingIn` right before navigating away (that
    // would flash the button back to its idle state for a frame). Anything
    // that throws before this is set still gets `_signingIn` reset, so the
    // button can never get stuck disabled.
    var didNavigateAway = false;
    try {
      final email = _emailController.text.trim();
      final result = await AuthStore.api.login(email: email, password: _passwordController.text);
      if (!mounted) return;

      if (!result.isSuccess) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _signingIn = false;
          _errorText = switch (result.outcome) {
            AuthOutcome.networkError => l10n.commonNetworkError,
            _ => l10n.loginInvalidCredentials,
          };
        });
        return;
      }

      await AuthStore.rememberEmail(_rememberMe ? email : null);
      if (!mounted) return;

      didNavigateAway = true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (r) => false,
      );
    } finally {
      if (!didNavigateAway && mounted && _signingIn) {
        setState(() => _signingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors.primaryGradient),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.style_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(l10n.loginTitle, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.loginSubtitle, style: Theme.of(context).textTheme.bodyLarge),
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
              AutofillGroup(
                child: Column(
                  children: [
                    AppTextField(
                      label: l10n.loginEmailLabel,
                      hint: 'sarah@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.loginPasswordLabel,
                      hint: '••••••••',
                      obscureText: true,
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _login(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) => setState(() => _rememberMe = v ?? false),
                            side: BorderSide(color: colors.border),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(l10n.loginRememberMe, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: Text(l10n.loginForgotPassword),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: l10n.commonSignIn, loading: _signingIn, onPressed: _login),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: Divider(color: colors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(l10n.loginOrContinueWith, style: TextStyle(color: colors.textMuted, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: colors.border)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: SocialButton(label: 'Google', icon: Icons.g_mobiledata_rounded, onPressed: () {})),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: SocialButton(label: 'Apple', icon: Icons.apple_rounded, onPressed: () {})),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.loginNoAccount, style: TextStyle(color: colors.textSecondary)),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: Text(l10n.registerTitle),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
