part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _MiscReferenceGroupFlow on _ReferenceSheetsViewState {
  Widget _buildGenericGuideGroupPanel(
    Map<String, dynamic> data, {
    required String sectionKey,
    required String sectionTitle,
    required String selectedCard,
    required String fieldLabel,
    required void Function(String value) onSelected,
    required IconData icon,
  }) {
    final section = data[sectionKey] as Map<String, dynamic>? ?? const {};
    return _buildGuideCardSelectorPanel(
      panelTitle: '',
      fieldLabel: fieldLabel,
      selectedCard: selectedCard,
      onSelected: onSelected,
      icon: icon,
      selectorKeyPrefix: sectionKey,
      entries: _guideCardsFromMap(section)
          .map((card) {
            final title = _guideCardTitle(card);
            final key = _guideOverrideKey(
              topSection: sectionTitle,
              guideKey: sectionKey,
              cardTitle: title,
            );
            return (
              cardTitle: title,
              items: _guideItemsForKey(key, _guideCardItems(card)),
            );
          })
          .where((entry) => entry.cardTitle.isNotEmpty)
          .toList(),
    );
  }
}
