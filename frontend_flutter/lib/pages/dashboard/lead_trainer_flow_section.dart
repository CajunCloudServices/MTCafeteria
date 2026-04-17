part of '../dashboard_page.dart';

class _LeadTrainerTaskSection extends StatefulWidget {
  const _LeadTrainerTaskSection({
    required this.resetSignal,
    required this.backSignal,
    required this.onBackAtRoot,
    required this.onReturnToDashboardHub,
    required this.trainerBoard,
    required this.traineeCount,
    required this.selectedTraineeSlot,
    required this.traineeJobBySlot,
    required this.trainerSlotTasks,
    required this.onSelectMeal,
    required this.onSetTraineeCount,
    required this.onAssignTraineeJob,
    required this.onSelectTraineeSlot,
    required this.onTaskToggle,
    required this.onReloadBoard,
    required this.onResetFlow,
  });
  final int resetSignal;
  final int backSignal;
  final VoidCallback onBackAtRoot;
  final Future<void> Function() onReturnToDashboardHub;

  final TrainerBoard? trainerBoard;
  final int traineeCount;
  final int selectedTraineeSlot;
  final Map<int, int?> traineeJobBySlot;
  final Map<int, List<TrainerTraineeTask>> trainerSlotTasks;
  final Future<void> Function(String meal) onSelectMeal;
  final ValueChanged<int> onSetTraineeCount;
  final Future<void> Function(int slot, int? jobId) onAssignTraineeJob;
  final ValueChanged<int> onSelectTraineeSlot;
  final Future<void> Function(int slot, int taskId, bool completed)
  onTaskToggle;
  final Future<void> Function() onReloadBoard;
  final VoidCallback onResetFlow;

  @override
  State<_LeadTrainerTaskSection> createState() =>
      _LeadTrainerTaskSectionState();
}

class _LeadTrainerTaskSectionState extends State<_LeadTrainerTaskSection> {
  static const int _finalStep = 5;

  int _step = 0;
  String? _selectedMeal;
  int? _selectedCount;
  Map<int, bool> _traineeCheckedOff = {};
  Map<String, bool> _leadTrainerEndShiftChecks = {};
  bool _shiftFinished = false;

  int _lastResetSignal = 0;
  int _lastBackSignal = 0;

  @override
  void initState() {
    super.initState();
    _lastResetSignal = widget.resetSignal;
    _lastBackSignal = widget.backSignal;
  }

  @override
  void didUpdateWidget(covariant _LeadTrainerTaskSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    void defer(VoidCallback action) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        action();
      });
    }

    if (widget.resetSignal != _lastResetSignal) {
      _lastResetSignal = widget.resetSignal;
      setState(() {
        // Reset should discard trainee selections and completion state.
        _step = 0;
        _shiftFinished = false;
        _traineeCheckedOff = {};
        _leadTrainerEndShiftChecks = {};
      });
    }
    if (widget.backSignal != _lastBackSignal) {
      _lastBackSignal = widget.backSignal;
      if (_shiftFinished) {
        setState(() {
          _shiftFinished = false;
        });
      } else if (_step > 0) {
        setState(() {
          _step -= 1;
        });
      } else {
        defer(widget.onBackAtRoot);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerBoard = widget.trainerBoard;
    if (trainerBoard == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Loading trainer board...'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: widget.onReloadBoard,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    _selectedMeal ??= trainerBoard.selectedMeal;
    _selectedCount ??= widget.traineeCount;

    final selectedSlot = widget.selectedTraineeSlot;
    final selectedTasks = widget.trainerSlotTasks[selectedSlot] ?? const [];

    _traineeCheckedOff = {
      for (var i = 0; i < widget.traineeCount; i += 1)
        i: _traineeCheckedOff[i] ?? false,
    };

    final selectedTraineeCompleted = _allTraineeCheckoffsComplete(
      selectedTasks,
    );
    final selectedTraineeCheckedOff = _traineeCheckedOff[selectedSlot] ?? false;
    final checkedOffCount = List.generate(
      widget.traineeCount,
      (slot) => _traineeCheckedOff[slot] ?? false,
    ).where((checked) => checked).length;

    final allTraineesCheckedOff = checkedOffCount == widget.traineeCount;

    final leadTrainerChecklistDone = leadTrainerEndShiftCheckoffItems.every(
      (item) => _leadTrainerEndShiftChecks[item] ?? false,
    );

    final allAssigned = List.generate(
      widget.traineeCount,
      (slot) => widget.traineeJobBySlot[slot] != null,
    ).every((assigned) => assigned);

    if (_shiftFinished) {
      return _buildLeadTrainerCompletionCard(checkedOffCount);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PanelTitle(
                    icon: Icons.groups,
                    title: 'Trainee Support Board',
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (_step + 1) / _finalStep,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: const Color(0xFFE2ECF8),
                    color: const Color(0xFF1F5E9C),
                  ),
                  const SizedBox(height: 12),
                  if (_step == 0) ...[
                    const Text(
                      'Step 1 of 4',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMeal,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: trainerBoard.meals
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMeal = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final meal =
                              _selectedMeal ?? trainerBoard.selectedMeal;
                          await widget.onSelectMeal(meal);
                          if (!mounted) return;
                          setState(() {
                            _step = 1;
                            _shiftFinished = false;
                            _traineeCheckedOff = {
                              for (var i = 0; i < widget.traineeCount; i += 1)
                                i: false,
                            };
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 1) ...[
                    const Text(
                      'Step 2 of 4',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCount,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Trainee Count',
                      ),
                      items: List.generate(12, (index) => index + 1)
                          .map(
                            (count) => DropdownMenuItem<int>(
                              value: count,
                              child: Text('$count'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCount = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final count = _selectedCount ?? widget.traineeCount;
                          widget.onSetTraineeCount(count);
                          setState(() {
                            _step = 2;
                            _shiftFinished = false;
                            _traineeCheckedOff = {
                              for (var i = 0; i < count; i += 1) i: false,
                            };
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 2) ...[
                    const Text(
                      'Step 3 of 4',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(widget.traineeCount, (slot) {
                      final jobId = widget.traineeJobBySlot[slot];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF9FB6D3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trainee ${slot + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: jobId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Job',
                              ),
                              items: trainerBoard.jobs
                                  .map(
                                    (job) => DropdownMenuItem<int>(
                                      value: job.id,
                                      child: Text(job.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                widget.onAssignTraineeJob(slot, value);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: allAssigned
                            ? () {
                                widget.onSelectTraineeSlot(0);
                                setState(() {
                                  _step = 3;
                                });
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ] else ...[
                    Text(
                      _step == 3
                          ? 'Step 4 of $_finalStep'
                          : 'Step 5 of $_finalStep',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (_step == 3) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF9FB6D3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trainee Selection',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: selectedSlot,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Trainee',
                              ),
                              items: List.generate(widget.traineeCount, (slot) {
                                return DropdownMenuItem<int>(
                                  value: slot,
                                  child: Text(
                                    'Trainee ${slot + 1}: ${_jobLabelForSlot(trainerBoard, slot)}',
                                  ),
                                );
                              }),
                              onChanged: (value) {
                                if (value != null) {
                                  widget.onSelectTraineeSlot(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_jobLabelForSlot(trainerBoard, selectedSlot) !=
                          'Unassigned') ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => showJobQuickReferenceDialog(
                                  context,
                                  jobName: _jobLabelForSlot(
                                    trainerBoard,
                                    selectedSlot,
                                  ),
                                  lines: notesForJob(
                                    _jobLabelForSlot(
                                      trainerBoard,
                                      selectedSlot,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.menu_book_rounded),
                                label: const Text('View Job Notes'),
                              ),
                            ),
                            if (_jobLabelForSlot(trainerBoard, selectedSlot) ==
                                'Condiments Prep')
                              const SizedBox(height: 10),
                            if (_jobLabelForSlot(trainerBoard, selectedSlot) ==
                                'Condiments Prep')
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      showCondimentsRotationDialog(context),
                                  icon: const Icon(Icons.tune_rounded),
                                  label: const Text('Condiment Rotation'),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 10),
                      _TrainerPhaseChecklist(
                        phase: 'Setup (Before Doors Open)',
                        tasks: selectedTasks
                            .where((t) => t.phase == 'Setup')
                            .toList(),
                        slot: selectedSlot,
                        onToggle: widget.onTaskToggle,
                      ),
                      _TrainerPhaseChecklist(
                        phase: 'During Shift (Doors Open)',
                        tasks: selectedTasks
                            .where((t) => t.phase == 'During Shift')
                            .toList(),
                        slot: selectedSlot,
                        onToggle: widget.onTaskToggle,
                      ),
                      _TrainerPhaseChecklist(
                        phase: 'Cleanup (After Doors Close)',
                        tasks: selectedTasks
                            .where((t) => t.phase == 'Cleanup')
                            .toList(),
                        slot: selectedSlot,
                        onToggle: widget.onTaskToggle,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF9FB6D3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Checkoff',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Progress: $checkedOffCount/${widget.traineeCount} checked off',
                              style: const TextStyle(
                                color: Color(0xFF32567F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed:
                                    selectedTraineeCompleted &&
                                        !selectedTraineeCheckedOff
                                    ? () {
                                        setState(() {
                                          _traineeCheckedOff = {
                                            ..._traineeCheckedOff,
                                            selectedSlot: true,
                                          };
                                        });
                                      }
                                    : null,
                                child: Text(
                                  selectedTraineeCheckedOff
                                      ? 'Checked Off'
                                      : 'Check Off Trainee',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (allTraineesCheckedOff) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _step = 4;
                              });
                            },
                            child: const Text('Next'),
                          ),
                        ),
                      ],
                    ] else ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF9FB6D3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lead Trainer End-of-Shift Checkoff',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            ...leadTrainerEndShiftCheckoffItems.map(
                              (item) => CheckboxListTile(
                                dense: false,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value:
                                    _leadTrainerEndShiftChecks[item] ?? false,
                                title: Text(item),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _leadTrainerEndShiftChecks = {
                                      ..._leadTrainerEndShiftChecks,
                                      item: value,
                                    };
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_step == 4 &&
            allTraineesCheckedOff &&
            leadTrainerChecklistDone &&
            !_shiftFinished) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                setState(() {
                  _shiftFinished = true;
                });
              },
              child: const Text('Finish'),
            ),
          ),
        ],
      ],
    );
  }
}
