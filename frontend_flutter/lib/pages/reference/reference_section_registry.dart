part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _ReferenceSectionRegistry on _ReferenceSheetsViewState {
  Map<String, List<String>> _buildSections(Map<String, dynamic> data) {
    return <String, List<String>>{
      'Line Jobs': const [],
      'Aloha + Choices': _extractAlohaChoices(data),
      'Condiments Rotation': _extractCondiments(data),
      if (!_runtimeConfig.isPilotProfile)
        'Fruit Prep (Grapes/Kiwi)': _extractFoodPrep(data),
      if (!_runtimeConfig.isPilotProfile) 'Meal Door Times': _extractMealTimes(data),
      if (!_runtimeConfig.isPilotProfile) 'Food Safety': _extractSafety(data),
      'Line Secondary + Checkoff': _extractSecondaryAndCheckoff(data),
    };
  }

  Widget _buildSectionContent(
    BuildContext context,
    Map<String, dynamic> data,
    Map<String, List<String>> sections,
  ) {
    final lines = sections[_selectedSection] ?? const <String>[];

    if (_selectedSection == 'Select') {
      return const SizedBox.shrink();
    }
    if (_selectedSection == 'Line Jobs') {
      return _buildLineJobsFlow(data);
    }
    if (_selectedSection == 'Find an Item') {
      return _buildLockerFlow(data);
    }
    if (_selectedSection == 'Line Secondary + Checkoff') {
      return _buildLineSecondaryFlow(data);
    }
    if (_selectedSection == 'Condiments Rotation') {
      return _buildCondimentsRotationFlow(data);
    }
    if (_selectedSection == 'Aloha + Choices') {
      return _buildAlohaChoicesPanel(data);
    }
    if (_selectedSection == 'Dining Map') {
      return _buildDiningMapPanel(context);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFB6C9E4),
        ),
      ),
      child: _buildReadableLines(lines),
    );
  }

  void _onReferenceSectionSelected(String value) {
    _updateReferenceState(() {
      _selectedSection = value;
      if (value == 'Condiments Rotation') {
        _condimentStep = 0;
      }
      if (value == 'Line Jobs') {
        _lineStep = 0;
      }
      if (value == 'Line Secondary + Checkoff') {
        _lineSecondaryStep = 0;
      }
    });
  }
}
