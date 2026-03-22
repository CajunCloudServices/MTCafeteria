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
      if (!_runtimeConfig.isPilotProfile) 'Fruit Prep (Grapes/Kiwi)',
      if (!_runtimeConfig.isPilotProfile) 'Meal Door Times',
      if (!_runtimeConfig.isPilotProfile) 'Food Safety',
    ];
  }

  Widget _buildLineGuideGroupPanel(Map<String, dynamic> data) {
    final options = _lineGuideOptions();
    final selected = options.contains(_selectedLineGuideSection)
        ? _selectedLineGuideSection
        : 'Select';

    Widget child;
    switch (selected) {
      case 'Select':
        child = const SizedBox.shrink();
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
        child = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            border: Border.all(color: const Color(0xFFB6C9E4)),
          ),
          child: _buildReadableLines(_extractFoodPrep(data)),
        );
      case 'Meal Door Times':
        child = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            border: Border.all(color: const Color(0xFFB6C9E4)),
          ),
          child: _buildReadableLines(_extractMealTimes(data)),
        );
      case 'Food Safety':
        child = Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            border: Border.all(color: const Color(0xFFB6C9E4)),
          ),
          child: _buildReadableLines(_extractSafety(data)),
        );
      default:
        child = const SizedBox.shrink();
    }

    return _buildReferencePanel(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('line-guide-$selected'),
            initialValue: selected,
            decoration: const InputDecoration(labelText: 'Line section'),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: 'Select',
                child: Text('Select'),
              ),
              ...options.map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _updateReferenceState(() {
                _selectedLineGuideSection = value;
              });
            },
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
