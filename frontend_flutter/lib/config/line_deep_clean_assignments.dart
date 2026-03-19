const List<String> lineDeepCleaningGeneralNotes = [
  'These assignments must be completed each shift.',
  'Talk to a Student Manager if you do not fully understand your assignment.',
];

const Map<String, Map<String, String>> lineDeepCleaningAssignments = {
  'monday': {
    'Breakfast':
        'Clean underneath beverage lines and steel polish metal trim on Line 6.',
    'Lunch':
        'Clean underneath beverage lines and steel polish metal trim on Line 1 and 2, including the nearest cereal station.',
    'Dinner':
        'Clean underneath beverage lines and steel polish metal trim on Line 4, including the nearest cereal station.',
  },
  'tuesday': {
    'Breakfast':
        'Sanitize and organize under shelves and the student table in Cafe West.',
    'Lunch': 'Deep clean the panini presses.',
    'Dinner':
        'Swap out and clean breakfast topping holders and large white tubs.',
  },
  'wednesday': {
    'Breakfast': 'Clean all of the sneeze guards.',
    'Lunch':
        'On serving lines, wipe underneath and scrub the white plastic boards.',
    'Dinner':
        'Wash dustpans in the pan machine, replace sheet pans on the first three racks in Locker 10, and discard condiments 3 days or older.',
  },
  'thursday': {
    'Breakfast':
        'Deep clean the right-side condiment dispensers in Cafe West and the condiment dispensers by D-100.',
    'Lunch':
        'Deep clean the left-side condiment dispensers and organize the station including underneath.',
    'Dinner':
        'Polish the metal trim and sanitize and organize underneath shelves and cupboards on the island.',
  },
  'friday': {
    'Breakfast': 'Defrost and sanitize the Blue Bunny ice cream freezer.',
    'Lunch':
        'Clean and organize under the fruit bar and wipe out the microwave.',
    'Dinner': 'Clean Cafe West warmers.',
  },
  'saturday': {
    'Breakfast': 'Maintain the mop closet and mop the BIB room.',
    'Lunch':
        'Wash red buckets in the pan machine at the end of shift and deep clean the dustpans with hose and Pantastic.',
    'Dinner': 'Maintain the Dish Return closet and Vacuum closet.',
  },
  'sunday': {
    'Breakfast':
        'Clean pillars in Cafe West and swap towel buckets under the student table and both serving lines.',
    'Lunch': 'Clean drip tubs under hanging rag bags in the custodial closet.',
    'Dinner': 'Spot mop and sweep the red floors.',
  },
};

String? lineDeepCleaningAssignmentFor(String dayKey, String meal) {
  return lineDeepCleaningAssignments[dayKey]?[meal];
}

List<String> flattenLineDeepCleaningAssignments() {
  final lines = <String>[...lineDeepCleaningGeneralNotes];
  lineDeepCleaningAssignments.forEach((day, meals) {
    meals.forEach((meal, assignment) {
      final dayTitle = '${day[0].toUpperCase()}${day.substring(1)}';
      lines.add('$dayTitle $meal: $assignment');
    });
  });
  return lines;
}
