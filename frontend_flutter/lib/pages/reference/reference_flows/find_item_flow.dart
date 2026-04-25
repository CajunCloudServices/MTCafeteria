part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _FindItemReferenceFlow on _ReferenceSheetsViewState {
  static const List<String> _namedLockerLocations = <String>[
    'Basement',
    'The Cage',
    'The Cove',
  ];

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

    final filtered = <String, List<String>>{};
    for (final entry in merged.entries) {
      final deletedItems = _deletedLockerInventory[entry.key] ?? const [];
      final items = entry.value
          .where(
            (item) => !deletedItems.any(
              (deleted) => deleted.toLowerCase() == item.toLowerCase(),
            ),
          )
          .toList();
      if (items.isNotEmpty) {
        filtered[entry.key] = items;
      }
    }

    return filtered;
  }

  List<String> _lockerLocationOptions(Map<String, List<String>> lockerData) {
    final numeric =
        lockerData.keys.where((key) => int.tryParse(key) != null).toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final named = {
      ...lockerData.keys.where(
        (key) =>
            int.tryParse(key) == null && key != 'notes' && key != 'unclear',
      ),
      ..._namedLockerLocations,
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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

  Future<void> _submitLockerAdd() async {
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
  }

  Widget _buildLockerLocationSelection(Map<String, List<String>> lockerData) {
    final lockerKeys = _lockerLocationOptions(lockerData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < lockerKeys.length; index++) ...[
          StitchListRow(
            title: _lockerDisplayLabel(lockerKeys[index]),
            titleStyle: StitchText.titleSm,
            leadingIcon: Icons.inventory_2_outlined,
            onTap: () {
              _updateReferenceState(() {
                _selectedLockerLocation = lockerKeys[index];
                _selectedLockerAddLocation = lockerKeys[index];
                _showLockerAddPanel = false;
                _showLockerDeleteMode = false;
              });
            },
          ),
          if (index < lockerKeys.length - 1)
            const SizedBox(height: StitchSpacing.md),
        ],
      ],
    );
  }

  Widget _buildLockerLocationItems({
    required String location,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_lockerDisplayLabel(location), style: StitchText.titleLg),
        const SizedBox(height: StitchSpacing.sm),
        Text(
          '${items.length} ${items.length == 1 ? 'item' : 'items'}',
          style: StitchText.body.copyWith(
            color: StitchColors.onSurfaceVariant,
          ),
        ),
        if (widget.adminModeEnabled) ...[
          const SizedBox(height: StitchSpacing.lg),
          if (_showLockerAddPanel) ...[
            TextField(
              controller: _lockerAddItemController,
              decoration: const InputDecoration(
                labelText: 'Item name',
                hintText: 'Type the item to add',
              ),
              onSubmitted: (_) async => _submitLockerAdd(),
            ),
            const SizedBox(height: StitchSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StitchSecondaryButton(
                    label: 'Cancel',
                    onPressed: () {
                      _lockerAddItemController.clear();
                      _updateReferenceState(() {
                        _showLockerAddPanel = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: StitchSpacing.md),
                Expanded(
                  child: StitchPrimaryButton(
                    label: 'Add Item',
                    icon: Icons.add_rounded,
                    onPressed: _submitLockerAdd,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: StitchSecondaryButton(
                    label: 'Add',
                    icon: Icons.add_rounded,
                    onPressed: () {
                      _updateReferenceState(() {
                        _selectedLockerAddLocation = location;
                        _showLockerAddPanel = true;
                        _showLockerDeleteMode = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: StitchSpacing.md),
                Expanded(
                  child: StitchSecondaryButton(
                    label: _showLockerDeleteMode ? 'Done' : 'Delete',
                    icon: _showLockerDeleteMode
                        ? Icons.close
                        : Icons.delete_outline,
                    onPressed: () {
                      _updateReferenceState(() {
                        _showLockerDeleteMode = !_showLockerDeleteMode;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
        const SizedBox(height: StitchSpacing.lg),
        if (items.isEmpty)
          Text(
            'No items in this location.',
            style: StitchText.body.copyWith(
              color: StitchColors.onSurfaceVariant,
            ),
          )
        else
          for (var index = 0; index < items.length; index++) ...[
            StitchListRow(
              title: items[index],
              leadingIcon: Icons.inventory_2_outlined,
              trailing: _showLockerDeleteMode && widget.adminModeEnabled
                  ? GestureDetector(
                      onTap: () async {
                        await _deleteLockerInventoryItem(
                          location: location,
                          item: items[index],
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Deleted "${items[index]}" from ${_lockerDisplayLabel(location)}.',
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: StitchColors.error,
                        size: 20,
                      ),
                    )
                  : null,
            ),
            if (index < items.length - 1)
              const SizedBox(height: StitchSpacing.md),
          ],
      ],
    );
  }

  Widget _buildLockerFlow(Map<String, dynamic> data) {
    final lockerData = _mergedLockerInventory(data);
    final search = _lockerSearchQuery.trim().toLowerCase();
    final normalizedSearch = _normalizeLockerSearchText(search);
    final lockerKeys = _lockerLocationOptions(lockerData);

    final matchRows =
        <({String item, String location, VoidCallback onTap})>[];
    if (search.isNotEmpty) {
      for (final locker in lockerKeys) {
        final items = lockerData[locker] ?? const <String>[];
        for (final item in items) {
          final lowerItem = item.toLowerCase();
          final matches =
              lowerItem.contains(search) ||
              (normalizedSearch.isNotEmpty &&
                  _normalizeLockerSearchText(lowerItem).contains(
                    normalizedSearch,
                  ));
          if (!matches) continue;
          matchRows.add((
            item: item,
            location: locker,
            onTap: () {
              _updateReferenceState(() {
                _selectedLockerLocation = locker;
                _selectedLockerAddLocation = locker;
                _showLockerAddPanel = false;
                _showLockerDeleteMode = false;
              });
            },
          ));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _lockerSearchController,
          decoration: InputDecoration(
            hintText: 'Search items',
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
        const SizedBox(height: StitchSpacing.lg),
        if (search.isNotEmpty)
          if (matchRows.isEmpty)
            Text(
              'No item match found.',
              style: StitchText.body.copyWith(
                color: StitchColors.onSurfaceVariant,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < matchRows.length; index++) ...[
                  StitchListRow(
                    title: matchRows[index].item,
                    subtitle: _lockerDisplayLabel(matchRows[index].location),
                    leadingIcon: Icons.inventory_2_outlined,
                    onTap: matchRows[index].onTap,
                  ),
                  if (index < matchRows.length - 1)
                    const SizedBox(height: StitchSpacing.md),
                ],
              ],
            )
        else if (_selectedLockerLocation != 'Select')
          _buildLockerLocationItems(
            location: _selectedLockerLocation,
            items: lockerData[_selectedLockerLocation] ?? const <String>[],
          )
        else
          _buildLockerLocationSelection(lockerData),
      ],
    );
  }
}
