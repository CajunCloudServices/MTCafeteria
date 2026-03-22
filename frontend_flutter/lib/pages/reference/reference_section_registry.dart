part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _ReferenceSectionRegistry on _ReferenceSheetsViewState {
  Map<String, List<String>> _buildSections(Map<String, dynamic> data) {
    return <String, List<String>>{
      'Line': _extractLineAllGuides(data),
      'Dishroom': _extractDishroomAllGuides(data),
      'Night Custodial': _extractNightCustodialAllGuides(data),
      'Kitchen': _extractKitchenAllGuides(data),
      'Recipes': _extractRecipeGuides(),
      'Safety': _extractGuideCards(data, 'safety_guides'),
      'General Information': _extractGuideCards(
        data,
        'general_information_guides',
      ),
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
    if (_selectedSection == 'Find an Item') {
      return _buildLockerFlow(data);
    }
    if (_selectedSection == 'Dining Map') {
      return _buildDiningMapPanel(context);
    }
    if (_selectedSection == 'Line') {
      return _buildLineGuideGroupPanel(data);
    }
    if (_selectedSection == 'Dishroom') {
      return _buildDishroomGuideGroupPanel(
        data,
        sectionTitle: _selectedSection,
      );
    }
    if (_selectedSection == 'Night Custodial') {
      return _buildNightCustodialGuideGroupPanel(
        data,
        sectionTitle: _selectedSection,
      );
    }
    if (_selectedSection == 'Kitchen') {
      return _buildKitchenGuideGroupPanel(data, sectionTitle: _selectedSection);
    }
    if (_selectedSection == 'Recipes') {
      return _buildRecipeGuidePanel();
    }
    if (_selectedSection == 'Safety') {
      return _buildGenericGuideGroupPanel(
        data,
        sectionKey: 'safety_guides',
        sectionTitle: _selectedSection,
        selectedCard: _selectedSafetyCard,
        fieldLabel: 'Safety section',
        onSelected: (value) {
          _selectedSafetyCard = value;
        },
        icon: Icons.health_and_safety_outlined,
      );
    }
    if (_selectedSection == 'General Information') {
      return _buildGenericGuideGroupPanel(
        data,
        sectionKey: 'general_information_guides',
        sectionTitle: _selectedSection,
        selectedCard: _selectedGeneralInformationCard,
        fieldLabel: 'General Information section',
        onSelected: (value) {
          _selectedGeneralInformationCard = value;
        },
        icon: Icons.info_outline,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: _buildReadableLines(lines),
    );
  }

  void _resetGuideSelectionStateForSection(String value) {
    switch (value) {
      case 'Line':
        _selectedLineGuideSection = 'Select';
        _lineStep = 0;
        _lineSecondaryStep = 0;
      case 'Dishroom':
        _selectedDishroomCard = 'Select';
      case 'Night Custodial':
        _selectedNightCustodialCard = 'Select';
      case 'Kitchen':
        _selectedKitchenCard = 'Select';
      case 'Recipes':
        _selectedRecipeCard = 'Select';
      case 'Safety':
        _selectedSafetyCard = 'Select';
      case 'General Information':
        _selectedGeneralInformationCard = 'Select';
      case 'Condiments Rotation':
        _condimentStep = 0;
    }
  }

  void _onReferenceSectionSelected(String value) {
    _updateReferenceState(() {
      _selectedSection = value;
      _showLockerBrowsePanel = false;
      _showLockerAddPanel = false;
      _showLockerDeleteMode = false;
      _resetGuideSelectionStateForSection(value);
    });
  }
}
