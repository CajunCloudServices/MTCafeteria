part of 'package:frontend_flutter/pages/reference_sheets_view.dart';

extension _ReferenceExtractors on _ReferenceSheetsViewState {
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
      title: '',
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
}
