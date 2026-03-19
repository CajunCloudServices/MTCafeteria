part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

const Map<String, Map<String, List<String>>>
_recipeGuideCards = <String, Map<String, List<String>>>{
  'Eggs': <String, List<String>>{
    'Setup + Staging': <String>[
      'Stage the eggs, oil or butter, spatulas, pans, and towels before the rush starts so the flat top can stay focused on production.',
      'Liquid eggs are kept in Locker 13, so confirm you have enough product staged before service if the cook has already pulled them.',
      'Talk with the cook and the runner before service about when they want low-food callouts and how many pans or hotel pans they want held at a time.',
      'If grease or heavy residue is going to build up during service, make sure there is a grease bucket available early rather than scrambling for one later.',
    ],
    'Cooking + Quality': <String>[
      'Preheat the flat top fully before starting and keep the work area organized so batches stay consistent.',
      'Cook in smaller controlled batches when needed rather than overloading the surface and dropping quality.',
      'Fold and pull eggs before they overcook so texture stays soft through the hold window.',
      'If the texture starts drifting, adjust with the cook right away instead of repeating a bad batch.',
    ],
    'Service + Handoff': <String>[
      'Keep communicating with the runner about what is getting low so cooks are not surprised when the line needs more food.',
      'Label and date any leftover egg product correctly and put it back in the right cooler location if the cook wants it saved.',
      'After service, clean the flat top area and surrounding surfaces so the next shift is not inheriting buildup.',
    ],
  },
  'French Toast Sticks': <String, List<String>>{
    'Setup + Oven Prep': <String>[
      'Preheat the oven to the temperature the cook specifies before loading pans.',
      'Stage sheet pans, parchment or liners if the cooks use them, towels, and holding pans before the first batch goes in.',
      'Confirm with the cook how many pans should be ready ahead and when the runner should call low food during service.',
    ],
    'Cooking + Batch Control': <String>[
      'Arrange French toast sticks in a single layer so they heat evenly and do not steam each other.',
      'Cook in timed batches and rotate pans partway through if the oven cooks unevenly.',
      'Keep an eye on color and crispness rather than relying only on the timer, especially on later batches.',
      'Do not overfill holding pans so product stays serviceable instead of going soggy.',
    ],
    'Hold + Service Support': <String>[
      'Hold hot product where the cook wants it and keep the freshest batch moving forward for service first.',
      'Communicate early when only a few pans are left so the next batch can be started in time.',
      'When service slows down, adjust batch size downward so extra product is not wasted.',
    ],
  },
  'Fried Chicken': <String, List<String>>{
    'Safety + Setup': <String>[
      'Confirm fryer setup and safety checks with the cook before starting any batch.',
      'Make sure the gas and electrical connections are solid if equipment has been moved. In Main Dish, the plug rotates to lock and unlock, and the gas hose should snap firmly into place.',
      'A green light issue usually points to the electrical connection, and a pilot-light issue usually points to the gas connection.',
      'Always return moved Main Dish equipment in the same order it was pulled: flat top, flat top, table, grill, fryer, SM grill.',
    ],
    'Frying + Batch Control': <String>[
      'Load chicken in controlled batches and do not overcrowd the fryer.',
      'Let the cook set the timing and doneness standard, especially for any product-size differences across batches.',
      'Keep the area organized for raw-to-cooked flow so pans, tongs, and holding space do not get crossed up during the rush.',
    ],
    'Holding + Cleanup': <String>[
      'Transfer finished chicken to the hold pan the cook wants, label batch timing if that is part of the shift routine, and keep it service-ready.',
      'If the item throws off a lot of grease, make sure the grease bucket is being used and emptied instead of letting that become an end-of-shift problem.',
      'After service, help reset the fryer area, label leftovers correctly, and leave the station ready for the next crew.',
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
