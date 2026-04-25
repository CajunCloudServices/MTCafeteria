import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/stitch_tokens.dart';
import 'stitch_buttons.dart';

/// One-time welcome popup shown when a tester first lands on the dashboard.
/// Explains what to do during testing and emphasizes the Send Feedback link.
///
/// Dismissal persists across launches via [SharedPreferences] so the dialog
/// never re-appears on the same device once acknowledged.
class TesterWelcomeDialog extends StatelessWidget {
  const TesterWelcomeDialog({super.key});

  static const String _prefsKey = 'tester_welcome_seen_v1';

  /// Shows the dialog exactly once per device. Safe to call on every hub
  /// build — no-ops if the flag has already been set or SharedPreferences is
  /// unavailable.
  static Future<void> maybeShow(BuildContext context) async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }
    if (prefs.getBool(_prefsKey) ?? false) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TesterWelcomeDialog(),
    );

    try {
      await prefs.setBool(_prefsKey, true);
    } on MissingPluginException {
      // No persistence available — dialog will re-show next launch.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: StitchColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchRadii.lg),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: StitchSpacing.xl,
        vertical: StitchSpacing.xl2,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 468),
        child: Padding(
          padding: const EdgeInsets.all(StitchSpacing.xl3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _WelcomeStep(
                number: '1',
                title: 'Tap Start Shift',
                body:
                    'Go to your assigned job for this shift and walk through the tasks like you would on a real shift.',
              ),
              const SizedBox(height: StitchSpacing.md),
              const _WelcomeStep(
                number: '2',
                title: 'Explore the rest of the app',
                body:
                    'Open the other features on the dashboard. See what you like, what confuses you, and what could work better.',
              ),
              const SizedBox(height: StitchSpacing.md),
              _WelcomeStep(
                number: '3',
                title: 'Leave feedback before you go',
                body: 'When you are done, tap ',
                emphasizeTrailingIcon: Icons.feedback_outlined,
                trailingText: 'Send Feedback',
                bodySuffix:
                    ' on the dashboard. That is the whole point — your notes are what make the app better.',
              ),
              const SizedBox(height: StitchSpacing.xl),
              StitchPrimaryButton(
                label: "Let's go",
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.number,
    required this.title,
    required this.body,
    this.emphasizeTrailingIcon,
    this.trailingText,
    this.bodySuffix,
  });

  final String number;
  final String title;
  final String body;
  final IconData? emphasizeTrailingIcon;
  final String? trailingText;
  final String? bodySuffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: StitchColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: StitchFonts.headline,
              fontFamilyFallback: StitchFonts.fallback,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: StitchColors.onPrimary,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: StitchSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: StitchText.titleSm),
              const SizedBox(height: 4),
              _buildBody(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (trailingText == null) {
      return Text(body, style: StitchText.bodyLg);
    }
    return Text.rich(
      TextSpan(
        style: StitchText.bodyLg,
        children: [
          TextSpan(text: body),
          if (emphasizeTrailingIcon != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  emphasizeTrailingIcon,
                  size: 16,
                  color: StitchColors.primary,
                ),
              ),
            ),
          TextSpan(
            text: trailingText,
            style: StitchText.bodyStrong.copyWith(color: StitchColors.primary),
          ),
          if (bodySuffix != null) TextSpan(text: bodySuffix),
        ],
      ),
    );
  }
}
