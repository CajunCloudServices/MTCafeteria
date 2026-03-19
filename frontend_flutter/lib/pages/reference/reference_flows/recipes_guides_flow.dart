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

    return _buildReferencePanel(
      title: 'Recipes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String?>(
            key: ValueKey<String>('recipe-guide-$_selectedRecipeCard'),
            initialValue: _selectedRecipeCard == 'Select'
                ? null
                : _selectedRecipeCard,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Recipe'),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Select'),
              ),
              ..._recipeGuideCards.keys.map(
                (recipe) => DropdownMenuItem<String?>(
                  value: recipe,
                  child: Text(recipe),
                ),
              ),
            ],
            onChanged: (value) {
              _updateReferenceState(() {
                _selectedRecipeCard = value ?? 'Select';
              });
            },
          ),
          if (sections != null) ...[
            const SizedBox(height: 14),
            ...sections.entries.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReferenceTaskCard(
                  title: section.key,
                  items: section.value,
                  icon: Icons.restaurant_menu,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
