import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/runtime_config.dart';

/// Guided reference browser for line operations, item lookup, condiments, and
/// map content.
class ReferenceSheetsView extends StatefulWidget {
  const ReferenceSheetsView({
    super.key,
    this.initialSection = 'Select',
    this.lockSection = false,
  });

  final String initialSection;
  final bool lockSection;

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

  String _toTitle(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }

  String _toDayTitle(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  static const Map<String, List<String>> _mealLineJobs = {
    'Breakfast': [
      'Sack Cashier',
      'Sack Runner',
      'Salads',
      'Line Runner',
      'Aloha Plate',
      'Choices',
      'Beverages',
      'Senior Cash',
      'Junior Cash',
      'Desserts',
      'Condiments Prep',
      'Condiments Host',
    ],
    'Lunch': [
      'Sack Cashier',
      'Sack Runner',
      'Salads',
      'Ice Cream',
      'Paninis',
      'Line Runner',
      'Aloha Plate',
      'Choices',
      'Beverages',
      'Senior Cash',
      'Junior Cash',
      'Desserts',
      'Condiments Prep',
      'Condiments Host',
    ],
    'Dinner': [
      'Ice Cream',
      'Paninis',
      'Line Runner',
      'Aloha Plate',
      'Choices',
      'Beverages',
      'Senior Cash',
      'Junior Cash',
      'Desserts',
      'Condiments Prep',
      'Condiments Host',
    ],
  };

  static const Map<String, Map<String, Map<String, List<String>>>>
  _lineReferenceCatalog = {
    'Breakfast': {
      'Sack Cashier': {
        'Setup': [
          'Put out oatmeal',
          'Put out oatmeal cups and lids',
          'Turn on cooler lights',
          'Put out donuts',
          'Put out donut utensils',
          'Unlock door when doors open',
          'Flip sign to "Open"',
          'Set up and sign into register',
        ],
        'During Shift': [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries who do not swipe',
          'Ring up senior missionaries',
          'Communicate with sack runner when items run out',
        ],
        'Cleanup': [
          'Flip sign to "Closed"',
          'Lock door',
          'Log out of register',
          'Turn off cooler lights',
          'Restock drinks',
          'Put away donuts',
          'Put away oatmeal',
          'Wipe counters',
          'Vacuum area',
        ],
      },
      'Sack Runner': {
        'Setup': ['Assist sack cashier with setup tasks'],
        'During Shift': [
          'Restock items from sack room as needed',
          'Coordinate with sack cashier',
        ],
        'Cleanup': ['Assist sack cashier with cleanup tasks'],
      },
      'Salads': {
        'Setup': [
          'Put out fruit and breakfast salad items',
          'Ensure plates are stocked',
        ],
        'During Shift': [
          'Keep salad bar stocked',
          'Ensure plates remain stocked',
          'Keep oatmeal, grits, or similar items stocked and warm',
        ],
        'Cleanup': [
          'Surfaces cleaned',
          'Soup area clean',
          'Fridges wiped out',
          'Floor swept in and out of island',
          'Bowls/plates restocked',
          'Fruit shelf restocked',
          'Lettuce wraps/dressings restocked',
          'Trash emptied',
        ],
      },
      'Line Runner': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Aloha Plate': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Choices': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Beverages': {
        'Setup': [
          'Ensure all beverages are stocked',
          'Turn on beverage machines',
        ],
        'During Shift': [
          'Restock cups',
          'Check bib room for soda stock',
          'Ensure sodas are stocked',
          'Ensure juices are stocked',
          'Ensure all beverage stations remain stocked',
        ],
        'Cleanup': [
          'Milks and juices restocked',
          'Milk/soda/juice machines cleaned',
          'Cups filled',
          'Ice filled',
          'Scissors cleaned',
          'Milk trays cleaned',
          'Coke machine nozzles (dinner)',
          'Blue crates to Empire Crate Building',
          'Empire Crate Building wrapped',
          'Vitamin waters restocked',
          'BIB room checked',
        ],
      },
      'Senior Cash': {
        'Setup': ['Sign into register', 'Verify register is ready'],
        'During Shift': ['Ring up senior missionaries'],
        'Cleanup': [
          'Napkins and salt/pepper',
          'Sanitizer and paper towels',
          'Lost and found items to front desk',
          'Write next meal menu on door',
          'Refill sanitizer bottles',
          'Sweep tile floor',
        ],
      },
      'Junior Cash': {
        'Setup': ['Sign into register'],
        'During Shift': [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries without cards',
        ],
        'Cleanup': [
          'Napkins and salt/pepper',
          'Sanitizer and paper towels',
          'Lost and found items to front desk',
          'Write next meal menu on door',
          'Refill sanitizer bottles',
          'Sweep tile floor',
        ],
      },
      'Desserts': {
        'Setup': [
          'Put out desserts',
          'Breakfast: donuts',
          'Lunch/Dinner: cookies or assigned desserts',
          'Put out plates',
          'Put out utensils',
        ],
        'During Shift': ['Keep desserts stocked', 'Keep utensils stocked'],
        'Cleanup': [
          'Dirty trays/utensils taken to scullery',
          'Dessert plates restocked',
          'Desserts put away in correct spot',
          'Counters/surfaces cleaned and dried',
          'Floor swept',
          'Cereal bowls restocked',
          'Silverware restocked',
        ],
      },
      'Condiments Prep': {
        'Setup': [
          'Ensure condiment cart is full',
          'Assist condiments host with setup',
        ],
        'During Shift': [
          'Keep condiments stocked',
          'Prepare condiments for next meal',
          'If dinner: prepare condiments for breakfast bar next day',
        ],
        'Cleanup': [
          'Enough prepped for next meal',
          'Specialty condiments prepped',
          'PB, J, and butter prepped',
          'Prep surfaces cleaned and dried',
          'Toaster station cleaned and restocked',
          'Condiment dispensers clean and full',
          'Pump station swept under',
          'Fruit bar surfaces cleaned and dried',
          'Bowls/plates restocked on fruit bar',
        ],
      },
      'Condiments Host': {
        'Setup': [
          'Turn on fruit bar cooler',
          'Put out fruit (4 shotgun pans of fruit, 2 of specialty food)',
          'Put out any special condiments to salad bar',
          'Put up allergen signs',
          'Put utensils in the peanut butter, and butter next to Aloha plate',
          'Make sure the condiment stands are stocked',
          'Put spoons in the fruit',
        ],
        'During Shift': [
          'Ensure everything stays stocked: fruit, condiments, and salad bar condiments',
        ],
        'Cleanup': [
          'Wrap and put away the specialty food',
          'Wrap the fruit, leave it in place, and leave the cooler on',
          'Put away the allergen signs',
          'Wipe down the fruit bar',
          'Wipe down all the condiment bars',
          'Wipe down the condiment area of the salad bar',
          'Move salad bar condiments to the student table',
        ],
      },
    },
    'Lunch': {
      'Sack Cashier': {
        'Setup': [
          'Put out soups',
          'Ensure sandwiches are available (not displayed)',
          'Put out cookies',
          'Put out chips',
          'Ensure salads are available',
          'Turn on cooler lights',
          'Unlock door when doors open',
          'Flip sign to "Open"',
          'Set up and sign into register',
        ],
        'During Shift': [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries who do not swipe',
          'Ring up senior missionaries',
          'Communicate with sack runner when items run out',
        ],
        'Cleanup': [
          'Flip sign to "Closed"',
          'Lock door',
          'Log out of register',
          'Turn off cooler lights',
          'Restock drinks',
          'Restock sandwiches',
          'Restock salads',
          'Wipe counters',
          'Vacuum area',
        ],
      },
      'Sack Runner': {
        'Setup': ['Assist sack cashier with setup tasks'],
        'During Shift': [
          'Restock items from sack room as needed',
          'Coordinate with sack cashier',
        ],
        'Cleanup': ['Assist sack cashier with cleanup tasks'],
      },
      'Salads': {
        'Setup': [
          'Put out salad ingredients',
          'Put out tortillas',
          'Set up deli bar',
          'Ensure plates are stocked',
        ],
        'During Shift': [
          'Keep salad bar stocked',
          'Ensure plates remain stocked',
        ],
        'Cleanup': [
          'Surfaces cleaned',
          'Soup area clean',
          'Fridges wiped out',
          'Floor swept in and out of island',
          'Bowls/plates restocked',
          'Fruit shelf restocked',
          'Lettuce wraps/dressings restocked',
          'Trash emptied',
        ],
      },
      'Ice Cream': {
        'Setup': [
          'Get ice cream',
          'Get scoops',
          'Get bowls',
          'Get water as needed',
        ],
        'During Shift': ['Serve ice cream'],
        'Cleanup': [
          'Dirty trays/utensils taken to scullery',
          'Dessert plates restocked',
          'Desserts put away in correct spot',
          'Counters/surfaces cleaned and dried',
          'Floor swept',
          'Cereal bowls restocked',
          'Silverware restocked',
        ],
      },
      'Paninis': {
        'Setup': ['Turn on panini machines'],
        'During Shift': [
          'Prepare paninis',
          'Press paninis in machines',
          'Cut paninis',
          'Put paninis out for service',
        ],
        'Cleanup': [
          'Panini presses and tools cleaned',
          'Surfaces wiped and floor swept',
          'Heated shelf off and cleaned',
        ],
      },
      'Line Runner': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Aloha Plate': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Choices': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Beverages': {
        'Setup': [
          'Ensure all beverages are stocked',
          'Turn on beverage machines',
        ],
        'During Shift': [
          'Restock cups',
          'Check bib room for soda stock',
          'Ensure sodas are stocked',
          'Ensure juices are stocked',
          'Ensure all beverage stations remain stocked',
        ],
        'Cleanup': [
          'Milks and juices restocked',
          'Milk/soda/juice machines cleaned',
          'Cups filled',
          'Ice filled',
          'Scissors cleaned',
          'Milk trays cleaned',
          'Coke machine nozzles (dinner)',
          'Blue crates to Empire Crate Building',
          'Empire Crate Building wrapped',
          'Vitamin waters restocked',
          'BIB room checked',
        ],
      },
      'Senior Cash': {
        'Setup': ['Sign into register', 'Verify register is ready'],
        'During Shift': ['Ring up senior missionaries'],
        'Cleanup': [
          'Napkins and salt/pepper',
          'Sanitizer and paper towels',
          'Lost and found items to front desk',
          'Write next meal menu on door',
          'Refill sanitizer bottles',
          'Sweep tile floor',
        ],
      },
      'Junior Cash': {
        'Setup': ['Sign into register'],
        'During Shift': [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries without cards',
        ],
        'Cleanup': [
          'Napkins and salt/pepper',
          'Sanitizer and paper towels',
          'Lost and found items to front desk',
          'Write next meal menu on door',
          'Refill sanitizer bottles',
          'Sweep tile floor',
        ],
      },
      'Desserts': {
        'Setup': [
          'Put out desserts',
          'Breakfast: donuts',
          'Lunch/Dinner: cookies or assigned desserts',
          'Put out plates',
          'Put out utensils',
        ],
        'During Shift': ['Keep desserts stocked', 'Keep utensils stocked'],
        'Cleanup': [
          'Dirty trays/utensils taken to scullery',
          'Dessert plates restocked',
          'Desserts put away in correct spot',
          'Counters/surfaces cleaned and dried',
          'Floor swept',
          'Cereal bowls restocked',
          'Silverware restocked',
        ],
      },
      'Condiments Prep': {
        'Setup': [
          'Ensure condiment cart is full',
          'Assist condiments host with setup',
        ],
        'During Shift': [
          'Keep condiments stocked',
          'Prepare condiments for next meal',
          'If dinner: prepare condiments for breakfast bar next day',
        ],
        'Cleanup': [
          'Enough prepped for next meal',
          'Specialty condiments prepped',
          'PB, J, and butter prepped',
          'Prep surfaces cleaned and dried',
          'Toaster station cleaned and restocked',
          'Condiment dispensers clean and full',
          'Pump station swept under',
          'Fruit bar surfaces cleaned and dried',
          'Bowls/plates restocked on fruit bar',
        ],
      },
      'Condiments Host': {
        'Setup': [
          'Turn on fruit bar cooler',
          'Put out fruit (4 shotgun pans of fruit, 2 of specialty food)',
          'Put out any special condiments to salad bar',
          'Put up allergen signs',
          'Put utensils in the peanut butter, and butter next to Aloha plate',
          'Make sure the condiment stands are stocked',
          'Put spoons in the fruit',
        ],
        'During Shift': [
          'Ensure everything stays stocked: fruit, condiments, and salad bar condiments',
        ],
        'Cleanup': [
          'Wrap and put away the specialty food',
          'Wrap the fruit, leave it in place, and leave the cooler on',
          'Put away the allergen signs',
          'Wipe down the fruit bar',
          'Wipe down all the condiment bars',
          'Wipe down the condiment area of the salad bar',
          'Move salad bar condiments to the student table',
        ],
      },
    },
    'Dinner': {
      'Ice Cream': {
        'Setup': [
          'Get ice cream',
          'Get scoops',
          'Get bowls',
          'Get water as needed',
        ],
        'During Shift': ['Serve ice cream'],
        'Cleanup': [
          'Dirty trays/utensils taken to scullery',
          'Dessert plates restocked',
          'Desserts put away in correct spot',
          'Counters/surfaces cleaned and dried',
          'Floor swept',
          'Cereal bowls restocked',
          'Silverware restocked',
        ],
      },
      'Paninis': {
        'Setup': ['Turn on panini machines'],
        'During Shift': [
          'Prepare paninis',
          'Press paninis in machines',
          'Cut paninis',
          'Put paninis out for service',
        ],
        'Cleanup': [
          'Panini presses and tools cleaned',
          'Surfaces wiped and floor swept',
          'Heated shelf off and cleaned',
        ],
      },
      'Line Runner': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Aloha Plate': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Choices': {
        'Setup': [
          'Fill wells with water',
          'Turn on heat',
          'Turn on heating elements',
          'Put food out in correct order',
          'Get utensils',
          'Prepare plate stacks',
        ],
        'During Shift': [
          'Keep food stocked',
          'Communicate with chefs as needed',
          'Put plates out 10 at a time',
          'Keep track of plate counts',
        ],
        'Cleanup': [
          'Plates/bowls restocked',
          'Heaters off',
          'Surfaces clean and dry',
          'Drain closed and bucket empty',
          'Floors swept (including under station)',
          'Trash emptied',
        ],
      },
      'Beverages': {
        'Setup': [
          'Ensure all beverages are stocked',
          'Turn on beverage machines',
        ],
        'During Shift': [
          'Restock cups',
          'Check bib room for soda stock',
          'Ensure sodas are stocked',
          'Ensure juices are stocked',
          'Ensure all beverage stations remain stocked',
        ],
        'Cleanup': [
          'Milks and juices restocked',
          'Milk/soda/juice machines cleaned',
          'Cups filled',
          'Ice filled',
          'Scissors cleaned',
          'Milk trays cleaned',
          'Coke machine nozzles (dinner)',
          'Blue crates to Empire Crate Building',
          'Empire Crate Building wrapped',
          'Vitamin waters restocked',
          'BIB room checked',
        ],
      },
      'Senior Cash': {
        'Setup': ['Sign into register', 'Verify register is ready'],
        'During Shift': ['Ring up senior missionaries'],
        'Cleanup': [
          'Napkins and salt/pepper',
          'Sanitizer and paper towels',
          'Lost and found items to front desk',
          'Write next meal menu on door',
          'Refill sanitizer bottles',
          'Sweep tile floor',
        ],
      },
      'Junior Cash': {
        'Setup': ['Sign into register'],
        'During Shift': [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries without cards',
        ],
        'Cleanup': [
          'Napkins and salt/pepper',
          'Sanitizer and paper towels',
          'Lost and found items to front desk',
          'Write next meal menu on door',
          'Refill sanitizer bottles',
          'Sweep tile floor',
        ],
      },
      'Desserts': {
        'Setup': [
          'Put out desserts',
          'Breakfast: donuts',
          'Lunch/Dinner: cookies or assigned desserts',
          'Put out plates',
          'Put out utensils',
        ],
        'During Shift': ['Keep desserts stocked', 'Keep utensils stocked'],
        'Cleanup': [
          'Dirty trays/utensils taken to scullery',
          'Dessert plates restocked',
          'Desserts put away in correct spot',
          'Counters/surfaces cleaned and dried',
          'Floor swept',
          'Cereal bowls restocked',
          'Silverware restocked',
        ],
      },
      'Condiments Prep': {
        'Setup': [
          'Ensure condiment cart is full',
          'Assist condiments host with setup',
        ],
        'During Shift': [
          'Keep condiments stocked',
          'Prepare condiments for next meal',
          'If dinner: prepare condiments for breakfast bar next day',
        ],
        'Cleanup': [
          'Enough prepped for next meal',
          'Specialty condiments prepped',
          'PB, J, and butter prepped',
          'Prep surfaces cleaned and dried',
          'Toaster station cleaned and restocked',
          'Condiment dispensers clean and full',
          'Pump station swept under',
          'Fruit bar surfaces cleaned and dried',
          'Bowls/plates restocked on fruit bar',
        ],
      },
      'Condiments Host': {
        'Setup': [
          'Turn on fruit bar cooler',
          'Put out fruit (4 shotgun pans of fruit, 2 of specialty food)',
          'Put out any special condiments to salad bar',
          'Put up allergen signs',
          'Put utensils in the peanut butter, and butter next to Aloha plate',
          'Make sure the condiment stands are stocked',
          'Put spoons in the fruit',
        ],
        'During Shift': [
          'Ensure everything stays stocked: fruit, condiments, and salad bar condiments',
        ],
        'Cleanup': [
          'Wrap and put away the specialty food',
          'Wrap the fruit, leave it in place, and leave the cooler on',
          'Put away the allergen signs',
          'Wipe down the fruit bar',
          'Wipe down all the condiment bars',
          'Wipe down the condiment area of the salad bar',
          'Move salad bar condiments to the student table',
        ],
      },
    },
  };

  List<String> _extractAlohaChoices(Map<String, dynamic> data) {
    final jobs = data['jobs'] as Map<String, dynamic>? ?? const {};
    final aloha = jobs['aloha_plate'] as Map<String, dynamic>? ?? const {};
    final alohaLeftovers =
        jobs['aloha_dinner_leftovers'] as Map<String, dynamic>? ?? const {};
    final choices =
        jobs['choices_leftovers'] as Map<String, dynamic>? ?? const {};
    final lines = <String>['Aloha Plate:'];
    lines.addAll(
      ((aloha['general_operational_notes'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    lines.add('Aloha Dinner Leftovers:');
    lines.addAll(
      ((alohaLeftovers['general_info'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    lines.add('Choices Leftovers:');
    lines.addAll(
      ((choices['general_info'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.addAll(
      ((choices['end_of_day'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    return lines;
  }

  Widget _buildAlohaChoicesPanel(Map<String, dynamic> data) {
    final jobs = data['jobs'] as Map<String, dynamic>? ?? const {};
    final aloha = jobs['aloha_plate'] as Map<String, dynamic>? ?? const {};
    final alohaLeftovers =
        jobs['aloha_dinner_leftovers'] as Map<String, dynamic>? ?? const {};
    final choices =
        jobs['choices_leftovers'] as Map<String, dynamic>? ?? const {};

    List<String> listFor(Map<String, dynamic> source, String key) {
      return ((source[key] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    final cards = <({String title, List<String> items})>[
      (
        title: 'Aloha Plate',
        items: [
          ...listFor(aloha, 'general_operational_notes'),
          ...listFor(aloha, 'food_specific_instructions'),
          ...listFor(aloha, 'equipment_instructions'),
        ],
      ),
      (
        title: 'Aloha Dinner Leftovers',
        items: [
          ...listFor(alohaLeftovers, 'general_info'),
          ...listFor(alohaLeftovers, 'end_of_day'),
        ],
      ),
      (
        title: 'Choices Leftovers',
        items: [
          ...listFor(choices, 'general_info'),
          ...listFor(choices, 'end_of_day'),
          ...listFor(choices, 'unclear'),
        ],
      ),
    ];

    return _buildReferencePanel(
      title: 'Aloha + Choices',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final card in cards) ...[
            _buildReferenceTaskCard(
              title: card.title,
              items: card.items.isEmpty
                  ? const ['No extra notes listed.']
                  : card.items,
              icon: Icons.menu_book_outlined,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  List<String> _extractCondiments(Map<String, dynamic> data) {
    final rotation =
        data['condiments_rotation'] as Map<String, dynamic>? ?? const {};
    final lines = <String>[];
    lines.addAll(
      ((rotation['shared_notes'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    for (final color in const ['green', 'blue', 'yellow', 'pink']) {
      final colorMap = rotation[color] as Map<String, dynamic>? ?? const {};
      lines.add('${color[0].toUpperCase()}${color.substring(1)} Menu:');
      for (final day in const [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ]) {
        final dayMap = colorMap[day] as Map<String, dynamic>? ?? const {};
        final breakfast = (dayMap['breakfast'] as List<dynamic>? ?? const [])
            .join(', ');
        final lunch = (dayMap['lunch'] as List<dynamic>? ?? const []).join(
          ', ',
        );
        final dinner = (dayMap['dinner'] as List<dynamic>? ?? const []).join(
          ', ',
        );
        lines.add(
          '- ${day[0].toUpperCase()}${day.substring(1)} | B: ${breakfast.isEmpty ? 'none' : breakfast} | L: ${lunch.isEmpty ? 'none' : lunch} | D: ${dinner.isEmpty ? 'none' : dinner}',
        );
      }
      lines.add('');
    }
    return lines;
  }

  List<String> _extractFoodPrep(Map<String, dynamic> data) {
    final prep = data['food_prep'] as Map<String, dynamic>? ?? const {};
    final grapes = prep['grapes'] as Map<String, dynamic>? ?? const {};
    final kiwi = prep['kiwi'] as Map<String, dynamic>? ?? const {};
    final lines = <String>['Grapes:'];
    lines.addAll(
      ((grapes['preparation_steps'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    lines.add('Kiwi:');
    lines.addAll(
      ((kiwi['preparation_steps'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    return lines;
  }

  List<String> _extractMealTimes(Map<String, dynamic> data) {
    final mealTimes = data['meal_times'] as Map<String, dynamic>? ?? const {};
    final lines = <String>[];
    for (final day in const [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ]) {
      final dayMap = mealTimes[day] as Map<String, dynamic>? ?? const {};
      final b = dayMap['breakfast'] as Map<String, dynamic>? ?? const {};
      final l = dayMap['lunch'] as Map<String, dynamic>? ?? const {};
      final d = dayMap['dinner'] as Map<String, dynamic>? ?? const {};
      lines.add(
        '- ${day[0].toUpperCase()}${day.substring(1)} | Breakfast ${b['start_time'] ?? '--'}-${b['end_time'] ?? '--'} | Lunch ${l['start_time'] ?? '--'}-${l['end_time'] ?? '--'} | Dinner ${d['start_time'] ?? '--'}-${d['end_time'] ?? '--'}',
      );
    }
    return lines;
  }

  List<String> _extractSafety(Map<String, dynamic> data) {
    final safety = data['food_safety'] as Map<String, dynamic>? ?? const {};
    final glove = safety['glove_rules'] as Map<String, dynamic>? ?? const {};
    final holding =
        safety['holding_temps'] as Map<String, dynamic>? ?? const {};
    final lines = <String>['Glove Rules:'];
    lines.addAll(
      ((glove['decision_flow'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    lines.add('Safe Food Temperatures:');
    final mins =
        (holding['minimum_temperatures'] as List<dynamic>?) ?? const [];
    for (final row in mins) {
      final m = row as Map<String, dynamic>;
      lines.add('- ${m['food']}: ${m['temp_f']}F (${m['time']})');
    }
    return lines;
  }

  List<String> _extractSecondaryAndCheckoff(Map<String, dynamic> data) {
    final general =
        data['general_reference'] as Map<String, dynamic>? ?? const {};
    final sec =
        general['line_secondary_jobs'] as Map<String, dynamic>? ?? const {};
    final check =
        general['lead_supervisor_checkoff'] as Map<String, dynamic>? ??
        const {};
    final lines = <String>['Line Secondary Jobs - While Doors Open:'];
    lines.addAll(
      ((sec['while_doors_are_open'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    lines.add('Line Secondary Jobs - After Doors Close:');
    lines.addAll(
      ((sec['after_doors_closed'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    lines.add('Supervisor Check-off:');
    lines.addAll(
      ((check['supervisor_checkoff'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    lines.add('');
    lines.add('Lead Trainer Check-off:');
    lines.addAll(
      ((check['lead_trainer_checkoff'] as List<dynamic>?) ?? const []).map(
        (e) => '- $e',
      ),
    );
    return lines;
  }

  Widget _buildReadableLines(List<String> lines) {
    // Convert plain text lines into a readable hierarchy so the source JSON can
    // stay simple while the UI still looks intentional.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) ...[
          if (line.isEmpty)
            const SizedBox(height: 8)
          else if (line.endsWith(':'))
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 6),
              child: Text(
                line,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123A65),
                ),
              ),
            )
          else if (line.startsWith('- '))
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '- ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(child: Text(line.substring(2))),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(line),
            ),
        ],
      ],
    );
  }

  Widget _buildReferencePanel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF123A65),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildReferenceTaskCard({
    required String title,
    required List<String> items,
    IconData icon = Icons.task_alt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1A4E8A)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF123A65),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 7,
                    width: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A4E8A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF244668),
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceSummaryChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFB6C9E4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A4E8A),
        ),
      ),
    );
  }

  Widget _buildCondimentsRotationFlow(Map<String, dynamic> data) {
    // This is reference-only. The stepped flow narrows the visible condiment
    // list without implying that workers are "completing" anything.
    final rotation =
        data['condiments_rotation'] as Map<String, dynamic>? ?? const {};
    final colorMap =
        rotation[_selectedCondimentColor] as Map<String, dynamic>? ?? const {};
    final dayMap =
        colorMap[_selectedCondimentDay] as Map<String, dynamic>? ?? const {};
    final mealKey = _selectedCondimentMeal.toLowerCase();
    final condiments = ((dayMap[mealKey] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();

    return _buildReferencePanel(
      title: 'Condiments Rotation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_condimentStep == 0) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedCondimentColor,
              decoration: const InputDecoration(labelText: 'Week Color'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'green', child: Text('Green')),
                DropdownMenuItem(value: 'blue', child: Text('Blue')),
                DropdownMenuItem(value: 'yellow', child: Text('Yellow')),
                DropdownMenuItem(value: 'pink', child: Text('Pink')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCondimentColor = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _condimentStep = 1),
                child: const Text('Next'),
              ),
            ),
          ] else if (_condimentStep == 1) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedCondimentDay,
              decoration: const InputDecoration(labelText: 'Day'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'monday', child: Text('Monday')),
                DropdownMenuItem(value: 'tuesday', child: Text('Tuesday')),
                DropdownMenuItem(value: 'wednesday', child: Text('Wednesday')),
                DropdownMenuItem(value: 'thursday', child: Text('Thursday')),
                DropdownMenuItem(value: 'friday', child: Text('Friday')),
                DropdownMenuItem(value: 'saturday', child: Text('Saturday')),
                DropdownMenuItem(value: 'sunday', child: Text('Sunday')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCondimentDay = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _condimentStep = 2),
                child: const Text('Next'),
              ),
            ),
          ] else if (_condimentStep == 2) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedCondimentMeal,
              decoration: const InputDecoration(labelText: 'Meal'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCondimentMeal = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _condimentStep = 3),
                child: const Text('Next'),
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReferenceSummaryChip(_toTitle(_selectedCondimentColor)),
                _buildReferenceSummaryChip(_toDayTitle(_selectedCondimentDay)),
                _buildReferenceSummaryChip(_selectedCondimentMeal),
              ],
            ),
            const SizedBox(height: 10),
            _buildReferenceTaskCard(
              title: condiments.isEmpty ? 'No Extra Condiments' : 'Put Out',
              items: condiments.isEmpty
                  ? const ['Nothing extra for this selection.']
                  : condiments,
              icon: Icons.kitchen_outlined,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(
                  () => _condimentStep = (_condimentStep - 1).clamp(0, 3),
                ),
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLineJobsFlow(Map<String, dynamic> data) {
    final jobsForMeal = _mealLineJobs[_selectedLineMeal] ?? const <String>[];
    if (_selectedLineJobKey == null && jobsForMeal.isNotEmpty) {
      _selectedLineJobKey = jobsForMeal.first;
    }
    if (_selectedLineJobKey != null &&
        !jobsForMeal.contains(_selectedLineJobKey)) {
      _selectedLineJobKey = jobsForMeal.isEmpty ? null : jobsForMeal.first;
    }

    // Line-job references mirror the real worker phases so the mental model is
    // consistent between the read-only reference and the actual shift flow.
    final selectedPhases = _selectedLineJobKey == null
        ? const <String, List<String>>{}
        : (_lineReferenceCatalog[_selectedLineMeal]?[_selectedLineJobKey!] ??
              const <String, List<String>>{});

    return _buildReferencePanel(
      title: 'Line Jobs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lineStep == 0) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedLineMeal,
              decoration: const InputDecoration(labelText: 'Meal'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedLineMeal = value;
                  final mealJobs = _mealLineJobs[value] ?? const <String>[];
                  _selectedLineJobKey = mealJobs.isEmpty
                      ? null
                      : mealJobs.first;
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _lineStep = 1),
                child: const Text('Next'),
              ),
            ),
          ] else if (_lineStep == 1) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedLineJobKey,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Job'),
              items: jobsForMeal
                  .map(
                    (job) =>
                        DropdownMenuItem<String>(value: job, child: Text(job)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedLineJobKey = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedLineJobKey == null
                    ? null
                    : () => setState(() => _lineStep = 2),
                child: const Text('Next'),
              ),
            ),
          ] else ...[
            Text(
              '$_selectedLineMeal • ${_selectedLineJobKey ?? '-'}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A4E8A),
              ),
            ),
            const SizedBox(height: 12),
            if (selectedPhases.isEmpty)
              const Text(
                'No job notes available for this selection.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF355678),
                ),
              )
            else ...[
              if ((selectedPhases['Setup'] ?? const <String>[]).isNotEmpty) ...[
                _buildReferenceTaskCard(
                  title: 'Setup',
                  items: selectedPhases['Setup'] ?? const <String>[],
                  icon: Icons.playlist_add_check_circle_outlined,
                ),
                const SizedBox(height: 10),
              ],
              if ((selectedPhases['During Shift'] ?? const <String>[])
                  .isNotEmpty) ...[
                _buildReferenceTaskCard(
                  title: 'During Shift',
                  items: selectedPhases['During Shift'] ?? const <String>[],
                  icon: Icons.sync_alt,
                ),
                const SizedBox(height: 10),
              ],
              if ((selectedPhases['Cleanup'] ?? const <String>[]).isNotEmpty)
                _buildReferenceTaskCard(
                  title: 'Cleanup',
                  items: selectedPhases['Cleanup'] ?? const <String>[],
                  icon: Icons.cleaning_services_outlined,
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    setState(() => _lineStep = (_lineStep - 1).clamp(0, 2)),
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLockerFlow(Map<String, dynamic> data) {
    // Workers usually know the item they need, not the locker number, so the
    // experience starts from search instead of a locker list.
    final lockerData =
        data['locker_inventory'] as Map<String, dynamic>? ?? const {};
    final search = _lockerSearchQuery.trim().toLowerCase();
    final lockerKeys = ['5', '6', '7', '8', '9'];

    final matchesByLocker = <String, List<String>>{};
    if (search.isNotEmpty) {
      for (final locker in lockerKeys) {
        final items = ((lockerData[locker] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .where((item) => item.toLowerCase().contains(search))
            .toList();
        if (items.isNotEmpty) {
          matchesByLocker[locker] = items;
        }
      }
    }

    return _buildReferencePanel(
      title: 'Find an Item',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _lockerSearchController,
            decoration: InputDecoration(
              labelText: 'Find an item',
              hintText: 'Example: gloves, syrup, ranch',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _lockerSearchQuery.trim().isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: () {
                        _lockerSearchController.clear();
                        setState(() => _lockerSearchQuery = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
            onChanged: (value) => setState(() => _lockerSearchQuery = value),
          ),
          const SizedBox(height: 12),
          if (search.isEmpty)
            const Text(
              'Search for an item to find its locker.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF355678),
              ),
            )
          else if (matchesByLocker.isEmpty)
            Text(
              'No locker match found for "$_lockerSearchQuery".',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF123A65),
              ),
            )
          else
            ...matchesByLocker.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReferenceTaskCard(
                  title: 'Locker ${entry.key}',
                  items: entry.value,
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLineSecondaryFlow(Map<String, dynamic> data) {
    final general =
        data['general_reference'] as Map<String, dynamic>? ?? const {};
    final sec =
        general['line_secondary_jobs'] as Map<String, dynamic>? ?? const {};
    final check =
        general['lead_supervisor_checkoff'] as Map<String, dynamic>? ??
        const {};
    final shiftSpecific =
        sec['shift_specific_secondaries'] as Map<String, dynamic>? ?? const {};
    final mealKey = _lineSecondaryMeal.toLowerCase();

    final whileOpen =
        ((sec['while_doors_are_open'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final afterClose =
        ((sec['after_doors_closed'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final mealSpecific =
        ((shiftSpecific[mealKey] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final supervisor =
        ((check['supervisor_checkoff'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();
    final trainer =
        ((check['lead_trainer_checkoff'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList();

    final selectedLines = switch (_lineSecondaryGroup) {
      'While Doors Open' => whileOpen,
      'After Doors Close' => afterClose,
      'Shift-Specific' => mealSpecific,
      'Supervisor Checkoff' => supervisor,
      'Lead Trainer Checkoff' => trainer,
      _ => const <String>[],
    };

    return _buildReferencePanel(
      title: 'Line Secondary + Checkoff',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lineSecondaryStep == 0) ...[
            DropdownButtonFormField<String>(
              initialValue: _lineSecondaryMeal,
              decoration: const InputDecoration(labelText: 'Meal'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _lineSecondaryMeal = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _lineSecondaryStep = 1),
                child: const Text('Next'),
              ),
            ),
          ] else if (_lineSecondaryStep == 1) ...[
            DropdownButtonFormField<String>(
              initialValue: _lineSecondaryGroup,
              decoration: const InputDecoration(labelText: 'Section'),
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'While Doors Open',
                  child: Text('While Doors Open'),
                ),
                DropdownMenuItem(
                  value: 'After Doors Close',
                  child: Text('After Doors Close'),
                ),
                DropdownMenuItem(
                  value: 'Shift-Specific',
                  child: Text('Shift-Specific'),
                ),
                DropdownMenuItem(
                  value: 'Supervisor Checkoff',
                  child: Text('Supervisor Checkoff'),
                ),
                DropdownMenuItem(
                  value: 'Lead Trainer Checkoff',
                  child: Text('Lead Trainer Checkoff'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _lineSecondaryGroup = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _lineSecondaryStep = 2),
                child: const Text('Next'),
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReferenceSummaryChip(_lineSecondaryMeal),
                _buildReferenceSummaryChip(_lineSecondaryGroup),
              ],
            ),
            const SizedBox(height: 10),
            _buildReferenceTaskCard(
              title: _lineSecondaryGroup,
              items: selectedLines.isEmpty
                  ? const ['No items listed for this selection.']
                  : selectedLines,
              icon: _lineSecondaryGroup.contains('Checkoff')
                  ? Icons.fact_check_outlined
                  : Icons.checklist_rtl_outlined,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(
                  () =>
                      _lineSecondaryStep = (_lineSecondaryStep - 1).clamp(0, 2),
                ),
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiningMapPanel(BuildContext context) {
    // InteractiveViewer provides zoom/pan without introducing a separate map
    // library for what is ultimately a static floorplan image.
    return _buildReferencePanel(
      title: 'Dining Map',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pinch to zoom and drag to move.',
                  style: TextStyle(
                    color: Color(0xFF355678),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    _mapTransformationController.value = Matrix4.identity(),
                icon: const Icon(Icons.center_focus_strong, size: 18),
                label: const Text('Reset View'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = MediaQuery.of(context).size.width < 760;
              final mapHeight = isMobile ? 430.0 : 640.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.white,
                  constraints: BoxConstraints(
                    minHeight: mapHeight,
                    maxHeight: mapHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: InteractiveViewer(
                    transformationController: _mapTransformationController,
                    minScale: 1.0,
                    maxScale: 6.0,
                    boundaryMargin: const EdgeInsets.all(120),
                    panEnabled: true,
                    child: Image.asset(
                      'assets/reference/MTC Dining Map (1).png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topLeft,
                      errorBuilder: (_, _, _) => const Center(
                        child: Text('Could not load dining map image.'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
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
        final sections = <String, List<String>>{
          'Line Jobs': const [],
          'Aloha + Choices': _extractAlohaChoices(data),
          'Condiments Rotation': _extractCondiments(data),
          if (!_runtimeConfig.isPilotProfile)
            'Fruit Prep (Grapes/Kiwi)': _extractFoodPrep(data),
          if (!_runtimeConfig.isPilotProfile)
            'Meal Door Times': _extractMealTimes(data),
          if (!_runtimeConfig.isPilotProfile)
            'Food Safety': _extractSafety(data),
          'Line Secondary + Checkoff': _extractSecondaryAndCheckoff(data),
        };
        final lockedStandaloneSections = <String>{'Find an Item', 'Dining Map'};
        _selectedSection =
            _selectedSection == 'Select' ||
                sections.containsKey(_selectedSection) ||
                (widget.lockSection &&
                    lockedStandaloneSections.contains(_selectedSection))
            ? _selectedSection
            : 'Select';

        final lines = sections[_selectedSection] ?? const <String>[];
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lockSection
                            ? widget.initialSection
                            : 'Reference Sheets',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (!widget.lockSection) ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSection,
                          decoration: const InputDecoration(
                            labelText: 'Section',
                          ),
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
                            setState(() {
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
                          },
                        ),
                        const SizedBox(height: 14),
                      ] else
                        const SizedBox(height: 10),
                      _selectedSection == 'Select'
                          ? const SizedBox.shrink()
                          : _selectedSection == 'Line Jobs'
                          ? _buildLineJobsFlow(data)
                          : _selectedSection == 'Find an Item'
                          ? _buildLockerFlow(data)
                          : _selectedSection == 'Line Secondary + Checkoff'
                          ? _buildLineSecondaryFlow(data)
                          : _selectedSection == 'Condiments Rotation'
                          ? _buildCondimentsRotationFlow(data)
                          : _selectedSection == 'Aloha + Choices'
                          ? _buildAlohaChoicesPanel(data)
                          : _selectedSection == 'Dining Map'
                          ? _buildDiningMapPanel(context)
                          : Container(
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
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
