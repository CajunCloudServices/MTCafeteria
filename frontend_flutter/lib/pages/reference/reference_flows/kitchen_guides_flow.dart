part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _KitchenGuidesFlow on _ReferenceSheetsViewState {
  Widget _buildKitchenGuideGroupPanel(
    Map<String, dynamic> data, {
    required String sectionTitle,
  }) {
    return _buildGuideCardSelectorPanel(
      panelTitle: '',
      fieldLabel: 'Kitchen section',
      selectedCard: _selectedKitchenCard,
      onSelected: (value) {
        _selectedKitchenCard = value;
      },
      icon: Icons.restaurant_menu_outlined,
      selectorKeyPrefix: 'kitchen-guide',
      entries:
          _nestedGuideEntries(
                data,
                sectionKey: 'kitchen_guides',
                orderedGuideKeys: const [
                  'salad_deli',
                  'desserts_fruit',
                  'weekend_setup',
                ],
              )
              .map((entry) => (cardTitle: entry.cardTitle, items: entry.items))
              .toList(),
    );
  }
}
