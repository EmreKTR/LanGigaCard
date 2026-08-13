import 'package:flutter/material.dart';
import '../data/pronunciation_service.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

/// Small colored pill showing whether a card is Mastered / Learning /
/// Review Due.
class MemoryStrengthPill extends StatelessWidget {
  const MemoryStrengthPill({super.key, required this.strength});

  final MemoryStrength strength;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = strength.color(colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(strength.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

/// Small orange/red streak badge ("⚡14") shown next to the user's avatar.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days, this.size = 24});

  final int days;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: size,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors.streakGradient),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [BoxShadow(color: colors.streakEnd.withValues(alpha: 0.45), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 2),
          Text('$days', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Speaker button next to a card word: reads the word aloud using the
/// device's own text-to-speech engine.
///
/// Pass [text] to make it speak. Without it the button renders disabled
/// rather than looking tappable and doing nothing.
class SpeakerButton extends StatefulWidget {
  const SpeakerButton({
    super.key,
    this.text,
    this.languageCode,
    this.languageName,
    this.size = 40,
  });

  /// The word to pronounce. Null means there is nothing to say.
  final String? text;

  /// Two-letter language code for the word. Falls back to the learner's
  /// target language when omitted.
  final String? languageCode;

  /// Used to name the language in the "voice not installed" message.
  final String? languageName;

  final double size;

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton> {
  bool _speaking = false;

  Future<void> _speak() async {
    final text = widget.text;
    if (text == null || text.isEmpty || _speaking) return;

    setState(() => _speaking = true);
    final result = await PronunciationService.speak(
      text,
      languageCode: widget.languageCode,
      languageName: widget.languageName,
    );
    if (!mounted) return;
    setState(() => _speaking = false);

    // A phone that has never used the language simply has no voice for it,
    // which is worth saying out loud instead of appearing broken.
    final message = switch (result.outcome) {
      PronunciationOutcome.spoke => null,
      PronunciationOutcome.languageMissing => result.language == null
          ? "This language's voice isn't installed on your device yet."
          : "${result.language} speech isn't installed on your device yet. "
              'Add it in your system text-to-speech settings.',
      PronunciationOutcome.unavailable => "This device doesn't have a text-to-speech engine available.",
    };
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = widget.text != null && widget.text!.isNotEmpty;

    return Tooltip(
      message: enabled ? 'Play pronunciation' : 'Nothing to pronounce',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.text == null ? 'Play pronunciation' : 'Play pronunciation of ${widget.text}',
        child: InkWell(
          onTap: enabled ? _speak : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _speaking ? colors.primary.withValues(alpha: 0.18) : colors.surfaceElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _speaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                  color: enabled ? colors.primary : colors.textMuted,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small circular badge with a 2-letter language code (e.g. "GB", "FR"),
/// used instead of bundling real flag image assets.
class LanguageBadge extends StatelessWidget {
  const LanguageBadge({super.key, required this.code, this.size = 36});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.surfaceElevated, shape: BoxShape.circle, border: Border.all(color: colors.border)),
      child: Text(code, style: TextStyle(fontWeight: FontWeight.w700, fontSize: size * 0.32, color: colors.textPrimary)),
    );
  }
}
