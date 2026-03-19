import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/line_deep_clean_assignments.dart';
import '../config/runtime_config.dart';

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
  });

  final String initialSection;
  final bool lockSection;
  final bool useOuterCard;

  @override
  State<ReferenceSheetsView> createState() => _ReferenceSheetsViewState();
}

class _ReferenceSheetsViewState extends State<ReferenceSheetsView> {
  static const String _customLockerItemsKey = 'custom_locker_items_v1';
  static const String _deletedLockerItemsKey = 'deleted_locker_items_v1';
  final AppRuntimeConfig _runtimeConfig = AppRuntimeConfig.fromEnvironment;
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
    // Reference content is bundled as an asset so pilot mode can operate
    // without additional backend dependencies.
    final raw = await rootBundle.loadString(
      'assets/reference/cafeteria_reference_data.json',
    );
    return jsonDecode(raw) as Map<String, dynamic>;
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
              Text('Guides', style: Theme.of(context).textTheme.headlineSmall),
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
            _guideSearchQuery.isNotEmpty
                ? _buildGuideSearchPanel(data)
                : _buildSectionContent(context, data, sections),
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
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
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
