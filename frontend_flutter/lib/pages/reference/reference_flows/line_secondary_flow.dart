part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _LineSecondaryReferenceFlow on _ReferenceSheetsViewState {
  List<String> _currentLineSecondaryItems(Map<String, dynamic> data) {
    final general =
        data['general_reference'] as Map<String, dynamic>? ?? const {};
    final sec =
        general['line_secondary_jobs'] as Map<String, dynamic>? ?? const {};
    final check =
        general['lead_supervisor_checkoff'] as Map<String, dynamic>? ??
        const {};
    final shiftSpecific =
        sec['shift_specific_secondaries'] as Map<String, dynamic>? ?? const {};
    final mealKey = _lineSecondaryMeal.toLowerCase();

    final whileOpen =
        ((sec['while_doors_are_open'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final afterClose =
        ((sec['after_doors_closed'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final mealSpecific =
        ((shiftSpecific[mealKey] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final supervisor =
        ((check['supervisor_checkoff'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final trainer =
        ((check['lead_trainer_checkoff'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();

    return switch (_lineSecondaryGroup) {
      'While Doors Open' => whileOpen,
      'After Doors Close' => afterClose,
      'Shift-Specific' => mealSpecific,
      'Supervisor Checkoff' => supervisor,
      'Lead Trainer Checkoff' => trainer,
      _ => const <String>[],
    };
  }

  Widget _buildLineSecondaryFlow(Map<String, dynamic> data) {
    final selectedLines = _currentLineSecondaryItems(data);
    final overrideKey = _guideOverrideKey(
      topSection: 'Line',
      guideKey: 'line_secondary',
      cardTitle: [_lineSecondaryMeal, _lineSecondaryGroup].join('_'),
    );
    final effectiveLines = _guideItemsForKey(
      overrideKey,
      selectedLines.isEmpty
          ? const ['No items listed for this selection.']
          : selectedLines,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lineSecondaryStep == 0)
          _buildGuideSelectionList(
            title: 'Select Meal',
            options: [
              (
                label: 'Breakfast',
                subtitle: null,
                icon: Icons.bakery_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryMeal = 'Breakfast';
                    _lineSecondaryStep = 1;
                  });
                },
              ),
              (
                label: 'Lunch',
                subtitle: null,
                icon: Icons.lunch_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryMeal = 'Lunch';
                    _lineSecondaryStep = 1;
                  });
                },
              ),
              (
                label: 'Dinner',
                subtitle: null,
                icon: Icons.restaurant_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryMeal = 'Dinner';
                    _lineSecondaryStep = 1;
                  });
                },
              ),
            ],
            backLabel: 'Back to Line Guides',
            onBack: () {
              _updateReferenceState(() {
                _selectedLineGuideSection = 'Select';
                _lineSecondaryStep = 0;
              });
            },
          )
        else if (_lineSecondaryStep == 1)
          _buildGuideSelectionList(
            title: 'Select Section',
            options: [
              (
                label: 'While Doors Open',
                subtitle: null,
                icon: Icons.door_front_door_outlined,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryGroup = 'While Doors Open';
                    _lineSecondaryStep = 2;
                  });
                },
              ),
              (
                label: 'After Doors Close',
                subtitle: null,
                icon: Icons.nightlight_round_outlined,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryGroup = 'After Doors Close';
                    _lineSecondaryStep = 2;
                  });
                },
              ),
              (
                label: 'Shift-Specific',
                subtitle: _lineSecondaryMeal,
                icon: Icons.event_repeat_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryGroup = 'Shift-Specific';
                    _lineSecondaryStep = 2;
                  });
                },
              ),
              (
                label: 'Supervisor Checkoff',
                subtitle: null,
                icon: Icons.fact_check_outlined,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryGroup = 'Supervisor Checkoff';
                    _lineSecondaryStep = 2;
                  });
                },
              ),
              (
                label: 'Lead Trainer Checkoff',
                subtitle: null,
                icon: Icons.assignment_turned_in_outlined,
                onTap: () {
                  _updateReferenceState(() {
                    _lineSecondaryGroup = 'Lead Trainer Checkoff';
                    _lineSecondaryStep = 2;
                  });
                },
              ),
            ],
            backLabel: 'Back to Meal',
            onBack: () {
              _updateReferenceState(() {
                _lineSecondaryStep = 0;
              });
            },
          )
        else
          _buildGuideContentScreen(
            backLabel: 'Back to Section',
            onBack: () {
              _updateReferenceState(() {
                _lineSecondaryStep = 1;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildReferenceSummaryChip(_lineSecondaryMeal),
                    _buildReferenceSummaryChip(_lineSecondaryGroup),
                  ],
                ),
                const SizedBox(height: 10),
                _buildReferenceTaskCard(
                  title: _lineSecondaryGroup,
                  items: effectiveLines,
                  icon: _lineSecondaryGroup.contains('Checkoff')
                      ? Icons.fact_check_outlined
                      : Icons.checklist_rtl_outlined,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
