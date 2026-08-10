import 'package:flutter/material.dart';
import '../../data/auth_store.dart';
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

    final email = _emailController.text.trim();
    final ok = await AuthStore.login(email, _passwordController.text);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _signingIn = false;
        _errorText = 'Incorrect email or password. Create an account if you don\'t have one yet.';
      });
      return;
    }

    await AuthStore.rememberEmail(_rememberMe ? email : null);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
              Text('Welcome back', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text('Sign in to continue your learning journey', style: Theme.of(context).textTheme.bodyLarge),
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
                      label: 'Email address',
                      hint: 'sarah@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Password',
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
                        Text('Remember me', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Sign In', loading: _signingIn, onPressed: _login),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: Divider(color: colors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text('or continue with', style: TextStyle(color: colors.textMuted, fontSize: 12)),
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
                  Text("Don't have an account?", style: TextStyle(color: colors.textSecondary)),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Create Account'),
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
