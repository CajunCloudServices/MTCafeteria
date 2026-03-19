part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _FindItemReferenceFlow on _ReferenceSheetsViewState {
  Map<String, List<String>> _mergedLockerInventory(Map<String, dynamic> data) {
    final raw = data['locker_inventory'] as Map<String, dynamic>? ?? const {};
    final merged = <String, List<String>>{};

    for (final entry in raw.entries) {
      final items = switch (entry.value) {
        List<dynamic> value => value.map((e) => e.toString().trim()).toList(),
        String value => <String>[value.trim()],
        _ => const <String>[],
      };
      merged[entry.key] = items.where((item) => item.isNotEmpty).toList();
    }

    for (final entry in _customLockerInventory.entries) {
      final existing = merged[entry.key] ?? const <String>[];
      final deduped = <String>[
        ...existing,
        ...entry.value.where(
          (item) => !existing.any(
            (existingItem) => existingItem.toLowerCase() == item.toLowerCase(),
          ),
        ),
      ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      merged[entry.key] = deduped;
    }

    return merged;
  }

  List<String> _lockerLocationOptions(Map<String, List<String>> lockerData) {
    final numeric =
        lockerData.keys.where((key) => int.tryParse(key) != null).toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final named =
        lockerData.keys
            .where(
              (key) =>
                  int.tryParse(key) == null &&
                  key != 'notes' &&
                  key != 'unclear',
            )
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [...numeric, ...named];
  }

  String _lockerDisplayLabel(String location) {
    return int.tryParse(location) != null ? 'Locker $location' : location;
  }

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
    final lockerData = _mergedLockerInventory(data);
    final search = _lockerSearchQuery.trim().toLowerCase();
    final normalizedSearch = _normalizeLockerSearchText(search);
    final lockerKeys = _lockerLocationOptions(lockerData);

    final matchesByLocker = <String, List<String>>{};
    if (search.isNotEmpty) {
      for (final locker in lockerKeys) {
        final items = lockerData[locker] ?? const <String>[];
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
                  title: _lockerDisplayLabel(entry.key),
                  items: entry.value,
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB6C9E4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add an Item',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123A65),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedLockerAddLocation,
                decoration: const InputDecoration(labelText: 'Location'),
                isExpanded: true,
                items: _lockerLocationOptions(lockerData)
                    .map(
                      (location) => DropdownMenuItem<String>(
                        value: location,
                        child: Text(_lockerDisplayLabel(location)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  _updateReferenceState(() {
                    _selectedLockerAddLocation = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lockerAddItemController,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  hintText: 'Type the item to add',
                ),
                onSubmitted: (_) async {
                  final item = _lockerAddItemController.text.trim();
                  if (item.isEmpty) return;
                  await _addLockerInventoryItem(
                    location: _selectedLockerAddLocation,
                    item: item,
                  );
                  if (!mounted) return;
                  _lockerAddItemController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added "$item" to ${_lockerDisplayLabel(_selectedLockerAddLocation)}.',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final item = _lockerAddItemController.text.trim();
                    if (item.isEmpty) return;
                    await _addLockerInventoryItem(
                      location: _selectedLockerAddLocation,
                      item: item,
                    );
                    if (!mounted) return;
                    _lockerAddItemController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added "$item" to ${_lockerDisplayLabel(_selectedLockerAddLocation)}.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Add Item'),
                ),
              ),
            ],
          ),
        ),
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
