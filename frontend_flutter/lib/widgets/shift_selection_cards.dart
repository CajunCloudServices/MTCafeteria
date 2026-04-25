import 'package:flutter/material.dart';

import 'ui/stitch_selection_screen.dart';

IconData _iconForTrack(String track) {
  switch (track) {
    case 'Line':
      return Icons.lunch_dining_rounded;
    case 'Dishroom':
      return Icons.water_drop_rounded;
    case 'Kitchen Jobs':
      return Icons.kitchen_rounded;
    case 'Night Custodial':
      return Icons.cleaning_services_rounded;
    default:
      return Icons.work_outline_rounded;
  }
}

IconData _iconForMode(String mode) {
  switch (mode) {
    case 'Supervisor':
      return Icons.badge_outlined;
    case 'Lead Trainer':
    case 'Dishroom Lead Trainer':
      return Icons.school_outlined;
    case 'Employee':
    case 'Dishroom Worker':
      return Icons.person_outline_rounded;
    default:
      return Icons.work_outline_rounded;
  }
}

String _labelForMode(String mode) => mode == 'Employee' ? 'Line Worker' : mode;

int _modePriority(String mode) {
  switch (mode) {
    case 'Employee':
    case 'Dishroom Worker':
      return 0;
    case 'Lead Trainer':
    case 'Dishroom Lead Trainer':
      return 1;
    case 'Supervisor':
      return 2;
    default:
      return 3;
  }
}

/// Step 1 of the shift flow: pick the operating area.
class ShiftTrackSelectionCard extends StatelessWidget {
  const ShiftTrackSelectionCard({
    super.key,
    required this.availableTracks,
    required this.selectedTrack,
    required this.onTrackChanged,
  });

  final List<String> availableTracks;
  final String selectedTrack;
  final ValueChanged<String> onTrackChanged;

  @override
  Widget build(BuildContext context) {
    return StitchSelectionScreen(
      title: 'Select Area',
      options: [
        for (final track in availableTracks)
          StitchSelectionOption(
            rowKey: ValueKey('shift-area-row-$track'),
            label: track,
            icon: _iconForTrack(track),
            selected: selectedTrack == track,
            onTap: () => onTrackChanged(track),
          ),
      ],
    );
  }
}

/// Step 2 of the shift flow: pick the role within the chosen area.
class ShiftRoleSelectionCard extends StatelessWidget {
  const ShiftRoleSelectionCard({
    super.key,
    required this.title,
    required this.availableModes,
    required this.selectedMode,
    required this.onModeChanged,
  });

  final String title;
  final List<String> availableModes;
  final String selectedMode;
  final ValueChanged<String> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final orderedModes = [...availableModes]
      ..sort((a, b) {
        final priorityCompare = _modePriority(a).compareTo(_modePriority(b));
        if (priorityCompare != 0) return priorityCompare;
        return _labelForMode(a).compareTo(_labelForMode(b));
      });

    return StitchSelectionScreen(
      title: title,
      options: [
        for (final mode in orderedModes)
          StitchSelectionOption(
            rowKey: ValueKey('shift-role-row-$mode'),
            label: _labelForMode(mode),
            icon: _iconForMode(mode),
            selected: selectedMode == mode,
            onTap: () => onModeChanged(mode),
          ),
      ],
    );
  }
}
