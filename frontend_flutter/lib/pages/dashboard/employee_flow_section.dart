part of '../dashboard_page.dart';

class _EmployeeTaskSection extends StatefulWidget {
  const _EmployeeTaskSection({
    required this.resetSignal,
    required this.backSignal,
    required this.onBackAtRoot,
    required this.onReturnToDashboardHub,
    required this.taskBoard,
    required this.onSelectMeal,
    required this.onSelectJob,
    required this.onTaskToggle,
    required this.onResetCompletedFlow,
  });

  final int resetSignal;
  final int backSignal;
  final VoidCallback onBackAtRoot;
  final Future<void> Function() onReturnToDashboardHub;
  final TaskBoard? taskBoard;
  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onSelectJob;
  final Future<void> Function(int taskId, bool completed) onTaskToggle;
  final Future<void> Function(String meal, int jobId) onResetCompletedFlow;

  @override
  State<_EmployeeTaskSection> createState() => _EmployeeTaskSectionState();
}

class _EmployeeTaskSectionState extends State<_EmployeeTaskSection> {
  static const int _finalStep = 5;

  int _step = 0;
  String? _selectedMeal;
  Map<int, bool> _taskCompletionOverrides = const {};
  int _lastResetSignal = 0;
  int _lastBackSignal = 0;

  @override
  void initState() {
    super.initState();
    _lastResetSignal = widget.resetSignal;
    _lastBackSignal = widget.backSignal;
  }

  @override
  void didUpdateWidget(covariant _EmployeeTaskSection oldWidget) {
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
        // Parent resets should return the employee flow to the first step.
        _step = 0;
        _isTransitioning = false;
      });
    }
    if (widget.backSignal != _lastBackSignal) {
      _lastBackSignal = widget.backSignal;
      if (_step > 0) {
        setState(() {
          _step -= 1;
        });
      } else {
        defer(widget.onBackAtRoot);
      }
    }

    final board = widget.taskBoard;
    if (board == null || _taskCompletionOverrides.isEmpty) return;

    final nextOverrides = Map<int, bool>.from(_taskCompletionOverrides);
    nextOverrides.removeWhere((taskId, completed) {
      for (final task in board.tasks) {
        if (task.taskId == taskId) {
          return task.completed == completed;
        }
      }
      return true;
    });
    if (nextOverrides.length != _taskCompletionOverrides.length) {
      _taskCompletionOverrides = nextOverrides;
    }
  }

  int? _selectedJobId;
  bool _isTransitioning = false;

  bool _allCheckoffComplete(List<TaskChecklistItem> tasks) {
    final checkoffTasks = tasks.where((t) => t.requiresCheckoff).toList();
    if (checkoffTasks.isEmpty) return true;
    return checkoffTasks.every((t) => t.completed);
  }

  List<TaskChecklistItem> _applyTaskOverrides(List<TaskChecklistItem> tasks) {
    if (_taskCompletionOverrides.isEmpty) return tasks;
    return tasks
        .map(
          (task) => _taskCompletionOverrides.containsKey(task.taskId)
              ? task.copyWith(completed: _taskCompletionOverrides[task.taskId])
              : task,
        )
        .toList();
  }

  Future<void> _handleTaskToggle(int taskId, bool completed) async {
    final previousOverride = _taskCompletionOverrides[taskId];
    final board = widget.taskBoard;
    bool? previousCompleted;
    if (board != null) {
      for (final task in board.tasks) {
        if (task.taskId == taskId) {
          previousCompleted = task.completed;
          break;
        }
      }
    }

    setState(() {
      _taskCompletionOverrides = {
        ..._taskCompletionOverrides,
        taskId: completed,
      };
    });

    try {
      await widget.onTaskToggle(taskId, completed);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final nextOverrides = Map<int, bool>.from(_taskCompletionOverrides);
        if (previousOverride != null) {
          nextOverrides[taskId] = previousOverride;
        } else if (previousCompleted != null) {
          nextOverrides.remove(taskId);
        }
        _taskCompletionOverrides = nextOverrides;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update task. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskBoard = widget.taskBoard;
    if (taskBoard == null) {
      return const Text('Loading task board...');
    }

    _selectedMeal ??= taskBoard.selectedMeal;
    _selectedJobId ??= taskBoard.selectedJobId;

    // Preserve the chosen job across meal changes when the same job still
    // exists in the new meal.
    final selectedJobId = taskBoard.jobs.any((j) => j.id == _selectedJobId)
        ? _selectedJobId
        : (taskBoard.jobs.isNotEmpty ? taskBoard.jobs.first.id : null);
    String? selectedJobName;
    if (selectedJobId != null) {
      for (final job in taskBoard.jobs) {
        if (job.id == selectedJobId) {
          selectedJobName = job.name;
          break;
        }
      }
    }
    final selectedJobReference = selectedJobName == null
        ? const <String>[]
        : notesForJob(selectedJobName);
    final showCondimentsRotation = selectedJobName == 'Condiments Prep';
    final showAnyInlineReferenceButton = selectedJobName != null;

    final setupTasks = _applyTaskOverrides(taskBoard.tasks
        .where((t) => t.phase == 'Setup')
        .toList());
    final duringTasks = _applyTaskOverrides(taskBoard.tasks
        .where((t) => t.phase == 'During Shift')
        .toList());
    final cleanupTasks = _applyTaskOverrides(taskBoard.tasks
        .where((t) => t.phase == 'Cleanup')
        .toList());

    final setupComplete = _allCheckoffComplete(setupTasks);
    final cleanupComplete = _allCheckoffComplete(cleanupTasks);

    if (_step >= _finalStep) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Shift Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF103760),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'All tasks complete. Report to your supervisor.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF264D76),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await widget.onReturnToDashboardHub();
                  },
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      );
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
                    icon: Icons.format_list_bulleted,
                    title: 'Shift Tasks',
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
                      'Step 1 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMeal,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: taskBoard.meals
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: _isTransitioning
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _selectedMeal = value);
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isTransitioning
                            ? null
                            : () async {
                                final meal =
                                    _selectedMeal ?? taskBoard.selectedMeal;
                                setState(() => _isTransitioning = true);
                                await widget.onSelectMeal(meal);
                                if (!mounted) return;
                                setState(() {
                                  _selectedJobId =
                                      widget.taskBoard?.selectedJobId;
                                  _step = 1;
                                  _isTransitioning = false;
                                });
                              },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 1) ...[
                    const Text(
                      'Step 2 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedJobId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Job'),
                      items: taskBoard.jobs
                          .map(
                            (j) => DropdownMenuItem<int>(
                              value: j.id,
                              child: Text(j.name),
                            ),
                          )
                          .toList(),
                      onChanged: _isTransitioning
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedJobId = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isTransitioning || selectedJobId == null
                            ? null
                            : () async {
                                setState(() => _isTransitioning = true);
                                await widget.onSelectJob(selectedJobId);
                                if (!mounted) return;
                                setState(() {
                                  _step = 2;
                                  _isTransitioning = false;
                                });
                              },
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 2) ...[
                    const Text(
                      'Step 3 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (showAnyInlineReferenceButton) ...[
                      const SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => showJobQuickReferenceDialog(
                                context,
                                jobName: selectedJobName!,
                                lines: selectedJobReference,
                              ),
                              icon: const Icon(Icons.menu_book_rounded),
                              label: const Text('View Notes'),
                            ),
                          ),
                          if (showCondimentsRotation)
                            const SizedBox(height: 10),
                          if (showCondimentsRotation)
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
                    ],
                    const SizedBox(height: 12),
                    _PhaseChecklist(
                      phase: 'Setup (Before Doors Open)',
                      tasks: setupTasks,
                      onTaskToggle: _handleTaskToggle,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: setupComplete
                            ? () {
                                setState(() {
                                  _step = 3;
                                });
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ] else if (_step == 3) ...[
                    const Text(
                      'Step 4 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (showAnyInlineReferenceButton) ...[
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => showJobQuickReferenceDialog(
                                context,
                                jobName: selectedJobName!,
                                lines: selectedJobReference,
                              ),
                              icon: const Icon(Icons.menu_book_rounded),
                              label: const Text('View Notes'),
                            ),
                          ),
                          if (showCondimentsRotation)
                            const SizedBox(height: 10),
                          if (showCondimentsRotation)
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
                    ],
                    const SizedBox(height: 12),
                    _PhaseChecklist(
                      phase: 'During Shift (Doors Open)',
                      tasks: duringTasks,
                      onTaskToggle: _handleTaskToggle,
                    ),
                    const SizedBox(height: 16),
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
                  ] else if (_step == 4) ...[
                    const Text(
                      'Step 5 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (showAnyInlineReferenceButton) ...[
                      const SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => showJobQuickReferenceDialog(
                                context,
                                jobName: selectedJobName!,
                                lines: selectedJobReference,
                              ),
                              icon: const Icon(Icons.menu_book_rounded),
                              label: const Text('View Notes'),
                            ),
                          ),
                          if (showCondimentsRotation)
                            const SizedBox(height: 10),
                          if (showCondimentsRotation)
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
                    ],
                    const SizedBox(height: 12),
                    _PhaseChecklist(
                      phase: 'Cleanup (After Doors Close)',
                      tasks: cleanupTasks,
                      onTaskToggle: _handleTaskToggle,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: cleanupComplete && !_isTransitioning
                            ? () {
                                setState(() {
                                  _step = _finalStep;
                                });
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Step 5 of 5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(
                            0xFF1F5E9C,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text(
                        'Cleanup complete. Report to your supervisor.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF113A67),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lead trainer flow for assigning trainee jobs and checking off trainee tasks.
