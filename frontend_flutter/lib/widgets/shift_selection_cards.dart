import 'package:flutter/material.dart';

import '../theme/app_ui_tokens.dart';

/// First dashboard step for choosing the worker's operating area.
class ShiftTrackSelectionCard extends StatelessWidget {
  const ShiftTrackSelectionCard({
    super.key,
    required this.availableTracks,
    required this.selectedTrack,
    required this.onTrackChanged,
    required this.onContinue,
  });

  final List<String> availableTracks;
  final String selectedTrack;
  final ValueChanged<String> onTrackChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            border: Border.all(color: AppUiTokens.shellBorder),
            boxShadow: AppUiTokens.shellShadowSoft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Area',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF123A65),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: const ValueKey('shift-area-dropdown'),
                  initialValue: selectedTrack,
                  decoration: const InputDecoration(labelText: 'Shift Area'),
                  isExpanded: true,
                  items: availableTracks
                      .map(
                        (track) => DropdownMenuItem<String>(
                          value: track,
                          child: Text(track),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onTrackChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('shift-area-continue-button'),
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Second dashboard step for choosing the worker's role within the selected
/// area.
class ShiftRoleSelectionCard extends StatelessWidget {
  const ShiftRoleSelectionCard({
    super.key,
    required this.title,
    required this.availableModes,
    required this.selectedMode,
    required this.onModeChanged,
    required this.onContinue,
  });

  final String title;
  final List<String> availableModes;
  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            border: Border.all(color: AppUiTokens.shellBorder),
            boxShadow: AppUiTokens.shellShadowSoft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF123A65),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: const ValueKey('shift-role-dropdown'),
                  initialValue: selectedMode,
                  decoration: const InputDecoration(labelText: 'Role'),
                  isExpanded: true,
                  items: availableModes
                      .map(
                        (mode) => DropdownMenuItem<String>(
                          value: mode,
                          child: Text(
                            mode == 'Employee' ? 'Line Worker' : mode,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onModeChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('shift-area-continue-button'),
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
