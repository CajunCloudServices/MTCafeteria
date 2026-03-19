part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _CondimentsRotationReferenceFlow on _ReferenceSheetsViewState {
  Widget _buildCondimentsRotationFlow(Map<String, dynamic> data) {
    // This is reference-only. The stepped flow narrows the visible condiment
    // list without implying that workers are "completing" anything.
    final rotation =
        data['condiments_rotation'] as Map<String, dynamic>? ?? const {};
    final colorMap =
        rotation[_selectedCondimentColor] as Map<String, dynamic>? ?? const {};
    final dayMap =
        colorMap[_selectedCondimentDay] as Map<String, dynamic>? ?? const {};
    final mealKey = _selectedCondimentMeal.toLowerCase();
    final condiments = ((dayMap[mealKey] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();

    return _buildReferencePanel(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_condimentStep == 0) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedCondimentColor,
              decoration: const InputDecoration(labelText: 'Week Color'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'green', child: Text('Green')),
                DropdownMenuItem(value: 'blue', child: Text('Blue')),
                DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
                DropdownMenuItem(value: 'pink', child: Text('Pink')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _updateReferenceState(() => _selectedCondimentColor = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _updateReferenceState(() => _condimentStep = 1),
                child: const Text('Next'),
              ),
            ),
          ] else if (_condimentStep == 1) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedCondimentDay,
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
                _updateReferenceState(() => _selectedCondimentDay = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _updateReferenceState(() => _condimentStep = 2),
                child: const Text('Next'),
              ),
            ),
          ] else if (_condimentStep == 2) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedCondimentMeal,
              decoration: const InputDecoration(labelText: 'Meal'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _updateReferenceState(() => _selectedCondimentMeal = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _updateReferenceState(() => _condimentStep = 3),
                child: const Text('Next'),
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReferenceSummaryChip(_toTitle(_selectedCondimentColor)),
                _buildReferenceSummaryChip(_toDayTitle(_selectedCondimentDay)),
                _buildReferenceSummaryChip(_selectedCondimentMeal),
              ],
            ),
            const SizedBox(height: 10),
            _buildReferenceTaskCard(
              title: condiments.isEmpty ? 'No Extra Condiments' : 'Put Out',
              items: condiments.isEmpty
                  ? const ['Nothing extra for this selection.']
                  : condiments,
              icon: Icons.kitchen_outlined,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _updateReferenceState(
                  () => _condimentStep = (_condimentStep - 1).clamp(0, 3),
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
