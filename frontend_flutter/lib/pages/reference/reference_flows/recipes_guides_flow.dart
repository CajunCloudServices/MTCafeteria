part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

const Map<String, Map<String, List<String>>>
_recipeGuideCards = <String, Map<String, List<String>>>{
  'Eggs': <String, List<String>>{
    'Eggs': <String>[
      'Stage eggs, oil or butter, spatulas, and pans before the rush starts.',
      'Preheat the flat top fully before cooking.',
      'Cook in controlled batches and pull the eggs before they overcook.',
      'Keep communicating with the runner and the cook when food is getting low.',
    ],
  },
  'French Toast Sticks': <String, List<String>>{
    'French Toast Sticks': <String>[
      'French toast sticks should be fried for 4 minutes.',
      'Cook in controlled batches so they stay crisp and do not get soggy.',
      'Tell the runner or cook early when you are getting low.',
    ],
  },
  'Fried Chicken': <String, List<String>>{
    'Fried Chicken': <String>[
      'Confirm fryer setup and safety checks with the cook before starting.',
      'Do not overcrowd the fryer.',
      'Let the cook set the timing and doneness standard for the batch.',
      'Keep the hold pan stocked and the fryer area clean and organized.',
    ],
  },
};

extension _RecipeGuidesFlow on _ReferenceSheetsViewState {
  Widget _buildRecipeGuidePanel() {
    final sections = _recipeGuideCards[_selectedRecipeCard];
    final overrideKey = _selectedRecipeCard == 'Select'
        ? null
        : _guideOverrideKey(
            topSection: 'Recipes',
            guideKey: 'recipes',
            cardTitle: _selectedRecipeCard,
          );
    final overrideItems = overrideKey == null
        ? null
        : _guideItemsForKey(
            overrideKey,
            (sections?.values ?? const []).expand((items) => items).toList(),
          );

    if (_selectedRecipeCard == 'Select') {
      return _buildGuideSelectionList(
        title: 'Recipes',
        options: [
          for (final recipe in _recipeGuideCards.keys)
            (
              label: recipe,
              subtitle: null,
              icon: Icons.restaurant_menu,
              onTap: () {
                _updateReferenceState(() {
                  _selectedRecipeCard = recipe;
                });
              },
            ),
        ],
      );
    }

    return _buildGuideContentScreen(
      backLabel: 'Back to Recipes',
      onBack: () {
        _updateReferenceState(() {
          _selectedRecipeCard = 'Select';
        });
      },
      child: _buildReferenceTaskCard(
        title: _selectedRecipeCard,
        items: overrideItems ?? const [],
        icon: Icons.restaurant_menu,
      ),
    );
  }
}
