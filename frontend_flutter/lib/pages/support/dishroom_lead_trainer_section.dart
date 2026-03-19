part of '../dashboard_support_sections.dart';

class DishroomLeadTrainerSection extends StatefulWidget {
  const DishroomLeadTrainerSection({
    super.key,
    required this.resetSignal,
    required this.backSignal,
    required this.onBackAtRoot,
  });

  final int resetSignal;
  final int backSignal;
  final VoidCallback onBackAtRoot;

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
  int _lastBack = 0;

  @override
  void initState() {
    super.initState();
    _lastReset = widget.resetSignal;
    _lastBack = widget.backSignal;
  }

  @override
  void didUpdateWidget(covariant DishroomLeadTrainerSection oldWidget) {
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
    if (widget.backSignal != _lastBack) {
      _lastBack = widget.backSignal;
      if (_step > 0) {
        setState(() {
          _step -= 1;
        });
      } else {
        deferRootBack();
      }
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
