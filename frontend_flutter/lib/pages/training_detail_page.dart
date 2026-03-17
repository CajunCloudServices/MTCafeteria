import 'package:flutter/material.dart';

import '../models/training.dart';

/// Full-screen two-minute training viewer with rotating daily default content.
class TrainingDetailPage extends StatefulWidget {
  const TrainingDetailPage({
    super.key,
    required this.today,
    required this.todaysTraining,
    required this.trainings,
  });

  final String? today;
  final Training? todaysTraining;
  final List<Training> trainings;

  @override
  State<TrainingDetailPage> createState() => _TrainingDetailPageState();
}

class _TrainingDetailPageState extends State<TrainingDetailPage> {
  // The pilot build uses transcribed content so trainings render reliably on
  // every supported surface.
  static const List<_TrainingTextContent> _trainings = [
    _TrainingTextContent(
      title: 'General Safety',
      objective:
          'Promote awareness of workplace accidents and how to prevent them by following proper safety procedures.',
      teachingIdea:
          'Quiz format: use each section as a question (for example, how proper dress code prevents accidents/injury).',
      sections: [
        _TrainingTextSection(
          heading: 'Clothing / Dress Code',
          bullets: [
            'How does following the proper dress code prevent accidents and injury?',
          ],
        ),
        _TrainingTextSection(
          heading: 'Burns',
          bullets: [
            'In what ways can you get burned, and what precautions can you take to avoid burns?',
          ],
        ),
        _TrainingTextSection(
          heading: 'Broken Glass',
          bullets: [
            'What do you do with broken glass? Where does it go?',
            'What can you do to prevent glass breakage?',
          ],
        ),
        _TrainingTextSection(
          heading: 'Wet Floors',
          bullets: [
            'When and where do we use wet floor signs?',
            'How do we clean up spills of any kind? (Spills need immediate cleanup.)',
            'Why should we clean up puddles in dishroom/scullery?',
          ],
        ),
        _TrainingTextSection(
          heading: 'Locker Doors',
          bullets: [
            'What injuries can happen when locker doors are opened improperly or too quickly? How can you prevent them?',
          ],
        ),
        _TrainingTextSection(
          heading: 'Dish Room Safety',
          bullets: [
            'Where do carts go in scullery? Where do cup racks go in dishroom?',
            'Where are knives cleaned? How are they cleaned?',
            'What else can you do to promote safety and prevent accidents in dishroom/scullery?',
          ],
        ),
      ],
    ),
    _TrainingTextContent(
      title: 'Medical Emergencies I',
      objective:
          'Make sure workers know how to appropriately respond to a medical emergency at work.',
      generalGuidelines: [
        'In an emergency, call 911, then call MTC Security (801-422-9000).',
        'Notify the supervisor as soon as possible.',
        'If a worker is injured (even minor), have a supervisor record it so the MTC can cover medical expenses if needed.',
      ],
      sections: [
        _TrainingTextSection(
          heading: 'Bleeding',
          bullets: [
            'Put on disposable gloves before helping someone who is bleeding.',
            'Apply pressure to stop bleeding.',
            'For a minor cut: clean wound, apply antibiotic, and use a bandage.',
            'If an object is embedded, do not remove it; apply pressure around it.',
            'If bleeding is severe, call 911.',
            'Wash your hands thoroughly after assisting.',
          ],
        ),
        _TrainingTextSection(
          heading: 'Sprain / Fracture',
          bullets: [
            'Keep the body still and stabilize with a splint if needed.',
            "If there's a severe fracture, do not move or set bones; wait for medical help.",
            'Apply ice packs to reduce swelling.',
          ],
        ),
        _TrainingTextSection(
          heading: 'Burns',
          bullets: [
            'First degree: remove hot item, cool with running water (not cold), apply burn gel, lightly bandage.',
            'Second degree (blisters): treat similarly and seek medical attention.',
            "Third degree: call 911, remove from source safely, don't apply water, monitor breathing/shock, loosely cover wound.",
          ],
        ),
      ],
    ),
    _TrainingTextContent(
      title: 'Medical Emergencies II',
      objective:
          'Make sure workers know how to appropriately respond to a medical emergency at work.',
      generalGuidelines: [
        'In an emergency, call 911, then call MTC Security (801-422-9000).',
        'Notify the supervisor as soon as possible.',
        'If a worker is injured (even minor), have a supervisor record it so the MTC can cover medical expenses if needed.',
      ],
      sections: [
        _TrainingTextSection(
          heading: 'Heat Exhaustion',
          bullets: [
            'Symptoms: heavy sweating, faintness, dizziness, fatigue, weak/rapid pulse.',
            'Move the person to a cool or air-conditioned area.',
            'Lay the person down and elevate legs/feet slightly.',
            'Give chilled water and remove tight clothing.',
          ],
        ),
        _TrainingTextSection(
          heading: 'Shock',
          bullets: [
            'Symptoms: clammy skin, confusion, dizziness, weak pulse, rapid breathing, nausea/vomiting.',
            'Call emergency services and monitor breathing/circulation (CPR may be needed).',
            'Lay person down, elevate legs, loosen tight clothing, and keep them warm.',
          ],
        ),
        _TrainingTextSection(
          heading: 'Heart Attack',
          bullets: [
            'Symptoms: chest pain/pressure/tightness, upper-body pain, shortness of breath, nausea, faintness.',
            'Call emergency services immediately and alert MTC Security.',
            'Clear the area so trained responders can assist quickly.',
          ],
        ),
      ],
    ),
    _TrainingTextContent(
      title: 'Medical Emergencies III',
      objective:
          'Make sure workers know how to appropriately respond to a medical emergency at work.',
      generalGuidelines: [
        'In an emergency, call 911, then call MTC Security (801-422-9000).',
        'Notify the supervisor as soon as possible.',
        'If a worker is injured (even minor), have a supervisor record it so the MTC can cover medical expenses if needed.',
      ],
      sections: [
        _TrainingTextSection(
          heading: 'Stroke (F.A.S.T.)',
          bullets: [
            'Face drooping: ask them to smile; one side may droop.',
            'Arm weakness: ask them to raise both arms; one may drift down.',
            'Speech changes: ask for a phrase; speech may be slurred/wrong.',
            'Time to call 911: act immediately, even if symptoms improve.',
          ],
        ),
        _TrainingTextSection(
          heading: 'Seizure',
          bullets: [
            'Stay calm and help others stay calm.',
            "Guide the person to the ground if possible; don't restrain movements.",
            'Set the person on their side to support breathing.',
            'Place a jacket/padding under the head and clear nearby hazards.',
            'Time the seizure. Call 911 if seizure lasts over 5 minutes, repeats, or injury/medical condition is present.',
          ],
        ),
      ],
    ),
  ];

  int _selectedTrainingIndex = 0;
  bool _showAllTrainings = false;

  @override
  void initState() {
    super.initState();
    _selectedTrainingIndex = _rotationIndexForToday();
  }

  /// Rotation is calendar-based so the highlighted training advances daily
  /// without requiring per-day backend assignments.
  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int _rotationIndexForToday() {
    if (_trainings.isEmpty) return 0;
    return _rotationIndexForDate(_todayDateOnly());
  }

  int _rotationIndexForDate(DateTime date) {
    if (_trainings.isEmpty) return 0;
    final cycleStart = DateTime(2026, 3, 16);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final delta = dateOnly.difference(cycleStart).inDays;
    final length = _trainings.length;
    return ((delta % length) + length) % length;
  }

  String _trainingTitleFor(int index) => _trainings[index].title;

  DateTime _trainingDateFor(int index) {
    final today = _todayDateOnly();
    final delta =
        (index - _selectedTrainingIndex + _trainings.length) %
        _trainings.length;
    return today.add(Duration(days: delta));
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _selectTraining(int index) {
    setState(() {
      _selectedTrainingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedTraining = _trainings[_selectedTrainingIndex];
    final displayDate = _formatDate(_trainingDateFor(_selectedTrainingIndex));

    return Scaffold(
      appBar: AppBar(title: const Text('2-Minute Trainings')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;
          final picker = Container(
            width: isWide ? 340 : double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF1F5E9C).withValues(alpha: 0.24),
              ),
            ),
            child: isWide
                ? ListView.separated(
                    itemCount: _trainings.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTrainingIndex == index;
                      final date = _formatDate(_trainingDateFor(index));
                      return InkWell(
                        onTap: () => _selectTraining(index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE6F0FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1F5E9C)
                                  : const Color(0xFFB3C7E2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _trainingTitleFor(index),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF123A65),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date,
                                style: const TextStyle(
                                  color: Color(0xFF4E6786),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                  )
                : SizedBox(
                    height: 116,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trainings.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedTrainingIndex == index;
                        return InkWell(
                          onTap: () => _selectTraining(index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 186,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE6F0FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1F5E9C)
                                    : const Color(0xFFB3C7E2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _trainingTitleFor(index),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF123A65),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Tap to view',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF1F5E9C,
                                    ).withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                    ),
                  ),
          );

          final viewer = Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF1F5E9C).withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Text(
                    displayDate,
                    style: const TextStyle(
                      color: Color(0xFF4E6786),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF4FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF9FB6D3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedTraining.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF123A65),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedTraining.objective,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E4E70),
                                  height: 1.35,
                                ),
                              ),
                              if (selectedTraining.teachingIdea != null &&
                                  selectedTraining.teachingIdea!
                                      .trim()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  selectedTraining.teachingIdea!,
                                  style: const TextStyle(
                                    color: Color(0xFF365A80),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (selectedTraining.generalGuidelines.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F4E6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFD4BC8D),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'General Guidelines',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF5B3F11),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...selectedTraining.generalGuidelines.map(
                                  (line) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '- ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Expanded(child: Text(line)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        ...selectedTraining.sections.map(
                          (section) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFB3C7E2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section.heading,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF123A65),
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...section.bullets.map(
                                    (line) => Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '- ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              line,
                                              style: const TextStyle(
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _showAllTrainings
                      ? isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  picker,
                                  const SizedBox(width: 12),
                                  Expanded(child: viewer),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  picker,
                                  const SizedBox(height: 10),
                                  Expanded(child: viewer),
                                ],
                              )
                      : viewer,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _showAllTrainings = !_showAllTrainings),
                    child: Text(_showAllTrainings ? 'Hide all' : 'See all'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Structured text representation of a training sheet.
class _TrainingTextContent {
  const _TrainingTextContent({
    required this.title,
    required this.objective,
    required this.sections,
    this.teachingIdea,
    this.generalGuidelines = const [],
  });

  final String title;
  final String objective;
  final String? teachingIdea;
  final List<String> generalGuidelines;
  final List<_TrainingTextSection> sections;
}

/// A single heading/bullet group within a training.
class _TrainingTextSection {
  const _TrainingTextSection({required this.heading, required this.bullets});

  final String heading;
  final List<String> bullets;
}
