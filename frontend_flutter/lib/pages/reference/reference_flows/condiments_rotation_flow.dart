part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _CondimentsRotationReferenceFlow on _ReferenceSheetsViewState {
  List<String> _currentCondimentItems(Map<String, dynamic> data) {
    final rotation =
        data['condiments_rotation'] as Map<String, dynamic>? ?? const {};
    final colorMap =
        rotation[_selectedCondimentColor] as Map<String, dynamic>? ?? const {};
    final dayMap =
        colorMap[_selectedCondimentDay] as Map<String, dynamic>? ?? const {};
    final mealKey = _selectedCondimentMeal.toLowerCase();
    return ((dayMap[mealKey] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();
  }

  Widget _buildCondimentsRotationFlow(Map<String, dynamic> data) {
    final condiments = _currentCondimentItems(data);
    final overrideKey = _guideOverrideKey(
      topSection: 'Line',
      guideKey: 'condiments_rotation',
      cardTitle: [
        _selectedCondimentColor,
        _selectedCondimentDay,
        _selectedCondimentMeal,
      ].join('_'),
    );
    final effectiveItems = _guideItemsForKey(
      overrideKey,
      condiments.isEmpty
          ? const ['Nothing extra for this selection.']
          : condiments,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_condimentStep == 0)
          _buildGuideSelectionList(
            title: 'Select Week Color',
            options: [
              for (final color in const ['green', 'blue', 'yellow', 'pink'])
                (
                  label: _toTitle(color),
                  subtitle: null,
                  icon: Icons.palette_outlined,
                  onTap: () {
                    _updateReferenceState(() {
                      _selectedCondimentColor = color;
                      _condimentStep = 1;
                    });
                  },
                ),
            ],
            backLabel: 'Back to Line Guides',
            onBack: () {
              _updateReferenceState(() {
                _selectedLineGuideSection = 'Select';
                _condimentStep = 0;
              });
            },
          )
        else if (_condimentStep == 1)
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
                      _selectedCondimentDay = day;
                      _condimentStep = 2;
                    });
                  },
                ),
            ],
            backLabel: 'Back to Color',
            onBack: () {
              _updateReferenceState(() {
                _condimentStep = 0;
              });
            },
          )
        else if (_condimentStep == 2)
          _buildGuideSelectionList(
            title: 'Select Meal',
            options: [
              (
                label: 'Breakfast',
                subtitle: null,
                icon: Icons.bakery_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedCondimentMeal = 'Breakfast';
                    _condimentStep = 3;
                  });
                },
              ),
              (
                label: 'Lunch',
                subtitle: null,
                icon: Icons.lunch_dining_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedCondimentMeal = 'Lunch';
                    _condimentStep = 3;
                  });
                },
              ),
              (
                label: 'Dinner',
                subtitle: null,
                icon: Icons.restaurant_rounded,
                onTap: () {
                  _updateReferenceState(() {
                    _selectedCondimentMeal = 'Dinner';
                    _condimentStep = 3;
                  });
                },
              ),
            ],
            backLabel: 'Back to Day',
            onBack: () {
              _updateReferenceState(() {
                _condimentStep = 1;
              });
            },
          )
        else
          _buildGuideContentScreen(
            backLabel: 'Back to Meal',
            onBack: () {
              _updateReferenceState(() {
                _condimentStep = 2;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  items: effectiveItems,
                  icon: Icons.kitchen_outlined,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
