part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _DishroomGuidesFlow on _ReferenceSheetsViewState {
  Widget _buildDishroomGuideGroupPanel(
    Map<String, dynamic> data, {
    required String sectionTitle,
  }) {
    return _buildGuideCardSelectorPanel(
      panelTitle: sectionTitle,
      fieldLabel: 'Dishroom section',
      selectedCard: _selectedDishroomCard,
      onSelected: (value) {
        _selectedDishroomCard = value;
      },
      icon: Icons.local_laundry_service_outlined,
      selectorKeyPrefix: 'dishroom-guide',
      entries:
          _nestedGuideEntries(
                data,
                sectionKey: 'dishroom_guides',
                orderedGuideKeys: const [
                  'operations',
                  'chemicals',
                  'cleaning',
                  'jobs',
                  'scullery',
                ],
              )
              .map((entry) => (cardTitle: entry.cardTitle, items: entry.items))
              .toList(),
    );
  }
}
