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
        if (_lineSecondaryStep == 0) ...[
          DropdownButtonFormField<String>(
            initialValue: _lineSecondaryMeal,
            decoration: const InputDecoration(labelText: 'Meal'),
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
              DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
              DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
            ],
            onChanged: (value) {
              if (value == null) return;
              _updateReferenceState(() => _lineSecondaryMeal = value);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  _updateReferenceState(() => _lineSecondaryStep = 1),
              child: const Text('Next'),
            ),
          ),
        ] else if (_lineSecondaryStep == 1) ...[
          DropdownButtonFormField<String>(
            initialValue: _lineSecondaryGroup,
            decoration: const InputDecoration(labelText: 'Section'),
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: 'While Doors Open',
                child: Text('While Doors Open'),
              ),
              DropdownMenuItem(
                value: 'After Doors Close',
                child: Text('After Doors Close'),
              ),
              DropdownMenuItem(
                value: 'Shift-Specific',
                child: Text('Shift-Specific'),
              ),
              DropdownMenuItem(
                value: 'Supervisor Checkoff',
                child: Text('Supervisor Checkoff'),
              ),
              DropdownMenuItem(
                value: 'Lead Trainer Checkoff',
                child: Text('Lead Trainer Checkoff'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _updateReferenceState(() => _lineSecondaryGroup = value);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  _updateReferenceState(() => _lineSecondaryStep = 2),
              child: const Text('Next'),
            ),
          ),
        ] else ...[
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _updateReferenceState(
                () => _lineSecondaryStep = (_lineSecondaryStep - 1).clamp(0, 2),
              ),
              child: const Text('Back'),
            ),
          ),
        ],
      ],
    );
  }
}
