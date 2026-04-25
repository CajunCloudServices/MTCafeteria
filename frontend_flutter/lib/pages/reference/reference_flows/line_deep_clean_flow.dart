part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _LineDeepCleanReferenceFlow on _ReferenceSheetsViewState {
  Widget _buildLineDeepCleanFlow() {
    final assignment = lineDeepCleaningAssignmentFor(
      _selectedLineDeepCleanDay,
      _selectedLineDeepCleanMeal,
    );
    final overrideKey = _guideOverrideKey(
      topSection: 'Line',
      guideKey: 'line_deep_clean',
      cardTitle: [
        _selectedLineDeepCleanDay,
        _selectedLineDeepCleanMeal,
      ].join('_'),
    );
    final assignmentItems = _guideItemsForKey(
      overrideKey,
      assignment == null
          ? const ['No deep cleaning assignment found for this day and meal.']
          : <String>[assignment],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lineDeepCleanStep == 0)
          _buildGuideSelectionList(
            title: 'Select Day',
            options: [
              for (final day in const [
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday',
                'sunday',
              ])
                (
                  label: _toDayTitle(day),
                  subtitle: null,
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    _updateReferenceState(() {
                      _selectedLineDeepCleanDay = day;
                      _lineDeepCleanStep = 1;
                    });
                  },
                ),
            ],
            backLabel: 'Back to Line Guides',
            onBack: () {
              _updateReferenceState(() {
                _selectedLineGuideSection = 'Select';
                _lineDeepCleanStep = 0;
              });
            },
          )
        else if (_lineDeepCleanStep == 1)
          _buildGuideSelectionList(
            title: 'Select Meal',
            options: [
              (
                label: 'Breakfast',
                subtitle: null,
                icon: Icons.bakery_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedLineDeepCleanMeal = 'Breakfast';
                    _lineDeepCleanStep = 2;
                  });
                },
              ),
              (
                label: 'Lunch',
                subtitle: null,
                icon: Icons.lunch_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedLineDeepCleanMeal = 'Lunch';
                    _lineDeepCleanStep = 2;
                  });
                },
              ),
              (
                label: 'Dinner',
                subtitle: null,
                icon: Icons.restaurant_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedLineDeepCleanMeal = 'Dinner';
                    _lineDeepCleanStep = 2;
                  });
                },
              ),
            ],
            backLabel: 'Back to Day',
            onBack: () {
              _updateReferenceState(() {
                _lineDeepCleanStep = 0;
              });
            },
          )
        else
          _buildGuideContentScreen(
            backLabel: 'Back to Meal',
            onBack: () {
              _updateReferenceState(() {
                _lineDeepCleanStep = 1;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  items: assignmentItems,
                  icon: Icons.cleaning_services_outlined,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
