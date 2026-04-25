part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _ReferenceHelpers on _ReferenceSheetsViewState {
  Widget _buildGuideSelectionList({
    required String title,
    String? subtitle,
    required List<
      ({
        String label,
        String? subtitle,
        IconData icon,
        VoidCallback onTap,
      })
    >
    options,
    String? backLabel,
    VoidCallback? onBack,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.trim().isNotEmpty) Text(title, style: StitchText.titleLg),
        if (subtitle != null && subtitle.trim().isNotEmpty) ...[
          const SizedBox(height: StitchSpacing.xs),
          Text(
            subtitle,
            style: StitchText.body.copyWith(
              color: StitchColors.onSurfaceVariant,
            ),
          ),
        ],
        if (title.trim().isNotEmpty ||
            (subtitle != null && subtitle.trim().isNotEmpty))
          const SizedBox(height: StitchSpacing.lg),
        for (final option in options) ...[
          StitchListRow(
            title: option.label,
            subtitle: option.subtitle,
            leadingIcon: option.icon,
            onTap: option.onTap,
          ),
          const SizedBox(height: StitchSpacing.md),
        ],
      ],
    );
  }

  Widget _buildGuideContentScreen({
    required String backLabel,
    required VoidCallback onBack,
    required Widget child,
  }) {
    return child;
  }

  IconData _guideSectionIcon(String section) {
    switch (section) {
      case 'Line':
        return Icons.restaurant_rounded;
      case 'Dishroom':
        return Icons.local_laundry_service_outlined;
      case 'Kitchen':
        return Icons.restaurant_menu_outlined;
      case 'Night Custodial':
        return Icons.cleaning_services_outlined;
      case 'Recipes':
        return Icons.menu_book_rounded;
      case 'Safety':
        return Icons.health_and_safety_outlined;
      case 'General Information':
        return Icons.info_outline_rounded;
      default:
        return Icons.chevron_right_rounded;
    }
  }

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

    if (selectedCardTitle == 'Select') {
      final listTitle = panelTitle.trim().isNotEmpty
          ? panelTitle
          : fieldLabel.replaceFirst(RegExp(r'\s+section$', caseSensitive: false), '');
      return _buildGuideSelectionList(
        title: listTitle,
        options: [
          for (final title in cardTitles)
            (
              label: title,
              subtitle: null,
              icon: icon,
              onTap: () {
                _updateReferenceState(() {
                  onSelected(title);
                });
              },
            ),
        ],
      );
    }

    return _buildGuideContentScreen(
      backLabel: 'Back',
      onBack: () {
        _updateReferenceState(() {
          onSelected('Select');
        });
      },
      child: _buildReferenceTaskCard(
        title: selectedCardTitle,
        items: items,
        icon: icon,
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
    addLineSection(
      title: 'Fruit Prep (Grapes/Kiwi)',
      items: _extractFoodPrep(data),
    );
    addLineSection(title: 'Meal Door Times', items: _extractMealTimes(data));
    addLineSection(title: 'Food Safety', items: _extractSafety(data));

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
    final bodyStyle = StitchText.bodyLg.copyWith(
      color: StitchColors.onSurface,
      height: 1.55,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) ...[
          if (line.isEmpty)
            const SizedBox(height: 10)
          else if (line.endsWith(':'))
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Text(
                line,
                style: StitchText.titleSm.copyWith(
                  color: StitchColors.onSurface,
                ),
              ),
            )
          else if (line.startsWith('- '))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: StitchColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(line.substring(2), style: bodyStyle),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(line, style: bodyStyle),
            ),
        ],
      ],
    );
  }

  Widget _buildReferencePanel({required String title, required Widget child}) {
    final hasTitle = title.trim().isNotEmpty;
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.xl),
      elevation: StitchCardElevation.subtle,
      ring: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Text(title, style: StitchText.titleLg),
            const SizedBox(height: StitchSpacing.md),
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
    final bodyStyle = StitchText.bodyLg.copyWith(
      color: StitchColors.onSurface,
      height: 1.55,
    );
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.lg),
      elevation: StitchCardElevation.subtle,
      ring: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: StitchColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: StitchText.titleMd)),
            ],
          ),
          const SizedBox(height: StitchSpacing.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: StitchColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _stripRedundantGuideBullet(item),
                      style: bodyStyle,
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
    return StitchChip(label: text, tone: StitchChipTone.secondary);
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
            Text(
              'No guide matches found.',
              style: StitchText.bodyLg.copyWith(
                color: StitchColors.onSurface,
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
                padding: const EdgeInsets.only(bottom: StitchSpacing.md),
                child: StitchCard(
                  padding: const EdgeInsets.all(StitchSpacing.lg),
                  elevation: StitchCardElevation.subtle,
                  ring: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: StitchText.titleMd.copyWith(
                          color: StitchColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: StitchSpacing.md),
                      ...previewItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: StitchColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _stripRedundantGuideBullet(item),
                                  style: StitchText.bodyLg.copyWith(
                                    color: StitchColors.onSurface,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: StitchGhostButton(
                          label: 'Open',
                          onPressed: entry.onOpen,
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
