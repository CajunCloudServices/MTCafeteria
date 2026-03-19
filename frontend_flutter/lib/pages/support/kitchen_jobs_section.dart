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
  int _lastReset = 0;
  int _lastBack = 0;

  static const List<String> _stations = <String>[
    'Main Dish',
    'Desserts',
    'Salads',
  ];

  static const List<String> _saladLines = <String>[
    'Go to Locker 9 and review what is ready to prep first.',
    'Prioritize time-sensitive items first (fruit, proteins, specialty toppings).',
    'Prep portions based on current meal demand and communicate shortages.',
    'Label and date all pans and stage for easy salad-bar restock.',
    'Check lettuce and produce quality before setting out.',
  ];

  static const List<String> _dessertLines = <String>[
    'Pull dessert pans from the assigned locker and stage them on a clean prep surface.',
    'Cut and portion items consistently so each serving is uniform.',
    'Keep trays clean and presentation-ready before placing at service.',
    'Stage backup trays so refills are quick during meal rushes.',
    'Communicate low stock early to supervisor or cook.',
  ];

  static const List<String> _mainDishItems = <String>[
    'Eggs',
    'French Toast Sticks',
    'Fried Chicken',
  ];

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

  List<String> _mainDishLines(String item) {
    switch (item) {
      case 'French Toast Sticks':
        return const <String>[
          'Preheat oven to chef-specified temperature before loading pans.',
          'Arrange sticks in a single layer for even cooking.',
          'Cook in timed intervals and rotate pans halfway through.',
          'Hold hot and communicate freshness timing to serving line.',
        ];
      case 'Fried Chicken':
        return const <String>[
          'Confirm fryer temp and safety checks with chef before starting.',
          'Load chicken in controlled batches (do not overcrowd).',
          'Cook until chef confirms internal temperature and doneness.',
          'Transfer to hold pan, label batch time, and keep service-ready.',
        ];
      case 'Eggs':
      default:
        return const <String>[
          'Preheat flat top and stage eggs, oil/butter, and tools.',
          'Cook in smaller batches for quality and consistency.',
          'Fold gently and remove before overcooking.',
          'Review texture with cook and adjust technique each batch.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _step == 0 ? _buildKitchenFlowChooser() : _buildSelectedFlowView(),
      ),
    );
  }

  Widget _buildKitchenFlowChooser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelTitle(
          icon: Icons.restaurant_menu,
          title: 'Kitchen Jobs',
        ),
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
          onChanged: (value) => setState(() => _station = value ?? _station),
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
    return _buildSimpleFlowView(
      title: _station,
      lines: _station == 'Desserts' ? _dessertLines : _saladLines,
    );
  }

  Widget _buildSimpleFlowView({required String title, required List<String> lines}) {
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
        _buildInstructionPanel(lines),
      ],
    );
  }

  Widget _buildMainDishRecipesView() {
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
          onChanged: (value) =>
              setState(() => _mainDishItem = value ?? _mainDishItem),
        ),
        const SizedBox(height: 12),
        _buildInstructionPanel(_mainDishLines(_mainDishItem)),
      ],
    );
  }

  Widget _buildInstructionPanel(List<String> lines) {
    final numbered = <String>[
      for (int i = 0; i < lines.length; i++) '${i + 1}. ${lines[i]}',
    ];
    return InstructionCard(lines: numbered);
  }
}
