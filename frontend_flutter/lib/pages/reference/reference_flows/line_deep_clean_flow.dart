part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _LineDeepCleanReferenceFlow on _ReferenceSheetsViewState {
  Widget _buildLineDeepCleanFlow() {
    final assignment = lineDeepCleaningAssignmentFor(
      _selectedLineDeepCleanDay,
      _selectedLineDeepCleanMeal,
    );
    final assignmentItems = assignment == null ? null : [assignment];

    return _buildReferencePanel(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lineDeepCleanStep == 0) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedLineDeepCleanDay,
              decoration: const InputDecoration(labelText: 'Day'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'monday', child: Text('Monday')),
                DropdownMenuItem(value: 'tuesday', child: Text('Tuesday')),
                DropdownMenuItem(value: 'wednesday', child: Text('Wednesday')),
                DropdownMenuItem(value: 'thursday', child: Text('Thursday')),
                DropdownMenuItem(value: 'friday', child: Text('Friday')),
                DropdownMenuItem(value: 'saturday', child: Text('Saturday')),
                DropdownMenuItem(value: 'sunday', child: Text('Sunday')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _updateReferenceState(() => _selectedLineDeepCleanDay = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    _updateReferenceState(() => _lineDeepCleanStep = 1),
                child: const Text('Next'),
              ),
            ),
          ] else if (_lineDeepCleanStep == 1) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedLineDeepCleanMeal,
              decoration: const InputDecoration(labelText: 'Meal'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _updateReferenceState(() => _selectedLineDeepCleanMeal = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    _updateReferenceState(() => _lineDeepCleanStep = 2),
                child: const Text('Next'),
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReferenceSummaryChip(
                  _toDayTitle(_selectedLineDeepCleanDay),
                ),
                _buildReferenceSummaryChip(_selectedLineDeepCleanMeal),
              ],
            ),
            const SizedBox(height: 10),
            _buildReferenceTaskCard(
              title: 'Line Deep Cleaning',
              items:
                  assignmentItems ??
                  const [
                    'No deep cleaning assignment found for this day and meal.',
                  ],
              icon: Icons.cleaning_services_outlined,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _updateReferenceState(
                  () =>
                      _lineDeepCleanStep = (_lineDeepCleanStep - 1).clamp(0, 2),
                ),
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
