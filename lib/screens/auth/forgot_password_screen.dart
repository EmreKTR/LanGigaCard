import 'package:flutter/material.dart';
import '../../data/auth_store.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';

/// "Forgot password?" — collects the email and shows a confirmation state.
///
/// The request is real (the server generates and mails a reset token), but
/// nothing in the app can complete a reset yet: the token is a long string
/// meant for a clicked email link, and there's no deep-link handling to
/// receive one. The confirmation screen says so plainly rather than
/// implying the loop closes here.
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
    // The server answers the same way whether or not the address has an
    // account (anti-enumeration), so `sent` only distinguishes "the request
    // went out" from "couldn't reach the server" — never "no such account".
    final sent = await AuthStore.api.requestPasswordReset(_emailController.text.trim());
    if (!mounted) return;

    if (!sent) {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).commonNetworkError)),
      );
      return;
    }

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
    final l10n = AppLocalizations.of(context);
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
        Text(l10n.forgotTitle, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.forgotSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xxl),
        AnimatedBuilder(
          animation: _emailController,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: l10n.forgotEmailLabel,
                hint: 'sarah@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                errorText: _emailController.text.isEmpty || _emailValid ? null : l10n.forgotInvalidEmail,
                onSubmitted: (_) => _emailValid ? _submit() : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: l10n.forgotSend,
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
            child: Text(l10n.registerBackToSignIn),
          ),
        ),
      ],
    );
  }

  Widget _confirmation(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 56, color: colors.success),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.forgotCheckInbox, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        // The address is emphasised inside the sentence. Rather than splitting
        // the copy into two fixed halves — which only works while the address
        // sits in the middle, and it doesn't in every language — the whole
        // sentence is translated as one string and the address located in it.
        Builder(builder: (context) {
          final email = _emailController.text.trim();
          final message = l10n.forgotSentTo(email);
          final start = message.indexOf(email);
          final bodyStyle = Theme.of(context).textTheme.bodyLarge;
          if (start < 0) {
            return Text(message, style: bodyStyle);
          }
          return Text.rich(
            TextSpan(
              style: bodyStyle,
              children: [
                TextSpan(text: message.substring(0, start)),
                TextSpan(
                  text: email,
                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: message.substring(start + email.length)),
              ],
            ),
          );
        }),
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
                  l10n.forgotNoMailServer,
                  style: TextStyle(color: colors.srsHard, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: l10n.registerBackToSignIn,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _submitted = false),
            child: Text(l10n.forgotUseDifferent),
          ),
        ),
      ],
    );
  }
}
