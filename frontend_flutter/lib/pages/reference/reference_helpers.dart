part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _ReferenceHelpers on _ReferenceSheetsViewState {
  List<Map<String, dynamic>> _lineMiscCards(Map<String, dynamic> data) {
    final section =
        data['line_misc_guides'] as Map<String, dynamic>? ?? const {};
    return _guideCardsFromMap(section)
        .where(
          (card) => _guideCardTitle(card) != 'Line Deep Cleaning Assignments',
        )
        .toList();
  }

  List<Map<String, dynamic>> _guideCardsFromMap(Map<String, dynamic> source) {
    return (source['cards'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  String _guideCardTitle(Map<String, dynamic> card) {
    return card['title']?.toString().trim() ?? '';
  }

  List<String> _guideCardItems(Map<String, dynamic> card) {
    return ((card['items'] as List<dynamic>?) ?? const [])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<({String guideKey, String cardTitle, List<String> items})>
  _nestedGuideEntries(
    Map<String, dynamic> data, {
    required String topSection,
    required String sectionKey,
    required List<String> orderedGuideKeys,
  }) {
    final section = data[sectionKey] as Map<String, dynamic>? ?? const {};
    final entries =
        <({String guideKey, String cardTitle, List<String> items})>[];

    for (final guideKey in orderedGuideKeys) {
      final guide = section[guideKey] as Map<String, dynamic>? ?? const {};
      for (final card in _guideCardsFromMap(guide)) {
        final title = _guideCardTitle(card);
        if (title.isEmpty) continue;
        final key = _guideOverrideKey(
          topSection: topSection,
          guideKey: guideKey,
          cardTitle: title,
        );
        entries.add((
          guideKey: guideKey,
          cardTitle: title,
          items: _guideItemsForKey(key, _guideCardItems(card)),
        ));
      }
    }

    return entries;
  }

  List<String>? _guideCardItemsForSection(
    Map<String, dynamic> data, {
    required String sectionKey,
    required String cardTitle,
    required String topSection,
  }) {
    final section = data[sectionKey] as Map<String, dynamic>? ?? const {};
    for (final card in _guideCardsFromMap(section)) {
      final title = _guideCardTitle(card);
      if (title != cardTitle) continue;
      final key = _guideOverrideKey(
        topSection: topSection,
        guideKey: sectionKey,
        cardTitle: title,
      );
      return _guideItemsForKey(key, _guideCardItems(card));
    }
    return null;
  }

  Widget _buildGuideCardSelectorPanel({
    required String panelTitle,
    required String fieldLabel,
    required String selectedCard,
    required void Function(String value) onSelected,
    required IconData icon,
    required List<({String cardTitle, List<String> items})> entries,
    required String selectorKeyPrefix,
  }) {
    final cardTitles = entries.map((entry) => entry.cardTitle).toList();
    final selectedCardTitle = cardTitles.contains(selectedCard)
        ? selectedCard
        : 'Select';
    final entry = entries.cast<dynamic>().firstWhere(
      (candidate) => candidate.cardTitle == selectedCardTitle,
      orElse: () => null,
    );
    final items = entry == null
        ? const <String>[]
        : entry.items as List<String>;

    return _buildReferencePanel(
      title: panelTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('$selectorKeyPrefix-$selectedCardTitle'),
            initialValue: selectedCardTitle,
            decoration: InputDecoration(labelText: fieldLabel),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: 'Select',
                child: Text('Select'),
              ),
              ...cardTitles.map(
                (title) =>
                    DropdownMenuItem<String>(value: title, child: Text(title)),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _updateReferenceState(() {
                onSelected(value);
              });
            },
          ),
          const SizedBox(height: 14),
          if (selectedCardTitle != 'Select')
            _buildReferenceTaskCard(
              title: selectedCardTitle,
              items: items,
              icon: icon,
            ),
        ],
      ),
    );
  }

  List<
    ({String title, String location, List<String> items, VoidCallback onOpen})
  >
  _buildGuideSearchEntries(Map<String, dynamic> data) {
    final entries =
        <
          ({
            String title,
            String location,
            List<String> items,
            VoidCallback onOpen,
          })
        >[];

    void addCardSection({
      required String topSection,
      required String sectionKey,
      required String locationLabel,
      required void Function(String title) selectCard,
      List<String>? subsectionKeys,
    }) {
      final groups = subsectionKeys == null
          ? _guideCardsFromMap(
              data[sectionKey] as Map<String, dynamic>? ?? const {},
            ).map((card) => (guideKey: sectionKey, card: card))
          : _nestedGuideEntries(
              data,
              topSection: topSection,
              sectionKey: sectionKey,
              orderedGuideKeys: subsectionKeys,
            ).map(
              (entry) => (
                guideKey: entry.guideKey,
                card: <String, dynamic>{
                  'title': entry.cardTitle,
                  'items': entry.items,
                },
              ),
            );

      for (final group in groups) {
        final title = _guideCardTitle(group.card);
        if (title.isEmpty) continue;
        final key = _guideOverrideKey(
          topSection: topSection,
          guideKey: group.guideKey,
          cardTitle: title,
        );
        final items = _guideItemsForKey(key, _guideCardItems(group.card));
        entries.add((
          title: title,
          location: locationLabel,
          items: items,
          onOpen: () {
            _guideSearchController.clear();
            _updateReferenceState(() {
              _guideSearchQuery = '';
              _selectedSection = topSection;
              selectCard(title);
            });
          },
        ));
      }
    }

    void addLineSection({required String title, required List<String> items}) {
      entries.add((
        title: title,
        location: 'Line',
        items: items,
        onOpen: () {
          _guideSearchController.clear();
          _updateReferenceState(() {
            _guideSearchQuery = '';
            _selectedSection = 'Line';
            _selectedLineGuideSection = title;
          });
        },
      ));
    }

    addLineSection(title: 'Aloha + Choices', items: _extractAlohaChoices(data));
    addLineSection(
      title: 'Condiments Rotation',
      items: _extractCondiments(data),
    );
    addLineSection(
      title: 'Deep Cleaning Assignments',
      items: flattenLineDeepCleaningAssignments(),
    );
    addLineSection(
      title: 'Secondary + Checkoff',
      items: _extractSecondaryAndCheckoff(data),
    );
    addLineSection(
      title: 'Misc',
      items: _extractCardsAsLines(_lineMiscCards(data)),
    );
    if (!_runtimeConfig.isPilotProfile) {
      addLineSection(
        title: 'Fruit Prep (Grapes/Kiwi)',
        items: _extractFoodPrep(data),
      );
      addLineSection(title: 'Meal Door Times', items: _extractMealTimes(data));
      addLineSection(title: 'Food Safety', items: _extractSafety(data));
    }

    addCardSection(
      topSection: 'Dishroom',
      sectionKey: 'dishroom_guides',
      locationLabel: 'Dishroom',
      selectCard: (title) => _selectedDishroomCard = title,
      subsectionKeys: const [
        'operations',
        'chemicals',
        'cleaning',
        'jobs',
        'scullery',
      ],
    );
    addCardSection(
      topSection: 'Kitchen',
      sectionKey: 'kitchen_guides',
      locationLabel: 'Kitchen',
      selectCard: (title) => _selectedKitchenCard = title,
      subsectionKeys: const ['salad_deli', 'desserts_fruit', 'weekend_setup'],
    );
    addCardSection(
      topSection: 'Night Custodial',
      sectionKey: 'night_custodial_guides',
      locationLabel: 'Night Custodial',
      selectCard: (title) => _selectedNightCustodialCard = title,
      subsectionKeys: const [
        'dishroom_scullery',
        'floors',
        'equipment',
        'stations',
      ],
    );
    addCardSection(
      topSection: 'Safety',
      sectionKey: 'safety_guides',
      locationLabel: 'Safety',
      selectCard: (title) => _selectedSafetyCard = title,
    );
    addCardSection(
      topSection: 'General Information',
      sectionKey: 'general_information_guides',
      locationLabel: 'General Information',
      selectCard: (title) => _selectedGeneralInformationCard = title,
    );

    return entries;
  }

  String _normalizeGuideSearch(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  String _toTitle(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }

  String _toDayTitle(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  String _stripRedundantGuideBullet(String value) {
    return value.replaceFirst(RegExp(r'^\s*[-•]\s+'), '').trim();
  }

  Widget _buildReadableLines(List<String> lines) {
    // Convert plain text lines into a readable hierarchy so the source JSON can
    // stay simple while the UI still looks intentional.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) ...[
          if (line.isEmpty)
            const SizedBox(height: 8)
          else if (line.endsWith(':'))
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Text(
                line,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123A65),
                ),
              ),
            )
          else if (line.startsWith('- '))
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '- ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(child: Text(line.substring(2))),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(line),
            ),
        ],
      ],
    );
  }

  Widget _buildReferencePanel({required String title, required Widget child}) {
    final hasTitle = title.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppUiTokens.panelSurface,
        borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
        border: Border.all(color: AppUiTokens.shellBorderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF123A65),
              ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildReferenceTaskCard({
    required String title,
    required List<String> items,
    IconData icon = Icons.task_alt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
        border: Border.all(color: AppUiTokens.shellBorder),
        boxShadow: AppUiTokens.cardShadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1A4E8A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF123A65),
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 7,
                    width: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A4E8A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _stripRedundantGuideBullet(item),
                      style: const TextStyle(
                        color: Color(0xFF244668),
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceSummaryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(AppUiTokens.chipRadius),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A4E8A),
        ),
      ),
    );
  }

  Widget _buildGuideSearchPanel(Map<String, dynamic> data) {
    final query = _normalizeGuideSearch(_guideSearchQuery);
    final results =
        _buildGuideSearchEntries(data).where((entry) {
          final titleText = _normalizeGuideSearch(entry.title);
          if (titleText.contains(query)) return true;
          final locationText = _normalizeGuideSearch(entry.location);
          if (locationText.contains(query)) return true;
          return entry.items.any(
            (line) => _normalizeGuideSearch(line).contains(query),
          );
        }).toList()..sort((a, b) {
          final aTitle = _normalizeGuideSearch(a.title).contains(query) ? 0 : 1;
          final bTitle = _normalizeGuideSearch(b.title).contains(query) ? 0 : 1;
          if (aTitle != bTitle) return aTitle.compareTo(bTitle);
          return a.title.compareTo(b.title);
        });

    return _buildReferencePanel(
      title: 'Search Results',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (results.isEmpty)
            const Text(
              'No guide matches found.',
              style: TextStyle(
                color: Color(0xFF244668),
                fontSize: 16,
                height: 1.35,
              ),
            )
          else
            ...results.map((entry) {
              final matchedLines = entry.items
                  .where((line) => _normalizeGuideSearch(line).contains(query))
                  .take(6)
                  .toList();
              final previewItems = matchedLines.isNotEmpty
                  ? matchedLines
                  : entry.items.take(4).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
                    border: Border.all(color: const Color(0xFFB6C9E4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF123A65),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildReferenceSummaryChip(entry.location),
                      const SizedBox(height: 10),
                      ...previewItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                height: 7,
                                width: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A4E8A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Color(0xFF244668),
                                    fontSize: 16,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: entry.onOpen,
                          child: const Text('Open'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
