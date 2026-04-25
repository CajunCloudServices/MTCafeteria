part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _LineJobsReferenceFlow on _ReferenceSheetsViewState {
  Widget _buildLineJobsFlow(Map<String, dynamic> data) {
    final jobsForMeal = availableLineJobsForMeal(_selectedLineMeal);
    if (_selectedLineJobKey != null &&
        !jobsForMeal.contains(_selectedLineJobKey)) {
      _selectedLineJobKey = null;
    }

    final selectedPhases = _selectedLineJobKey == null
        ? const <String, List<String>>{}
        : (_lineReferenceCatalog[_selectedLineMeal]?[_selectedLineJobKey!] ??
              const <String, List<String>>{});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lineStep == 0)
          _buildGuideSelectionList(
            title: 'Select Meal',
            options: [
              (
                label: 'Breakfast',
                subtitle: null,
                icon: Icons.bakery_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedLineMeal = 'Breakfast';
                    _selectedLineJobKey = null;
                    _lineStep = 1;
                  });
                },
              ),
              (
                label: 'Lunch',
                subtitle: null,
                icon: Icons.lunch_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedLineMeal = 'Lunch';
                    _selectedLineJobKey = null;
                    _lineStep = 1;
                  });
                },
              ),
              (
                label: 'Dinner',
                subtitle: null,
                icon: Icons.restaurant_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedLineMeal = 'Dinner';
                    _selectedLineJobKey = null;
                    _lineStep = 1;
                  });
                },
              ),
            ],
            backLabel: 'Back to Line Guides',
            onBack: () {
              _updateReferenceState(() {
                _selectedLineGuideSection = 'Select';
                _lineStep = 0;
                _selectedLineJobKey = null;
              });
            },
          )
        else if (_lineStep == 1)
          _buildGuideSelectionList(
            title: 'Select Job',
            options: [
              for (final job in jobsForMeal)
                (
                  label: job,
                  subtitle: _selectedLineMeal,
                  icon: Icons.work_outline_rounded,
                  onTap: () {
                    _updateReferenceState(() {
                      _selectedLineJobKey = job;
                      _lineStep = 2;
                    });
                  },
                ),
            ],
            backLabel: 'Back to Meal',
            onBack: () {
              _updateReferenceState(() {
                _lineStep = 0;
                _selectedLineJobKey = null;
              });
            },
          )
        else
          _buildGuideContentScreen(
            backLabel: 'Back to Jobs',
            onBack: () {
              _updateReferenceState(() {
                _lineStep = 1;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildReferenceSummaryChip(_selectedLineMeal),
                    if (_selectedLineJobKey != null)
                      _buildReferenceSummaryChip(_selectedLineJobKey!),
                  ],
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
              ],
            ),
          ),
      ],
    );
  }
}
