import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/line_deep_clean_assignments.dart';
import '../theme/app_ui_tokens.dart';

part 'reference/reference_catalog.dart';
part 'reference/reference_section_registry.dart';
part 'reference/reference_helpers.dart';
part 'reference/reference_extractors.dart';
part 'reference/reference_flows/dishroom_guides_flow.dart';
part 'reference/reference_flows/kitchen_guides_flow.dart';
part 'reference/reference_flows/line_guide_group_flow.dart';
part 'reference/reference_flows/misc_reference_group_flow.dart';
part 'reference/reference_flows/night_custodial_guides_flow.dart';
part 'reference/reference_flows/recipes_guides_flow.dart';
part 'reference/reference_flows/line_jobs_flow.dart';
part 'reference/reference_flows/line_secondary_flow.dart';
part 'reference/reference_flows/find_item_flow.dart';
part 'reference/reference_flows/condiments_rotation_flow.dart';
part 'reference/reference_flows/line_deep_clean_flow.dart';
part 'reference/reference_flows/dining_map_flow.dart';

/// Guided reference browser for line operations, item lookup, condiments, and
/// map content.
class ReferenceSheetsView extends StatefulWidget {
  const ReferenceSheetsView({
    super.key,
    this.initialSection = 'Select',
    this.lockSection = false,
    this.useOuterCard = true,
    this.adminModeEnabled = false,
  });

  final String initialSection;
  final bool lockSection;
  final bool useOuterCard;
  final bool adminModeEnabled;

  @override
  State<ReferenceSheetsView> createState() => _ReferenceSheetsViewState();
}

class _ReferenceSheetsViewState extends State<ReferenceSheetsView> {
  static const String _customLockerItemsKey = 'custom_locker_items_v1';
  static const String _deletedLockerItemsKey = 'deleted_locker_items_v1';
  static const String _guideOverridesKey = 'guide_overrides_v1';
  late final Future<Map<String, dynamic>> _referenceFuture;
  final TransformationController _mapTransformationController =
      TransformationController();
  final TextEditingController _lockerSearchController = TextEditingController();
  final TextEditingController _lockerAddItemController =
      TextEditingController();
  final TextEditingController _guideSearchController = TextEditingController();
  String _selectedSection = 'Select';
  int _condimentStep = 0;
  String _selectedCondimentColor = 'green';
  String _selectedCondimentDay = 'monday';
  String _selectedCondimentMeal = 'Breakfast';
  int _lineDeepCleanStep = 0;
  String _selectedLineDeepCleanDay = 'monday';
  String _selectedLineDeepCleanMeal = 'Breakfast';
  int _lineStep = 0;
  String _selectedLineMeal = 'Breakfast';
  String? _selectedLineJobKey;
  String _lockerSearchQuery = '';
  String _guideSearchQuery = '';
  String _selectedLineGuideSection = 'Select';
  String _selectedDishroomCard = 'Select';
  String _selectedKitchenCard = 'Select';
  String _selectedNightCustodialCard = 'Select';
  String _selectedRecipeCard = 'Select';
  String _selectedSafetyCard = 'Select';
  String _selectedGeneralInformationCard = 'Select';
  String _selectedLockerAddLocation = '1';
  bool _showLockerBrowsePanel = false;
  bool _showLockerAddPanel = false;
  bool _showLockerDeleteMode = false;
  Map<String, List<String>> _customLockerInventory = const {};
  Map<String, List<String>> _deletedLockerInventory = const {};
  Map<String, List<String>> _guideOverrides = const {};
  int _lineSecondaryStep = 0;
  String _lineSecondaryMeal = 'Breakfast';
  String _lineSecondaryGroup = 'While Doors Open';

  void _updateReferenceState(VoidCallback action) {
    setState(action);
  }

  @override
  void initState() {
    super.initState();
    _selectedSection = widget.initialSection;
    _referenceFuture = _loadReferenceData();
    _loadCustomLockerInventory();
    _loadDeletedLockerInventory();
    _loadGuideOverrides();
  }

  @override
  void dispose() {
    _mapTransformationController.dispose();
    _lockerSearchController.dispose();
    _lockerAddItemController.dispose();
    _guideSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomLockerInventory() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }
    final raw = prefs.getString(_customLockerItemsKey);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final parsed = <String, List<String>>{};
      for (final entry in decoded.entries) {
        parsed[entry.key] = ((entry.value as List<dynamic>?) ?? const [])
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _customLockerInventory = parsed;
      });
    } catch (_) {
      // Ignore malformed local cache and fall back to bundled inventory.
    }
  }

  Future<void> _loadDeletedLockerInventory() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }
    final raw = prefs.getString(_deletedLockerItemsKey);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final parsed = <String, List<String>>{};
      for (final entry in decoded.entries) {
        parsed[entry.key] = ((entry.value as List<dynamic>?) ?? const [])
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _deletedLockerInventory = parsed;
      });
    } catch (_) {
      // Ignore malformed local cache and fall back to bundled inventory.
    }
  }

  Future<void> _saveCustomLockerInventory() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }
    await prefs.setString(
      _customLockerItemsKey,
      jsonEncode(_customLockerInventory),
    );
  }

  Future<void> _saveDeletedLockerInventory() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }
    await prefs.setString(
      _deletedLockerItemsKey,
      jsonEncode(_deletedLockerInventory),
    );
  }

  Future<void> _loadGuideOverrides() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }
    final raw = prefs.getString(_guideOverridesKey);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final parsed = <String, List<String>>{};
      for (final entry in decoded.entries) {
        parsed[entry.key] = ((entry.value as List<dynamic>?) ?? const [])
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _guideOverrides = parsed;
      });
    } catch (_) {
      // Ignore malformed local cache and fall back to bundled guide content.
    }
  }

  Future<void> _saveGuideOverrides() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on MissingPluginException {
      return;
    }
    await prefs.setString(_guideOverridesKey, jsonEncode(_guideOverrides));
  }

  String _guideOverrideKey({
    required String topSection,
    required String guideKey,
    required String cardTitle,
  }) => '$topSection::$guideKey::$cardTitle';

  List<String> _guideItemsForKey(String key, List<String> fallback) {
    final override = _guideOverrides[key];
    if (override == null) return fallback;
    return override;
  }

  Future<void> _setGuideOverride({
    required String key,
    required List<String> items,
  }) async {
    setState(() {
      _guideOverrides = <String, List<String>>{..._guideOverrides, key: items};
    });
    await _saveGuideOverrides();
  }

  Future<void> _clearGuideOverride(String key) async {
    final updated = <String, List<String>>{..._guideOverrides}..remove(key);
    setState(() {
      _guideOverrides = updated;
    });
    await _saveGuideOverrides();
  }

  Future<void> _addLockerInventoryItem({
    required String location,
    required String item,
  }) async {
    final normalizedItem = item.trim();
    if (normalizedItem.isEmpty) return;

    final existing = _customLockerInventory[location] ?? const <String>[];
    final alreadyExists = existing.any(
      (entry) => entry.toLowerCase() == normalizedItem.toLowerCase(),
    );
    if (alreadyExists) return;

    final updated = <String, List<String>>{
      ..._customLockerInventory,
      location: [...existing, normalizedItem]
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
    };
    final deletedForLocation = _deletedLockerInventory[location] ?? const [];
    final updatedDeleted = <String, List<String>>{
      ..._deletedLockerInventory,
      if (deletedForLocation.isNotEmpty)
        location: deletedForLocation
            .where(
              (entry) => entry.toLowerCase() != normalizedItem.toLowerCase(),
            )
            .toList(),
    }..removeWhere((_, value) => value.isEmpty);

    setState(() {
      _customLockerInventory = updated;
      _deletedLockerInventory = updatedDeleted;
    });
    await _saveCustomLockerInventory();
    await _saveDeletedLockerInventory();
  }

  Future<void> _deleteLockerInventoryItem({
    required String location,
    required String item,
  }) async {
    final normalizedItem = item.trim();
    if (normalizedItem.isEmpty) return;

    final existingCustom = _customLockerInventory[location] ?? const [];
    final updatedCustom = <String, List<String>>{
      ..._customLockerInventory,
      location: existingCustom
          .where((entry) => entry.toLowerCase() != normalizedItem.toLowerCase())
          .toList(),
    }..removeWhere((_, value) => value.isEmpty);

    final existingDeleted = _deletedLockerInventory[location] ?? const [];
    final alreadyDeleted = existingDeleted.any(
      (entry) => entry.toLowerCase() == normalizedItem.toLowerCase(),
    );
    final updatedDeleted = <String, List<String>>{
      ..._deletedLockerInventory,
      location:
          alreadyDeleted
                ? existingDeleted
                : [...existingDeleted, normalizedItem]
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
    };

    setState(() {
      _customLockerInventory = updatedCustom;
      _deletedLockerInventory = updatedDeleted;
    });
    await _saveCustomLockerInventory();
    await _saveDeletedLockerInventory();
  }

  Future<Map<String, dynamic>> _loadReferenceData() async {
    // Reference content is bundled as an asset so the app can render guide
    // pages without additional backend dependencies.
    final raw = await rootBundle.loadString(
      'assets/reference/cafeteria_reference_data.json',
    );
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  bool _isEditableGuideSection(String section) {
    return const {
      'Line',
      'Dishroom',
      'Kitchen',
      'Night Custodial',
      'Recipes',
      'Safety',
      'General Information',
    }.contains(section);
  }

  ({String key, String title, List<String> items, bool hasOverride})?
  _currentGuideEditTarget(Map<String, dynamic> data) {
    switch (_selectedSection) {
      case 'Dishroom':
        if (_selectedDishroomCard == 'Select') return null;
        final entry =
            _nestedGuideEntries(
                  data,
                  topSection: 'Dishroom',
                  sectionKey: 'dishroom_guides',
                  orderedGuideKeys: const [
                    'operations',
                    'chemicals',
                    'cleaning',
                    'jobs',
                    'scullery',
                  ],
                )
                .where((entry) => entry.cardTitle == _selectedDishroomCard)
                .firstOrNull;
        if (entry == null) return null;
        final key = _guideOverrideKey(
          topSection: 'Dishroom',
          guideKey: entry.guideKey,
          cardTitle: entry.cardTitle,
        );
        return (
          key: key,
          title: entry.cardTitle,
          items: entry.items,
          hasOverride: _guideOverrides.containsKey(key),
        );
      case 'Kitchen':
        if (_selectedKitchenCard == 'Select') return null;
        final entry = _nestedGuideEntries(
          data,
          topSection: 'Kitchen',
          sectionKey: 'kitchen_guides',
          orderedGuideKeys: const [
            'salad_deli',
            'desserts_fruit',
            'weekend_setup',
          ],
        ).where((entry) => entry.cardTitle == _selectedKitchenCard).firstOrNull;
        if (entry == null) return null;
        final key = _guideOverrideKey(
          topSection: 'Kitchen',
          guideKey: entry.guideKey,
          cardTitle: entry.cardTitle,
        );
        return (
          key: key,
          title: entry.cardTitle,
          items: entry.items,
          hasOverride: _guideOverrides.containsKey(key),
        );
      case 'Night Custodial':
        if (_selectedNightCustodialCard == 'Select') return null;
        final entry =
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
                .where(
                  (entry) => entry.cardTitle == _selectedNightCustodialCard,
                )
                .firstOrNull;
        if (entry == null) return null;
        final key = _guideOverrideKey(
          topSection: 'Night Custodial',
          guideKey: entry.guideKey,
          cardTitle: entry.cardTitle,
        );
        return (
          key: key,
          title: entry.cardTitle,
          items: entry.items,
          hasOverride: _guideOverrides.containsKey(key),
        );
      case 'Safety':
        if (_selectedSafetyCard == 'Select') return null;
        final key = _guideOverrideKey(
          topSection: 'Safety',
          guideKey: 'safety_guides',
          cardTitle: _selectedSafetyCard,
        );
        final items = _guideCardItemsForSection(
          data,
          sectionKey: 'safety_guides',
          cardTitle: _selectedSafetyCard,
          topSection: 'Safety',
        );
        return items == null
            ? null
            : (
                key: key,
                title: _selectedSafetyCard,
                items: items,
                hasOverride: _guideOverrides.containsKey(key),
              );
      case 'General Information':
        if (_selectedGeneralInformationCard == 'Select') return null;
        final key = _guideOverrideKey(
          topSection: 'General Information',
          guideKey: 'general_information_guides',
          cardTitle: _selectedGeneralInformationCard,
        );
        final items = _guideCardItemsForSection(
          data,
          sectionKey: 'general_information_guides',
          cardTitle: _selectedGeneralInformationCard,
          topSection: 'General Information',
        );
        return items == null
            ? null
            : (
                key: key,
                title: _selectedGeneralInformationCard,
                items: items,
                hasOverride: _guideOverrides.containsKey(key),
              );
      case 'Recipes':
        if (_selectedRecipeCard == 'Select') return null;
        final key = _guideOverrideKey(
          topSection: 'Recipes',
          guideKey: 'recipes',
          cardTitle: _selectedRecipeCard,
        );
        final fallback =
            (_recipeGuideCards[_selectedRecipeCard]?.values ?? const [])
                .expand((items) => items)
                .toList();
        return (
          key: key,
          title: _selectedRecipeCard,
          items: _guideItemsForKey(key, fallback),
          hasOverride: _guideOverrides.containsKey(key),
        );
      case 'Line':
        switch (_selectedLineGuideSection) {
          case 'Deep Cleaning Assignments':
            if (_lineDeepCleanStep < 2) return null;
            final key = _guideOverrideKey(
              topSection: 'Line',
              guideKey: 'line_deep_clean',
              cardTitle: [
                _selectedLineDeepCleanDay,
                _selectedLineDeepCleanMeal,
              ].join('_'),
            );
            final assignment = lineDeepCleaningAssignmentFor(
              _selectedLineDeepCleanDay,
              _selectedLineDeepCleanMeal,
            );
            final fallback = assignment == null
                ? const [
                    'No deep cleaning assignment found for this day and meal.',
                  ]
                : <String>[assignment];
            return (
              key: key,
              title: 'Line Deep Cleaning',
              items: _guideItemsForKey(key, fallback),
              hasOverride: _guideOverrides.containsKey(key),
            );
          case 'Secondary + Checkoff':
            if (_lineSecondaryStep < 2) return null;
            final key = _guideOverrideKey(
              topSection: 'Line',
              guideKey: 'line_secondary',
              cardTitle: [_lineSecondaryMeal, _lineSecondaryGroup].join('_'),
            );
            final fallback = _currentLineSecondaryItems(data);
            return (
              key: key,
              title: _lineSecondaryGroup,
              items: _guideItemsForKey(key, fallback),
              hasOverride: _guideOverrides.containsKey(key),
            );
          case 'Condiments Rotation':
            if (_condimentStep < 3) return null;
            final key = _guideOverrideKey(
              topSection: 'Line',
              guideKey: 'condiments_rotation',
              cardTitle: [
                _selectedCondimentColor,
                _selectedCondimentDay,
                _selectedCondimentMeal,
              ].join('_'),
            );
            final fallback = _currentCondimentItems(data);
            return (
              key: key,
              title: fallback.isEmpty ? 'No Extra Condiments' : 'Put Out',
              items: _guideItemsForKey(
                key,
                fallback.isEmpty
                    ? const ['Nothing extra for this selection.']
                    : fallback,
              ),
              hasOverride: _guideOverrides.containsKey(key),
            );
          default:
            return null;
        }
      default:
        return null;
    }
  }

  Future<void> _openGuideEditor(Map<String, dynamic> data) async {
    final target = _currentGuideEditTarget(data);
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Open a specific guide card or final guide step first.',
          ),
        ),
      );
      return;
    }

    final result = await showDialog<({List<String>? items, bool reset})>(
      context: context,
      builder: (_) => _GuideEditDialog(
        title: target.title,
        initialItems: target.items,
        canReset: target.hasOverride,
      ),
    );

    if (result == null || !mounted) return;
    if (result.reset) {
      await _clearGuideOverride(target.key);
      return;
    }
    final items = result.items;
    if (items == null) return;
    await _setGuideOverride(key: target.key, items: items);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _referenceFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final sections = _buildSections(data);
        final lockedStandaloneSections = <String>{'Find an Item', 'Dining Map'};
        final showGuideEditAction =
            widget.useOuterCard &&
            !widget.lockSection &&
            _guideSearchQuery.isEmpty &&
            widget.adminModeEnabled &&
            _isEditableGuideSection(_selectedSection);
        _selectedSection =
            _selectedSection == 'Select' ||
                sections.containsKey(_selectedSection) ||
                (widget.lockSection &&
                    lockedStandaloneSections.contains(_selectedSection))
            ? _selectedSection
            : 'Select';

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.lockSection && widget.useOuterCard) ...[
              TextField(
                controller: _guideSearchController,
                decoration: InputDecoration(
                  labelText: 'Search guides',
                  hintText: 'Search instructions, lockers, soups, desserts...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _guideSearchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _guideSearchController.clear();
                            _updateReferenceState(() {
                              _guideSearchQuery = '';
                            });
                          },
                        ),
                ),
                onChanged: (value) {
                  _updateReferenceState(() {
                    _guideSearchQuery = value.trim();
                  });
                },
              ),
              const SizedBox(height: 14),
            ],
            if (!widget.lockSection) ...[
              DropdownButtonFormField<String>(
                key: ValueKey('reference-section-$_selectedSection'),
                initialValue: _selectedSection,
                decoration: const InputDecoration(labelText: 'Section'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<String>(
                    value: 'Select',
                    child: Text('Select'),
                  ),
                  ...sections.keys.map(
                    (name) => DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  _onReferenceSectionSelected(value);
                },
              ),
              const SizedBox(height: 14),
            ],
            _guideSearchQuery.isNotEmpty
                ? _buildGuideSearchPanel(data)
                : _buildSectionContent(context, data, sections),
            if (showGuideEditAction) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openGuideEditor(data),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ],
        );

        if (widget.lockSection && !widget.useOuterCard) {
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Padding(padding: const EdgeInsets.all(18), child: content),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Container(
                decoration: BoxDecoration(
                  color: AppUiTokens.shellSurface,
                  borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
                  border: Border.all(color: AppUiTokens.shellBorder),
                  boxShadow: AppUiTokens.shellShadowSoft,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: content,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GuideEditDialog extends StatefulWidget {
  const _GuideEditDialog({
    required this.title,
    required this.initialItems,
    required this.canReset,
  });

  final String title;
  final List<String> initialItems;
  final bool canReset;

  @override
  State<_GuideEditDialog> createState() => _GuideEditDialogState();
}

class _GuideEditDialogState extends State<_GuideEditDialog> {
  late final TextEditingController _itemsController = TextEditingController(
    text: widget.initialItems.join('\n'),
  );

  @override
  void dispose() {
    _itemsController.dispose();
    super.dispose();
  }

  void _save() {
    final items = _itemsController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    Navigator.of(context).pop((items: items, reset: false));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 440,
        child: TextField(
          controller: _itemsController,
          minLines: 8,
          maxLines: 16,
          decoration: const InputDecoration(
            labelText: 'Lines',
            hintText: 'One bullet per line',
            alignLabelWithHint: true,
          ),
        ),
      ),
      actions: [
        if (widget.canReset)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop((items: null, reset: true)),
            child: const Text('Reset'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
