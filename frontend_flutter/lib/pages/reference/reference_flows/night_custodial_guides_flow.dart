part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _NightCustodialGuidesFlow on _ReferenceSheetsViewState {
  Widget _buildNightCustodialGuideGroupPanel(
    Map<String, dynamic> data, {
    required String sectionTitle,
  }) {
    return _buildGuideCardSelectorPanel(
      panelTitle: '',
      fieldLabel: 'Night Custodial section',
      selectedCard: _selectedNightCustodialCard,
      onSelected: (value) {
        _selectedNightCustodialCard = value;
      },
      icon: Icons.cleaning_services_outlined,
      selectorKeyPrefix: 'night-custodial-guide',
      entries:
          _nestedGuideEntries(
                data,
                topSection: 'Night Custodial',
                sectionKey: 'night_custodial_guides',
                orderedGuideKeys: const [
                  'dishroom_scullery',
                  'floors',
                  'equipment',
                  'stations',
                ],
              )
              .map((entry) => (cardTitle: entry.cardTitle, items: entry.items))
              .toList(),
    );
  }
}
