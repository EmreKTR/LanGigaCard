import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';

/// "Forgot password?" — collects the email and shows a confirmation state.
///
/// No mail actually goes out (that needs a backend), and the confirmation
/// screen says so plainly instead of implying a reset link is on its way.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final value = _emailController.text.trim();
    return value.contains('@') && !value.startsWith('@') && !value.endsWith('@');
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    // Stand-in for the real request so the button's loading state is exercised.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: _submitted ? _confirmation(context) : _form(context, colors),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, AppColorsExt colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors.primaryGradient),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Reset your password', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Enter the email you signed up with and we'll send you a link to choose a new password.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xxl),
        AnimatedBuilder(
          animation: _emailController,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Email address',
                hint: 'sarah@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                errorText: _emailController.text.isEmpty || _emailValid ? null : 'Enter a valid email address',
                onSubmitted: (_) => _emailValid ? _submit() : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Send reset link',
                loading: _sending,
                onPressed: _emailValid ? _submit : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back to sign in'),
          ),
        ),
      ],
    );
  }

  Widget _confirmation(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 56, color: colors.success),
        const SizedBox(height: AppSpacing.lg),
        Text('Check your inbox', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: [
              const TextSpan(text: 'If an account exists for '),
              TextSpan(
                text: _emailController.text.trim(),
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ', a reset link is on its way.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.srsHard.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.srsHard.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: colors.srsHard),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'This build has no mail server connected, so no email is actually sent.',
                  style: TextStyle(color: colors.srsHard, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _submitted = false),
            child: const Text('Use a different email'),
          ),
        ),
      ],
    );
  }
}
