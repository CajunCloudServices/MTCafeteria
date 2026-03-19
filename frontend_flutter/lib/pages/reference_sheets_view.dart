import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/runtime_config.dart';

part 'reference/reference_catalog.dart';
part 'reference/reference_section_registry.dart';
part 'reference/reference_helpers.dart';
part 'reference/reference_extractors.dart';
part 'reference/reference_flows/line_jobs_flow.dart';
part 'reference/reference_flows/line_secondary_flow.dart';
part 'reference/reference_flows/find_item_flow.dart';
part 'reference/reference_flows/condiments_rotation_flow.dart';
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
  final AppRuntimeConfig _runtimeConfig = AppRuntimeConfig.fromEnvironment;
  late final Future<Map<String, dynamic>> _referenceFuture;
  final TransformationController _mapTransformationController =
      TransformationController();
  final TextEditingController _lockerSearchController = TextEditingController();
  String _selectedSection = 'Select';
  int _condimentStep = 0;
  String _selectedCondimentColor = 'green';
  String _selectedCondimentDay = 'monday';
  String _selectedCondimentMeal = 'Breakfast';
  int _lineStep = 0;
  String _selectedLineMeal = 'Breakfast';
  String? _selectedLineJobKey;
  String _lockerSearchQuery = '';
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
  }

  @override
  void dispose() {
    _mapTransformationController.dispose();
    _lockerSearchController.dispose();
    super.dispose();
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
            if (!widget.lockSection) ...[
              Text('Guides', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
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
            _buildSectionContent(context, data, sections),
          ],
        );

        if (widget.lockSection && !widget.useOuterCard) {
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initialSection,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 14),
                  content,
                ],
              ),
            ),
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
