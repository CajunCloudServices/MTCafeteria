part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _LineJobsReferenceFlow on _ReferenceSheetsViewState {
  Widget _buildLineJobsFlow(Map<String, dynamic> data) {
    final jobsForMeal = _mealLineJobs[_selectedLineMeal] ?? const <String>[];
    if (_selectedLineJobKey == null && jobsForMeal.isNotEmpty) {
      _selectedLineJobKey = jobsForMeal.first;
    }
    if (_selectedLineJobKey != null &&
        !jobsForMeal.contains(_selectedLineJobKey)) {
      _selectedLineJobKey = jobsForMeal.isEmpty ? null : jobsForMeal.first;
    }

    // Line-job references mirror the real worker phases so the mental model is
    // consistent between the read-only reference and the actual shift flow.
    final selectedPhases = _selectedLineJobKey == null
        ? const <String, List<String>>{}
        : (_lineReferenceCatalog[_selectedLineMeal]?[_selectedLineJobKey!] ??
              const <String, List<String>>{});

    return _buildReferencePanel(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lineStep == 0) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedLineMeal,
              decoration: const InputDecoration(labelText: 'Meal'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _updateReferenceState(() {
                  _selectedLineMeal = value;
                  final mealJobs = _mealLineJobs[value] ?? const <String>[];
                  _selectedLineJobKey = mealJobs.isEmpty
                      ? null
                      : mealJobs.first;
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _updateReferenceState(() => _lineStep = 1),
                child: const Text('Next'),
              ),
            ),
          ] else if (_lineStep == 1) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedLineJobKey,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Job'),
              items: jobsForMeal
                  .map(
                    (job) =>
                        DropdownMenuItem<String>(value: job, child: Text(job)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                _updateReferenceState(() => _selectedLineJobKey = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedLineJobKey == null
                    ? null
                    : () => _updateReferenceState(() => _lineStep = 2),
                child: const Text('Next'),
              ),
            ),
          ] else ...[
            Text(
              '$_selectedLineMeal • ${_selectedLineJobKey ?? '-'}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A4E8A),
              ),
            ),
            const SizedBox(height: 12),
            if (selectedPhases.isEmpty)
              const Text(
                'No job notes available for this selection.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF355678),
                ),
              )
            else ...[
              if ((selectedPhases['Setup'] ?? const <String>[]).isNotEmpty) ...[
                _buildReferenceTaskCard(
                  title: 'Setup',
                  items: selectedPhases['Setup'] ?? const <String>[],
                  icon: Icons.playlist_add_check_circle_outlined,
                ),
                const SizedBox(height: 10),
              ],
              if ((selectedPhases['During Shift'] ?? const <String>[])
                  .isNotEmpty) ...[
                _buildReferenceTaskCard(
                  title: 'During Shift',
                  items: selectedPhases['During Shift'] ?? const <String>[],
                  icon: Icons.sync_alt,
                ),
                const SizedBox(height: 10),
              ],
              if ((selectedPhases['Cleanup'] ?? const <String>[]).isNotEmpty)
                _buildReferenceTaskCard(
                  title: 'Cleanup',
                  items: selectedPhases['Cleanup'] ?? const <String>[],
                  icon: Icons.cleaning_services_outlined,
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    _updateReferenceState(() => _lineStep = (_lineStep - 1).clamp(0, 2)),
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
