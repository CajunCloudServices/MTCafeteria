part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _FindItemReferenceFlow on _ReferenceSheetsViewState {
  String _normalizeLockerSearchText(String value) {
    final lower = value.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final isLetter = rune >= 97 && rune <= 122;
      final isDigit = rune >= 48 && rune <= 57;
      if (isLetter || isDigit) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  Widget _buildLockerFlow(Map<String, dynamic> data) {
    // Workers usually know the item they need, not the locker number, so the
    // experience starts from search instead of a locker list.
    final lockerData =
        data['locker_inventory'] as Map<String, dynamic>? ?? const {};
    final search = _lockerSearchQuery.trim().toLowerCase();
    final normalizedSearch = _normalizeLockerSearchText(search);
    final lockerKeys =
        lockerData.keys.where((key) => int.tryParse(key) != null).toList()
          ..sort((a, b) {
            final aNum = int.tryParse(a);
            final bNum = int.tryParse(b);
            if (aNum != null && bNum != null) {
              return aNum.compareTo(bNum);
            }
            return a.compareTo(b);
          });

    final matchesByLocker = <String, List<String>>{};
    if (search.isNotEmpty) {
      for (final locker in lockerKeys) {
        final rawItems = lockerData[locker];
        final items = switch (rawItems) {
          List<dynamic> value => value.map((e) => e.toString()).toList(),
          String value => <String>[value],
          _ => const <String>[],
        };
        final filteredItems = items.where((item) {
          final lowerItem = item.toLowerCase();
          if (lowerItem.contains(search)) return true;
          if (normalizedSearch.isEmpty) return false;
          return _normalizeLockerSearchText(
            lowerItem,
          ).contains(normalizedSearch);
        }).toList();
        if (filteredItems.isNotEmpty) {
          matchesByLocker[locker] = filteredItems;
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
            hintText: 'Example: meat shop, hard boiled eggs, ice cream',
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
          onChanged: (value) =>
              _updateReferenceState(() => _lockerSearchQuery = value),
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

    return _buildReferencePanel(title: 'Find an Item', child: searchBody);
  }
}
