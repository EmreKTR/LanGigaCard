import 'package:flutter/material.dart';
import '../../data/api/user_api.dart';
import '../../data/api/vocabgrid_user_api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';

/// "Change password" from Privacy & Security — verifies the current
/// password server-side before setting the new one.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _submitting = false;
  String? _currentError;
  String? _newError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _currentError = null;
      _newError = _newController.text.length < 8 ? l10n.registerPasswordTooShort : null;
    });
    if (_newError != null) return;

    setState(() => _submitting = true);
    final result = await userApi.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (!mounted) return;

    switch (result.outcome) {
      case PasswordChangeOutcome.success:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.changePasswordSuccess)));
        Navigator.of(context).pop();
      case PasswordChangeOutcome.incorrectCurrentPassword:
        setState(() {
          _submitting = false;
          _currentError = l10n.changePasswordIncorrectCurrent;
        });
      case PasswordChangeOutcome.validationError:
        setState(() {
          _submitting = false;
          _newError = result.message ?? l10n.commonSomethingWrong;
        });
      case PasswordChangeOutcome.networkError:
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonNetworkError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyChangePassword)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: l10n.changePasswordCurrentLabel,
                obscureText: true,
                controller: _currentController,
                errorText: _currentError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.changePasswordNewLabel,
                hint: l10n.registerPasswordHint,
                obscureText: true,
                controller: _newController,
                errorText: _newError,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: l10n.commonSave, loading: _submitting, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
