part of '../dashboard_support_sections.dart';

class KitchenJobsSection extends StatefulWidget {
  const KitchenJobsSection({
    super.key,
    required this.resetSignal,
    required this.backSignal,
    required this.onBackAtRoot,
  });

  final int resetSignal;
  final int backSignal;
  final VoidCallback onBackAtRoot;

  @override
  State<KitchenJobsSection> createState() => _KitchenJobsSectionState();
}

class _KitchenJobsSectionState extends State<KitchenJobsSection> {
  int _step = 0;
  String _station = 'Main Dish';
  String _mainDishItem = 'Eggs';
  String? _mainDishSection;
  String? _dessertSection;
  String? _saladSection;
  int _lastReset = 0;
  int _lastBack = 0;

  static const List<String> _stations = <String>[
    'Main Dish',
    'Desserts',
    'Salads',
  ];

  static const Map<String, List<String>>
  _saladSections = <String, List<String>>{
    'Dressings + Tortillas': <String>[
      'Keep dressings in the larger salad-area bottles under the table when setting up the salad side.',
      'Current dressings listed in the notes are Ranch, Thousand Island, Bleu Cheese, Raspberry Vinaigrette, Catalina, Poppyseed, Italian, and Creamy Caesar.',
      'Breakfast line crew is expected to replace dressing bottles every day for lunch and dinner and also make sure refill containers are available.',
      'Use 4 to 5 tortilla kinds, including whole wheat, plain, spinach, tomato basil, and garlic herb.',
      'Tortilla wraps are pulled from Locker 10, and if needed from Locker 11 to thaw.',
    ],
    'Greens + Cold Well': <String>[
      'Tortilla wraps, lettuce, and spinach stage through the salad cart and the southwest cold-well area of the island during service.',
      'Turn on the cold well by holding the power button for about 5 seconds.',
      'Put out 2 pans of lettuce and 1 pan of spinach during service, with backup product kept in the cooler.',
    ],
    'Toppings + Produce': <String>[
      'Use the clipboard and the paper in the salad binder to see how many pans of each topping need to be prepped.',
      'Write down the number of new pans you made so the next person can see what was already done.',
      'Salad toppings are generally panned into deep 1/6-size metal pans so more topping varieties can fit on the island during service.',
      'Before panning new toppings, always check both date and quality.',
      'Throw away spoiled food, including moldy produce or anything clearly past quality.',
      'Most salad vegetables are kept in Locker 8, including onions, peppers, carrots, cucumbers, squash, tomatoes, alfalfa sprouts, and sugar snap peas.',
      'Common fruit items include mandarin oranges, pineapple tidbits, and craisins, with substitutes like peaches, pears, or raisins if needed.',
      'Olives and beans should be drained or rinsed as needed before panning.',
    ],
    'Cheese + Meat Handling': <String>[
      'Do not keep meats or cooked leftovers longer than 7 days.',
      'The cheese section is mostly Locker 7, with shredded cheddar bags there, cottage cheese in Locker 8, and white cheeses in Locker 7, including feta, bleu cheese, parmesan, mozzarella, cotija, and pepper jack.',
      'If cottage cheese is unavailable, the notes suggest using 2 kinds of white cheese as a practical substitute.',
      'Always check cheese carefully for mold before putting it out.',
      'Check available leftovers and prepared meats before panning new salad-bar meat items.',
      'Usable meats can include Philly beef, chicken fajita, shredded meats like barbacoa or Carolina pork, steak, chicken breast, bacon, ham slices, and shredded salmon.',
      'Some meats need to be cut up before they can go onto the salad bar.',
      'If using cooked leftovers, use the date the product was cooked and cooled when labeling it.',
      'If using thawed packaged meats, use the open date.',
      'Do not use cooked leftover meats older than 7 days.',
      'Diced eggs are stored frozen in Locker 10 and should be pulled 2 to 3 trays at a time as needed.',
    ],
    'Soup Service': <String>[
      'Soup service is usually breakfast 7:00 to 8:30 a.m., lunch 11:30 a.m. to 1:15 p.m., and dinner 4:30 to 6:15 p.m.',
      'Soups come pre-bagged from campus and are stored in Locker 1 near the east dock before cooks place them into the bain marie in the main kitchen.',
      'Use the bain marie carefully because the water can be very hot or boiling.',
      'Use long tongs plus heat protection such as rags or oven mitts when handling soup bags.',
      'Carry soup to the island on a movable metal cart, set the soup-pot dial around 4 or 5, label the soups, and wipe up spills.',
    ],
    'Deli Bar': <String>[
      'The deli bar layout is condiments, meats, cheeses, then vegetables.',
      'Mayo and mustard or Dijon are kept in the cage.',
      'Common deli meats are ham, roast beef, and turkey, and common cheeses are cheddar, Swiss, provolone, and pepper jack.',
      'Green leaf lettuce, sliced tomatoes, and red onions are in Locker 8, and pickles are in Locker 4.',
      'Deli meats are typically frozen in freezer 11, so pull a box out a few days before service so it can thaw in time.',
      'If meats run short, talk to a supervisor, full-time kitchen staff, or the material specialist.',
      'On heavy sandwich days, prep extra cheese, lettuce, tomatoes, mustard, and pickles ahead of time.',
    ],
  };

  static const Map<String, List<String>>
  _dessertSections = <String, List<String>>{
    'Storage + Setup': <String>[
      'Desserts are kept in upright keepers in closed wheeled racks.',
      'Uncut desserts are commonly received into Locker 8 until they are ready to be cut for service.',
      'Keep cold desserts cold, especially anything containing dairy or nuts.',
      'Use clean knives between dessert types to reduce cross-contact.',
      'Label every tray with the dessert name and the date made.',
      'Return the dessert keeper to Locker 10 when finished.',
    ],
    'Cutting + Portioning': <String>[
      'When cutting brownies and other dense desserts, use care so you do not leave metal shavings in the pan.',
      'Dense pies and crusted desserts should be cut all the way through so slices come out clean and are easier to serve.',
      'Most tray desserts such as cakes, bars, and Rice Krispy treats are cut into 7 by 10 pieces, for 70 total pieces.',
      'Cheesecakes are usually cut into 16 pieces, and pies are usually cut into 8 pieces.',
      'Hot water on the knife can help when cutting cheesecake.',
      'Puddings, crisps, and cobblers go into 9 oz cups, filled about two-thirds to three-quarters full with the designated scoop.',
      'Nilla Wafer pudding stays in the pan it comes in rather than being repanned.',
    ],
    'Sweet Breads + Angel Food Cake': <String>[
      'Sweet bread loaves for Monday service are prepped by checking Friday counts, slicing each loaf into about 8 to 10 slices, and shingling the slices into a full-size hotel pan.',
      'If sweet bread will not be served right away, cover it with plastic wrap.',
      'Angel food cake is treated like a dessert even though it comes as a loaf; slice it like sweet bread and keep it covered so it does not dry out.',
      'The notes call for 1 or 2 small pans of strawberry syrup with angel food cake and a visible note so line workers know the syrup goes with the cake.',
    ],
    'No-Prep Desserts': <String>[
      'Cookies require no kitchen prep for service; line workers handle them during lunch.',
      'Pre-portioned desserts such as mousse cups, panna cotta cups, macarons, pecan tarts, and key lime tarts do not need additional preparation.',
      'If a dessert does not need prep, it can stay out for lunch service as-is.',
    ],
  };

  static const List<String> _mainDishItems = <String>[
    'Eggs',
    'French Toast Sticks',
    'Fried Chicken',
  ];

  static const Map<String, Map<String, List<String>>>
  _mainDishSections = <String, Map<String, List<String>>>{
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

  @override
  void initState() {
    super.initState();
    _lastReset = widget.resetSignal;
    _lastBack = widget.backSignal;
  }

  @override
  void didUpdateWidget(covariant KitchenJobsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    void deferRootBack() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onBackAtRoot();
      });
    }

    if (widget.resetSignal != _lastReset) {
      _lastReset = widget.resetSignal;
      setState(() {
        _step = 0;
        _station = 'Main Dish';
        _mainDishItem = 'Eggs';
        _mainDishSection = null;
        _dessertSection = null;
        _saladSection = null;
      });
    }

    if (widget.backSignal != _lastBack) {
      _lastBack = widget.backSignal;
      if (_step > 0) {
        setState(() => _step -= 1);
      } else {
        deferRootBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _step == 0
            ? _buildKitchenFlowChooser()
            : _buildSelectedFlowView(),
      ),
    );
  }

  Widget _buildKitchenFlowChooser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelTitle(icon: Icons.restaurant_menu, title: 'Kitchen Jobs'),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_step + 1) / 2,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: const Color(0xFFE2ECF8),
          color: const Color(0xFF1F5E9C),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _station,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Kitchen Flow'),
          items: _stations
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) => setState(() {
            _station = value ?? _station;
            _mainDishSection = null;
            _dessertSection = null;
            _saladSection = null;
          }),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFlowView() {
    if (_station == 'Main Dish') {
      return _buildMainDishRecipesView();
    }
    return _buildSectionedFlowView(title: _station);
  }

  Widget _buildSectionedFlowView({required String title}) {
    final isDesserts = title == 'Desserts';
    final sections = isDesserts ? _dessertSections : _saladSections;
    final selectedSection = isDesserts ? _dessertSection : _saladSection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF123A64),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          key: ValueKey<String>(
            'kitchen-$title-${selectedSection ?? 'select'}',
          ),
          initialValue: selectedSection,
          isExpanded: true,
          decoration: InputDecoration(labelText: '$title Section'),
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem<String?>(value: null, child: Text('Select')),
            ...sections.keys.map(
              (section) => DropdownMenuItem<String?>(
                value: section,
                child: Text(section),
              ),
            ),
          ],
          onChanged: (value) => setState(() {
            if (isDesserts) {
              _dessertSection = value;
            } else {
              _saladSection = value;
            }
          }),
        ),
        const SizedBox(height: 12),
        if (selectedSection == null)
          _buildEmptySectionState(
            'Choose a $title section to view the job instructions.',
          )
        else
          _buildInstructionPanel(sections[selectedSection]!),
      ],
    );
  }

  Widget _buildMainDishRecipesView() {
    final sections = _mainDishSections[_mainDishItem]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Main Dish Recipes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF123A64),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _mainDishItem,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Recipe / Item'),
          items: _mainDishItems
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() {
            _mainDishItem = value ?? _mainDishItem;
            _mainDishSection = null;
          }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          key: ValueKey<String>(
            'main-dish-$_mainDishItem-${_mainDishSection ?? 'select'}',
          ),
          initialValue: _mainDishSection,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Instruction Section'),
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem<String?>(value: null, child: Text('Select')),
            ...sections.keys.map(
              (section) => DropdownMenuItem<String?>(
                value: section,
                child: Text(section),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _mainDishSection = value),
        ),
        const SizedBox(height: 12),
        if (_mainDishSection == null)
          _buildEmptySectionState(
            'Choose a Main Dish section to view the job instructions.',
          )
        else
          _buildInstructionPanel(sections[_mainDishSection]!),
      ],
    );
  }

  Widget _buildInstructionPanel(List<String> lines) {
    final numbered = <String>[
      for (int i = 0; i < lines.length; i++) '${i + 1}. ${lines[i]}',
    ];
    return InstructionCard(lines: numbered);
  }

  Widget _buildEmptySectionState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFD2EA)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF355C84),
        ),
      ),
    );
  }
}
