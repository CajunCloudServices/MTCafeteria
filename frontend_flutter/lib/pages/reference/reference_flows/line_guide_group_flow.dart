part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _LineGuideGroupFlow on _ReferenceSheetsViewState {
  List<String> _lineGuideOptions() {
    return <String>[
      'Jobs',
      'Aloha + Choices',
      'Condiments Rotation',
      'Deep Cleaning Assignments',
      'Secondary + Checkoff',
      'Misc',
      'Fruit Prep (Grapes/Kiwi)',
      'Meal Door Times',
      'Food Safety',
    ];
  }

  Widget _buildLineGuideGroupPanel(Map<String, dynamic> data) {
    final options = _lineGuideOptions();
    final selected = options.contains(_selectedLineGuideSection)
        ? _selectedLineGuideSection
        : 'Select';

    if (selected == 'Select') {
      return _buildGuideSelectionList(
        title: 'Line Guides',
        options: [
          for (final option in options)
            (
              label: option,
              subtitle: null,
              icon: Icons.menu_book_outlined,
              onTap: () {
                _updateReferenceState(() {
                  _selectedLineGuideSection = option;
                });
              },
            ),
        ],
      );
    }

    Widget child;
    switch (selected) {
      case 'Jobs':
        child = _buildLineJobsFlow(data);
      case 'Aloha + Choices':
        child = _buildAlohaChoicesPanel(data);
      case 'Condiments Rotation':
        child = _buildCondimentsRotationFlow(data);
      case 'Deep Cleaning Assignments':
        child = _buildLineDeepCleanFlow();
      case 'Secondary + Checkoff':
        child = _buildLineSecondaryFlow(data);
      case 'Misc':
        final cards = _lineMiscCards(data);
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final card in cards) ...[
              _buildReferenceTaskCard(
                title: _guideCardTitle(card).isEmpty
                    ? 'Line Misc'
                    : _guideCardTitle(card),
                items: _guideCardItems(card),
                icon: Icons.layers_outlined,
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      case 'Fruit Prep (Grapes/Kiwi)':
        child = StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.lg),
          elevation: StitchCardElevation.subtle,
          ring: true,
          child: _buildReadableLines(_extractFoodPrep(data)),
        );
      case 'Meal Door Times':
        child = StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.lg),
          elevation: StitchCardElevation.subtle,
          ring: true,
          child: _buildReadableLines(_extractMealTimes(data)),
        );
      case 'Food Safety':
        child = StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.lg),
          elevation: StitchCardElevation.subtle,
          ring: true,
          child: _buildReadableLines(_extractSafety(data)),
        );
      default:
        child = const SizedBox.shrink();
    }

    return _buildGuideContentScreen(
      backLabel: 'Back to Line Guides',
      onBack: () {
        _updateReferenceState(() {
          _selectedLineGuideSection = 'Select';
        });
      },
      child: child,
    );
  }
}
