import 'package:flutter/material.dart';

/// Local checklist item used by the prototype support-track flows that are not
/// yet backed by shared API task data.
class LocalChecklistTask {
  const LocalChecklistTask({
    required this.id,
    required this.description,
    required this.requiresCheckoff,
  });

  final String id;
  final String description;
  final bool requiresCheckoff;
}

/// Local-only job definition for dishroom, kitchen jobs, and night custodial.
class LocalJobDefinition {
  const LocalJobDefinition({
    required this.name,
    required this.setup,
    required this.during,
    required this.cleanup,
  });

  final String name;
  final List<LocalChecklistTask> setup;
  final List<LocalChecklistTask> during;
  final List<LocalChecklistTask> cleanup;
}

const List<String> _localMeals = ['Breakfast', 'Lunch', 'Dinner'];

/// Converts `DateTime.weekday` values into labels used by local deep-clean
/// references.
String weekdayNameLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}

const List<LocalJobDefinition> dishroomJobs = [
  LocalJobDefinition(
    name: 'Pit Lead',
    setup: [
      LocalChecklistTask(
        id: 'pitlead-setup-1',
        description: 'Set pit station and verify spray tools are ready.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-setup-2',
        description: 'Confirm dish return flow and blue belt are clear.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'pitlead-during-1',
        description: 'Keep pit flowing and support crew with bottlenecks.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'pitlead-clean-1',
        description: 'Clean pulper.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-2',
        description: 'Paint station and rinse blue belt in dish return.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-3',
        description: 'Clear pit on low side.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-4',
        description: 'Spray out trap pans and remove food and trash.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-5',
        description: 'Scrub pit walls and island; remove all food.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Pit Crew',
    setup: [
      LocalChecklistTask(
        id: 'pitcrew-setup-1',
        description: 'Stage spray nozzles and PPE.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'pitcrew-during-1',
        description:
            'Maintain pit support and clear food buildup continuously.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'pitcrew-clean-1',
        description: 'Spray carousel trays and remove food.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-2',
        description: 'Spray lower pit wall.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-3',
        description: 'Spray out traps (3) and remove all food.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-4',
        description: 'Vacuum from pit drain.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-5',
        description: 'Clean floors.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Cups',
    setup: [
      LocalChecklistTask(
        id: 'cups-setup-1',
        description: 'Prepare cup machine and racks.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'cups-during-1',
        description: 'Keep cup flow moving and prevent rack backlog.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'cups-clean-1',
        description: 'Replace cup machine.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'cups-clean-2',
        description: 'Clean cup machine.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'cups-clean-3',
        description: 'Put cups away.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Silverware',
    setup: [
      LocalChecklistTask(
        id: 'silver-setup-1',
        description: 'Set silverware bins and machine area.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'silver-during-1',
        description: 'Sort silverware continuously and keep counters clear.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'silver-clean-1',
        description: 'Sort all silverware.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'silver-clean-2',
        description:
            'Place silverware container and set on counter in Cafe West.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'silver-clean-3',
        description: 'Clean silverware machine, clean and squeegee counters.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'silver-clean-4',
        description: 'Clean silverware area.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Loading',
    setup: [
      LocalChecklistTask(
        id: 'loading-setup-1',
        description: 'Prepare loading area and machine access.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'loading-during-1',
        description: 'Keep loading flow consistent and feed machines steadily.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'loading-clean-1',
        description: 'Spray blue belt and counter near loading area.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'loading-clean-2',
        description: 'Empty each dish machine.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'loading-clean-3',
        description: 'Clean first 2 sections of dish machine, including parts.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'loading-clean-4',
        description: 'Clean floors and drains near dish machine.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Unloading',
    setup: [
      LocalChecklistTask(
        id: 'unload-setup-1',
        description: 'Set unload carts and gloves basket.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'unload-during-1',
        description: 'Unload continuously and return clean dishes quickly.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'unload-clean-1',
        description: 'Clean unloading area of machine and remove all food.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'unload-clean-2',
        description: 'Wash rack cart and refill clean gloves basket.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'unload-clean-3',
        description: 'Wash dirty unloading gloves.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'unload-clean-4',
        description: 'Empty recycling.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Scullery',
    setup: [
      LocalChecklistTask(
        id: 'sc-setup-1',
        description: 'Set scullery and sorting carts.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'sc-during-1',
        description: 'Keep dish return sorted and clear.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'sc-clean-1',
        description: 'Put away all dishes and clean all carts.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'sc-clean-2',
        description: 'Clean sinks and machines.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'sc-clean-3',
        description: 'Clean wall.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'sc-clean-4',
        description: 'Take out trash.',
        requiresCheckoff: true,
      ),
    ],
  ),
];

List<LocalChecklistTask> dishroomDeepCleanTasksFor({
  required String meal,
  required int weekday,
}) {
  if (weekday == DateTime.saturday && meal == 'Breakfast') {
    return const [
      LocalChecklistTask(
        id: 'deep-sat-breakfast-1',
        description: 'Scrub blue cup conveyor attachments.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.saturday && meal == 'Lunch') {
    return const [
      LocalChecklistTask(
        id: 'deep-sat-lunch-1',
        description: 'Scrub blue cups.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.saturday && meal == 'Dinner') {
    return const [
      LocalChecklistTask(
        id: 'deep-sat-dinner-1',
        description: 'Wash steel wool dish machine or silverware machine.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.sunday && meal == 'Breakfast') {
    return const [
      LocalChecklistTask(
        id: 'deep-sun-breakfast-1',
        description: 'Clean walls and machines in dishroom.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.sunday && meal == 'Dinner') {
    return const [
      LocalChecklistTask(
        id: 'deep-sun-dinner-1',
        description: 'Clean floors between dishroom machines.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.monday) {
    return const [
      LocalChecklistTask(
        id: 'deep-mon-1',
        description: 'Clean/polish walls in dish return and scullery.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.tuesday) {
    return const [
      LocalChecklistTask(
        id: 'deep-tue-1',
        description: 'Pull out dish machine and clean floor around it.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.wednesday) {
    return const [
      LocalChecklistTask(
        id: 'deep-wed-1',
        description: 'Put cups, pans, and bowls into pan machine at shift end.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.thursday) {
    return const [
      LocalChecklistTask(
        id: 'deep-thu-1',
        description: 'Replace black bins and clean sink/counter area.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.friday) {
    return const [
      LocalChecklistTask(
        id: 'deep-fri-1',
        description: 'Clean wall/restroom and relabel with date.',
        requiresCheckoff: true,
      ),
    ];
  }
  return const [
    LocalChecklistTask(
      id: 'deep-generic-1',
      description: 'Complete todays assigned dishroom deep clean task.',
      requiresCheckoff: true,
    ),
  ];
}

const List<String> supervisorEndShiftCheckoffItems = [
  '1-on-1 for both dishroom and line (if applicable)',
  'Check discipline sheets: signed, filled out, and filed in binder/shelf',
  'Fill out the Service Missionary attendance sheet',
  'Ensure any first-day checklists are completed',
  'Confirm new employee buddy-system checkout is completed',
  'Ensure crate building has been wrapped',
  'Keep supervisor/lead trainer station organized',
  'Add maintenance issues with specific details to shift email',
  'Confirm deep-cleaning assignment has been completed',
  'Ensure all radios are returned and plugged in correctly',
  'Ensure all secondary jobs are done',
  'Assign shift shoutout and add to Google form',
  'Send correctly completed shift email',
];

const List<String> leadTrainerEndShiftCheckoffItems = [
  'Put away 2-minute trainings',
  'Put away allergen signs (including fresh bar for dinner)',
  'Enter all trainings in correct matrix with date, coaching notes, and your name',
  'Add training summary to shift email',
];

/// Worker-facing dishroom checklist flow.
class DishroomWorkerSection extends StatefulWidget {
  const DishroomWorkerSection({super.key, required this.resetSignal});

  final int resetSignal;

  @override
  State<DishroomWorkerSection> createState() => _DishroomWorkerSectionState();
}

class _DishroomWorkerSectionState extends State<DishroomWorkerSection> {
  int _step = 0;
  String _meal = _localMeals.first;
  String _jobName = dishroomJobs.first.name;
  final Map<String, bool> _checks = {};
  int _lastReset = 0;

  @override
  void initState() {
    super.initState();
    _lastReset = widget.resetSignal;
  }

  @override
  void didUpdateWidget(covariant DishroomWorkerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal != _lastReset) {
      _lastReset = widget.resetSignal;
      setState(() {
        _step = 0;
        _meal = _localMeals.first;
        _jobName = dishroomJobs.first.name;
        _checks.clear();
      });
    }
  }

  bool _allChecked(List<LocalChecklistTask> tasks) {
    final requiredTasks = tasks.where((t) => t.requiresCheckoff).toList();
    if (requiredTasks.isEmpty) return true;
    return requiredTasks.every((t) => _checks[t.id] ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final job = dishroomJobs.firstWhere((j) => j.name == _jobName);
    final setupDone = _allChecked(job.setup);
    final cleanupDone = _allChecked(job.cleanup);
    final deepCleanTasks = dishroomDeepCleanTasksFor(
      meal: _meal,
      weekday: DateTime.now().weekday,
    );
    final deepCleanDone = _allChecked(deepCleanTasks);

    if (_step >= 6) {
      return const SimpleFinishCard(
        title: 'Dishroom Shift Complete',
        message:
            'All dishroom tasks complete. Report to the dishroom lead trainer.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle(
              icon: Icons.cleaning_services,
              title: 'Dishroom Tasks',
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_step + 1) / 6,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: const Color(0xFFE2ECF8),
              color: const Color(0xFF1F5E9C),
            ),
            const SizedBox(height: 12),
            if (_step == 0) ...[
              const Text(
                'Step 1 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Choose meal for this dishroom shift.'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _meal,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Meal'),
                items: _localMeals
                    .map(
                      (meal) =>
                          DropdownMenuItem(value: meal, child: Text(meal)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _meal = value ?? _meal),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 1) ...[
              const Text(
                'Step 2 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Select your dishroom assignment.'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _jobName,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Dishroom Job'),
                items: dishroomJobs
                    .map(
                      (job) => DropdownMenuItem(
                        value: job.name,
                        child: Text(job.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _jobName = value ?? _jobName),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 2) ...[
              const Text(
                'Step 3 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Complete setup tasks.'),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'Setup (Before Doors Open)',
                tasks: job.setup,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: setupDone ? () => setState(() => _step = 3) : null,
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 3) ...[
              const Text(
                'Step 4 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Use during-shift tasks as your guide.'),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'During Shift (Doors Open)',
                tasks: job.during,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 4),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 4) ...[
              const Text(
                'Step 5 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Complete cleanup tasks.'),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'Cleanup (After Doors Close)',
                tasks: job.cleanup,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: cleanupDone
                      ? () => setState(() => _step = 5)
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 5) ...[
              const Text(
                'Step 6 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Deep clean tasks for ${weekdayNameLabel(DateTime.now().weekday)}.',
              ),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'Deep Clean',
                tasks: deepCleanTasks,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: deepCleanDone
                      ? () => setState(() => _step = 6)
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lead-trainer support flow for dishroom trainees.
class DishroomLeadTrainerSection extends StatefulWidget {
  const DishroomLeadTrainerSection({super.key, required this.resetSignal});

  final int resetSignal;

  @override
  State<DishroomLeadTrainerSection> createState() =>
      _DishroomLeadTrainerSectionState();
}

class _DishroomLeadTrainerSectionState
    extends State<DishroomLeadTrainerSection> {
  int _step = 0;
  String _meal = _localMeals.first;
  int _traineeCount = 1;
  int _selectedTrainee = 0;
  final Map<int, String?> _traineeJob = {0: null};
  final Map<int, Map<String, bool>> _traineeChecks = {};
  final Map<int, bool> _traineeCheckedOff = {};
  int _lastReset = 0;

  @override
  void initState() {
    super.initState();
    _lastReset = widget.resetSignal;
  }

  @override
  void didUpdateWidget(covariant DishroomLeadTrainerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal != _lastReset) {
      _lastReset = widget.resetSignal;
      setState(() {
        _step = 0;
        _meal = _localMeals.first;
        _traineeCount = 1;
        _selectedTrainee = 0;
        _traineeJob
          ..clear()
          ..[0] = null;
        _traineeChecks.clear();
        _traineeCheckedOff.clear();
      });
    }
  }

  List<LocalChecklistTask> _allForTrainee(int slot) {
    final jobName = _traineeJob[slot];
    if (jobName == null) return const [];
    final job = dishroomJobs.firstWhere((j) => j.name == jobName);
    return [...job.setup, ...job.cleanup];
  }

  bool _traineeTasksComplete(int slot) {
    final tasks = _allForTrainee(slot);
    if (tasks.isEmpty) return false;
    final checks = _traineeChecks[slot] ?? const {};
    return tasks
        .where((t) => t.requiresCheckoff)
        .every((t) => checks[t.id] ?? false);
  }

  bool get _allTraineesCheckedOff {
    if (_traineeCount == 0) return false;
    for (var i = 0; i < _traineeCount; i += 1) {
      if (!(_traineeCheckedOff[i] ?? false)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_step >= 4) {
      return const SimpleFinishCard(
        title: 'Dishroom Trainer Shift Complete',
        message:
            'All trainees checked off. Submit shift email report and report to the supervisor.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle(
              icon: Icons.groups_rounded,
              title: 'Dishroom Trainee Support',
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_step + 1) / 5,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: const Color(0xFFE2ECF8),
              color: const Color(0xFF1F5E9C),
            ),
            const SizedBox(height: 12),
            if (_step == 0) ...[
              const Text(
                'Step 1 of 5',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Select meal.'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _meal,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Meal'),
                items: _localMeals
                    .map(
                      (meal) =>
                          DropdownMenuItem(value: meal, child: Text(meal)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _meal = value ?? _meal),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 1) ...[
              const Text(
                'Step 2 of 5',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('How many trainees are you supporting?'),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: _traineeCount,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Trainees'),
                items: List<int>.generate(8, (i) => i + 1)
                    .map(
                      (count) =>
                          DropdownMenuItem(value: count, child: Text('$count')),
                    )
                    .toList(),
                onChanged: (value) {
                  final next = value ?? 1;
                  setState(() {
                    _traineeCount = next;
                    for (var i = 0; i < _traineeCount; i += 1) {
                      _traineeJob.putIfAbsent(i, () => null);
                    }
                    _traineeJob.removeWhere(
                      (key, value) => key >= _traineeCount,
                    );
                    if (_selectedTrainee >= _traineeCount) {
                      _selectedTrainee = _traineeCount - 1;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 2) ...[
              const Text(
                'Step 3 of 5',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Assign each trainee a dishroom job.'),
              const SizedBox(height: 10),
              ...List.generate(_traineeCount, (slot) {
                final selected = _traineeJob[slot];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DropdownButtonFormField<String>(
                    initialValue: selected,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Trainee ${slot + 1} Job',
                    ),
                    items: dishroomJobs
                        .map(
                          (job) => DropdownMenuItem(
                            value: job.name,
                            child: Text(job.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _traineeJob[slot] = value;
                        _traineeCheckedOff[slot] = false;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 6),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      List.generate(
                        _traineeCount,
                        (i) => _traineeJob[i],
                      ).every((job) => job != null)
                      ? () => setState(() => _step = 3)
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 3) ...[
              const Text(
                'Step 4 of 5',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Select trainee and review tasks.'),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: _selectedTrainee,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Trainee'),
                items: List.generate(_traineeCount, (slot) {
                  final job = _traineeJob[slot] ?? 'Unassigned';
                  return DropdownMenuItem(
                    value: slot,
                    child: Text('Trainee ${slot + 1}: $job'),
                  );
                }),
                onChanged: (value) => setState(
                  () => _selectedTrainee = value ?? _selectedTrainee,
                ),
              ),
              const SizedBox(height: 10),
              _buildTraineeChecklist(_selectedTrainee),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _traineeTasksComplete(_selectedTrainee)
                      ? () => setState(
                          () => _traineeCheckedOff[_selectedTrainee] = true,
                        )
                      : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    (_traineeCheckedOff[_selectedTrainee] ?? false)
                        ? 'Trainee Checked Off'
                        : 'Mark Trainee Checked Off',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _allTraineesCheckedOff
                      ? () => setState(() => _step = 4)
                      : null,
                  child: const Text('Finish'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTraineeChecklist(int slot) {
    final jobName = _traineeJob[slot];
    if (jobName == null) {
      return const Text('Assign a job to this trainee first.');
    }

    final job = dishroomJobs.firstWhere((j) => j.name == jobName);
    final checks = _traineeChecks.putIfAbsent(slot, () => {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LocalPhaseChecklist(
          title: 'Setup (Before Doors Open)',
          tasks: job.setup,
          checks: checks,
          onToggle: (id, checked) => setState(() => checks[id] = checked),
        ),
        const SizedBox(height: 8),
        LocalPhaseChecklist(
          title: 'During Shift (Doors Open)',
          tasks: job.during,
          checks: checks,
          onToggle: (id, checked) => setState(() => checks[id] = checked),
        ),
        const SizedBox(height: 8),
        LocalPhaseChecklist(
          title: 'Cleanup (After Doors Close)',
          tasks: job.cleanup,
          checks: checks,
          onToggle: (id, checked) => setState(() => checks[id] = checked),
        ),
      ],
    );
  }
}

/// Reference-first kitchen jobs section used for main dish, salads, and
/// desserts.
class KitchenJobsSection extends StatefulWidget {
  const KitchenJobsSection({super.key, required this.resetSignal});

  final int resetSignal;

  @override
  State<KitchenJobsSection> createState() => _KitchenJobsSectionState();
}

class _KitchenJobsSectionState extends State<KitchenJobsSection> {
  String _station = 'Main Dish';
  String _dessert = 'Brownies';
  String _mainDishItem = 'Eggs';
  int _lastReset = 0;

  @override
  void initState() {
    super.initState();
    _lastReset = widget.resetSignal;
  }

  @override
  void didUpdateWidget(covariant KitchenJobsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal != _lastReset) {
      _lastReset = widget.resetSignal;
      setState(() {
        _station = 'Main Dish';
        _dessert = 'Brownies';
        _mainDishItem = 'Eggs';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainDishLines = _mainDishLines(_mainDishItem);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle(
              icon: Icons.restaurant_menu,
              title: 'Kitchen Jobs',
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _station,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Kitchen Station'),
              items: const [
                DropdownMenuItem(value: 'Main Dish', child: Text('Main Dish')),
                DropdownMenuItem(value: 'Salads', child: Text('Salads')),
                DropdownMenuItem(value: 'Desserts', child: Text('Desserts')),
              ],
              onChanged: (value) =>
                  setState(() => _station = value ?? _station),
            ),
            const SizedBox(height: 12),
            if (_station == 'Desserts') ...[
              DropdownButtonFormField<String>(
                initialValue: _dessert,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Dessert Item'),
                items: const [
                  DropdownMenuItem(value: 'Brownies', child: Text('Brownies')),
                  DropdownMenuItem(value: 'Pie', child: Text('Pie')),
                  DropdownMenuItem(
                    value: 'Cake Bars',
                    child: Text('Cake Bars'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _dessert = value ?? _dessert),
              ),
              const SizedBox(height: 10),
              InstructionCard(lines: _dessertLines(_dessert)),
            ] else if (_station == 'Salads') ...[
              const InstructionCard(
                lines: [
                  '1. Go to Locker 9 and review what is ready to prep.',
                  '2. Prioritize time-sensitive items first (fruit, proteins, specialty toppings).',
                  '3. Prep portions based on current meal demand and communicate shortages.',
                  '4. Label and stage items for easy salad-bar restock.',
                ],
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                initialValue: _mainDishItem,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Main Dish Item'),
                items: const [
                  DropdownMenuItem(value: 'Eggs', child: Text('Eggs')),
                  DropdownMenuItem(
                    value: 'French Toast Sticks',
                    child: Text('French Toast Sticks'),
                  ),
                  DropdownMenuItem(
                    value: 'Fried Chicken',
                    child: Text('Fried Chicken'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _mainDishItem = value ?? _mainDishItem),
              ),
              const SizedBox(height: 12),
              InstructionCard(lines: mainDishLines),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _dessertLines(String dessert) {
    switch (dessert) {
      case 'Pie':
        return const [
          '1. Go to Locker 8 and pull the pie assigned for service.',
          '2. Place pie on a clean cutting board and use a sanitized slicer.',
          '3. Cut each pie into 6 even pieces.',
          '4. Plate, cover, and stage for service pickup.',
        ];
      case 'Cake Bars':
        return const [
          '1. Go to Locker 8 and pull cake bars for the shift.',
          '2. Trim edges only if needed for clean presentation.',
          '3. Cut into equal servings (target 12 x 6 style consistency by tray).',
          '4. Stage trays and communicate refill timing.',
        ];
      case 'Brownies':
      default:
        return const [
          '1. Go to Locker 8 and pull the brownie pans for service.',
          '2. Use a clean, straight-edged knife and wipe between rows.',
          '3. Cut brownies into 12 by 6 rows for consistent portions.',
          '4. Stage trays for quick restock access.',
        ];
    }
  }

  List<String> _mainDishLines(String item) {
    switch (item) {
      case 'French Toast Sticks':
        return const [
          '1. Preheat oven to chef-specified temp before loading pans.',
          '2. Arrange sticks in a single layer for even cook.',
          '3. Cook 8-10 minutes, rotate pans, then cook 6-8 minutes more.',
          '4. Hold hot and communicate freshness timing to chefs.',
        ];
      case 'Fried Chicken':
        return const [
          '1. Confirm fryer temp and safety checks with chef before start.',
          '2. Load chicken in controlled batches; do not overcrowd baskets.',
          '3. Cook 12-15 minutes or until chef confirms internal temperature.',
          '4. Transfer to holding pan and log batch time.',
        ];
      case 'Eggs':
      default:
        return const [
          '1. Preheat flat top and stage eggs, butter/oil, and tools.',
          '2. Cook in smaller batches for quality and consistency.',
          '3. Fold gently and remove before overcooking.',
          '4. Review texture with chef and apply coaching adjustments each batch.',
        ];
    }
  }
}

/// Prototype-only night custodial checklist flow.
class NightCustodialSection extends StatefulWidget {
  const NightCustodialSection({super.key, required this.resetSignal});

  final int resetSignal;

  @override
  State<NightCustodialSection> createState() => _NightCustodialSectionState();
}

class _NightCustodialSectionState extends State<NightCustodialSection> {
  int _step = 0;
  String _section = 'Daily Jobs';
  final Map<String, bool> _checks = {};
  int _lastReset = 0;

  @override
  void initState() {
    super.initState();
    _lastReset = widget.resetSignal;
  }

  @override
  void didUpdateWidget(covariant NightCustodialSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal != _lastReset) {
      _lastReset = widget.resetSignal;
      setState(() {
        _step = 0;
        _section = 'Daily Jobs';
        _checks.clear();
      });
    }
  }

  static const _sections = ['Daily Jobs', 'Tile Floors', 'Rotational Jobs'];

  static const _dailyJobs = [
    'Pulpers emptied',
    'Paper dispensers/consumables refilled',
    'Trough, traps, arms, and drains in dishroom/scullery/machine cleaned',
    'Floors scrubbed, rinsed, and squeegeed',
    'Drains cleaned',
    'Hose, scrubbers, and squeegees put away',
  ];

  static const _tileFloorsByDay = {
    1: ['Bev. Line 4', 'Cereal Station'],
    2: ['Bev. Line 2', 'Junior Cash'],
    3: ['Island'],
    4: ['Cafe West'],
    5: ['Dish Return'],
    6: ['Aloha Plate', 'Choices', 'Line 1 and 3'],
    7: [],
  };

  static const _rotationalByDay = {
    1: [
      'Grout/shelf tops',
      'Cup conveyor/under section',
      'Line area (Supervisor)',
    ],
    2: ['Blue belt - shift return', 'Bev. Line 1 and 4', 'Fryers'],
    3: ['Blue belt - pit', 'Hoods', 'Ovens'],
    4: ['Blue belt - BTS', 'Bev. Line 2'],
    5: [
      'Fryers',
      'Bev. Line 6',
      'Basement stairs/pipe carts/fans/cereal dispensers',
    ],
    6: ['Grey floors', 'Custodial closet', 'Deep cleaning'],
    7: [],
  };

  List<LocalChecklistTask> get _activeTasks {
    final day = DateTime.now().weekday;
    final raw = switch (_section) {
      'Tile Floors' => _tileFloorsByDay[day] ?? const <String>[],
      'Rotational Jobs' => _rotationalByDay[day] ?? const <String>[],
      _ => _dailyJobs,
    };
    return [
      for (var i = 0; i < raw.length; i += 1)
        LocalChecklistTask(
          id: 'nc-${_section.toLowerCase().replaceAll(' ', '-')}-$day-$i',
          description: raw[i],
          requiresCheckoff: true,
        ),
    ];
  }

  bool _allChecked(List<LocalChecklistTask> tasks) {
    return tasks
        .where((t) => t.requiresCheckoff)
        .every((t) => _checks[t.id] ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (_step >= 2) {
      return const SimpleFinishCard(
        title: 'Night Custodial Complete',
        message: 'All custodial tasks complete. Submit final handoff report.',
      );
    }

    final activeTasks = _activeTasks;
    final sectionDone = _allChecked(activeTasks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle(
              icon: Icons.nights_stay,
              title: 'Night Custodial Tasks',
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
            if (_step == 0) ...[
              const Text(
                'Step 1 of 2',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Select custodial section.'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _section,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Section'),
                items: _sections
                    .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _section = value ?? _section),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Next'),
                ),
              ),
            ] else ...[
              const Text(
                'Step 2 of 2',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete $_section (${weekdayNameLabel(DateTime.now().weekday)}).',
              ),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: _section,
                tasks: activeTasks,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: sectionDone
                      ? () => setState(() => _step = 2)
                      : null,
                  child: const Text('Finish'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shared instruction card used by the local support sections.
class InstructionCard extends StatelessWidget {
  const InstructionCard({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1F5E9C).withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines) ...[
            Text(line, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

/// Reusable phase checklist for local-only support sections.
class LocalPhaseChecklist extends StatelessWidget {
  const LocalPhaseChecklist({
    super.key,
    required this.title,
    required this.tasks,
    required this.checks,
    required this.onToggle,
  });

  final String title;
  final List<LocalChecklistTask> tasks;
  final Map<String, bool> checks;
  final void Function(String id, bool checked) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF9AB3CF).withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...tasks.map(
            (task) => task.requiresCheckoff
                ? CheckboxListTile(
                    dense: false,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: checks[task.id] ?? false,
                    title: Text(task.description),
                    onChanged: (value) => onToggle(task.id, value ?? false),
                  )
                : ListTile(
                    dense: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    leading: const Icon(Icons.remove, size: 18),
                    title: Text(task.description),
                    subtitle: const Text(
                      'Continuous during-shift responsibility',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight finish card for prototype flows without backend persistence.
class SimpleFinishCard extends StatelessWidget {
  const SimpleFinishCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF103760),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF264D76),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Consistent section heading used across support-track cards.
class PanelTitle extends StatelessWidget {
  const PanelTitle({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF123A64),
      ),
    );
  }
}
