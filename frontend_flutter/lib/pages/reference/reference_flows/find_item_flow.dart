part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _FindItemReferenceFlow on _ReferenceSheetsViewState {
  Widget _buildLockerFlow(Map<String, dynamic> data) {
    // Workers usually know the item they need, not the locker number, so the
    // experience starts from search instead of a locker list.
    final lockerData =
        data['locker_inventory'] as Map<String, dynamic>? ?? const {};
    final search = _lockerSearchQuery.trim().toLowerCase();
    final lockerKeys = ['5', '6', '7', '8', '9'];

    final matchesByLocker = <String, List<String>>{};
    if (search.isNotEmpty) {
      for (final locker in lockerKeys) {
        final items = ((lockerData[locker] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .where((item) => item.toLowerCase().contains(search))
            .toList();
        if (items.isNotEmpty) {
          matchesByLocker[locker] = items;
        }
      }
    }

    final searchBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _lockerSearchController,
          decoration: InputDecoration(
            labelText: 'Find an item',
            hintText: 'Example: gloves, syrup, ranch',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _lockerSearchQuery.trim().isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () {
                      _lockerSearchController.clear();
                      _updateReferenceState(() => _lockerSearchQuery = '');
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
          onChanged: (value) => _updateReferenceState(() => _lockerSearchQuery = value),
        ),
        if (search.isNotEmpty) ...[
          const SizedBox(height: 12),
          if (matchesByLocker.isEmpty)
            Text(
              'No locker match found for "$_lockerSearchQuery".',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF123A65),
              ),
            )
          else
            ...matchesByLocker.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReferenceTaskCard(
                  title: 'Locker ${entry.key}',
                  items: entry.value,
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ),
        ],
      ],
    );

    // Locked mode (opened directly from dashboard) should match the same
    // single-card style rhythm as other locked reference surfaces.
    if (widget.lockSection) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find an Item',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          searchBody,
        ],
      );
    }

    return _buildReferencePanel(
      title: 'Find an Item',
      child: searchBody,
    );
  }
}
