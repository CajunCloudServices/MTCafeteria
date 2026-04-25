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
    required this.onReloadBoard,
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
  final Future<void> Function() onReloadBoard;
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
  bool _hasPromptedForCurrentCompletion = false;
  bool _finishPromptOpen = false;

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
        _step = 0;
        _isTransitioning = false;
        _hasPromptedForCurrentCompletion = false;
        _finishPromptOpen = false;
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

  void _maybePromptForShiftFinish({required bool ready}) {
    if (!ready || _step != 4 || _step >= _finalStep) {
      _hasPromptedForCurrentCompletion = false;
      return;
    }
    if (_hasPromptedForCurrentCompletion || _finishPromptOpen) return;
    _hasPromptedForCurrentCompletion = true;
    _finishPromptOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final shouldFinish = await _showShiftFinishPrompt(context);
      _finishPromptOpen = false;
      if (!mounted || !shouldFinish || _step != 4) return;
      setState(() {
        _step = _finalStep;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskBoard = widget.taskBoard;
    if (taskBoard == null) {
      return StitchCard(
        padding: const EdgeInsets.all(StitchSpacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loading task board…', style: StitchText.titleMd),
            const SizedBox(height: 12),
            StitchSecondaryButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: widget.onReloadBoard,
              expand: false,
            ),
          ],
        ),
      );
    }

    final selectedJobId = taskBoard.jobs.any((j) => j.id == _selectedJobId)
        ? _selectedJobId
        : null;
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

    final setupTasks = _applyTaskOverrides(
      taskBoard.tasks.where((t) => t.phase == 'Setup').toList(),
    );
    final duringTasks = _applyTaskOverrides(
      taskBoard.tasks.where((t) => t.phase == 'During Shift').toList(),
    );
    final cleanupTasks = _applyTaskOverrides(
      taskBoard.tasks.where((t) => t.phase == 'Cleanup').toList(),
    );

    final setupComplete = _allCheckoffComplete(setupTasks);
    final cleanupComplete = _allCheckoffComplete(cleanupTasks);
    _maybePromptForShiftFinish(
      ready: cleanupComplete && !_isTransitioning,
    );

    if (_step >= _finalStep) {
      final totalDone = taskBoard.tasks
          .where((t) => t.requiresCheckoff && t.completed)
          .length;
      final totalCheckoff = taskBoard.tasks
          .where((t) => t.requiresCheckoff)
          .length;
      final compliance = totalCheckoff == 0
          ? 100
          : ((totalDone / totalCheckoff) * 100).round();
      return StitchSuccessCard(
        title: 'Shift Complete',
        message: '',
        stats: [
          StitchSuccessStat(value: '$totalDone', label: 'Tasks Done'),
          StitchSuccessStat(value: '$compliance%', label: 'Compliance'),
        ],
        primaryCtaLabel: 'Back to Dashboard',
        primaryIcon: Icons.dashboard_rounded,
        onPrimary: () async {
          await widget.onReturnToDashboardHub();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_step == 0)
          StitchSelectionScreen(
            title: 'Select Meal',
            isBusy: _isTransitioning,
            options: [
              for (final meal in taskBoard.meals)
                StitchSelectionOption(
                  rowKey: ValueKey('meal-row-$meal'),
                  label: meal,
                  icon: _iconForMeal(meal),
                  selected: _selectedMeal == meal,
                  onTap: _isTransitioning
                      ? null
                      : () async {
                          setState(() {
                            _selectedMeal = meal;
                            _isTransitioning = true;
                          });
                          await widget.onSelectMeal(meal);
                          if (!mounted) return;
                          setState(() {
                            _selectedJobId = null;
                            _step = 1;
                            _isTransitioning = false;
                          });
                        },
                ),
            ],
          )
        else if (_step == 1)
          StitchSelectionScreen(
            title: 'Select Station',
            isBusy: _isTransitioning,
            options: [
              for (final job in taskBoard.jobs)
                StitchSelectionOption(
                  rowKey: ValueKey('station-row-${job.id}'),
                  label: job.name,
                  icon: Icons.work_outline_rounded,
                  selected: selectedJobId == job.id,
                  onTap: _isTransitioning
                      ? null
                      : () async {
                          setState(() {
                            _isTransitioning = true;
                          });
                          await widget.onSelectJob(job.id);
                          if (!mounted) return;
                          setState(() {
                            _selectedJobId = job.id;
                            _step = 2;
                            _isTransitioning = false;
                          });
                        },
                ),
            ],
          )
        else if (_step == 2)
          _PhaseStep(
            title: 'Setup',
            showReferenceActions: showAnyInlineReferenceButton,
            selectedJobName: selectedJobName,
            selectedJobReference: selectedJobReference,
            showCondimentsRotation: showCondimentsRotation,
            checklist: _PhaseChecklist(
              phase: 'Station Readiness',
              tasks: setupTasks,
              onTaskToggle: _handleTaskToggle,
            ),
            continueLabel: 'Start Service',
            continueIcon: Icons.play_arrow_rounded,
            onContinue: setupComplete
                ? () => setState(() => _step = 3)
                : null,
          )
        else if (_step == 3)
          _PhaseStep(
            title: 'Running',
            showReferenceActions: showAnyInlineReferenceButton,
            selectedJobName: selectedJobName,
            selectedJobReference: selectedJobReference,
            showCondimentsRotation: showCondimentsRotation,
            checklist: _PhaseChecklist(
              phase: 'During Shift',
              tasks: duringTasks,
              onTaskToggle: _handleTaskToggle,
            ),
            continueLabel: 'Begin Cleanup',
            continueIcon: Icons.cleaning_services_rounded,
            onContinue: () => setState(() => _step = 4),
          )
        else if (_step == 4)
          _PhaseStep(
            title: 'Cleanup',
            showReferenceActions: showAnyInlineReferenceButton,
            selectedJobName: selectedJobName,
            selectedJobReference: selectedJobReference,
            showCondimentsRotation: showCondimentsRotation,
            checklist: _PhaseChecklist(
              phase: 'Cleanup',
              tasks: cleanupTasks,
              onTaskToggle: _handleTaskToggle,
            ),
            continueLabel: 'Finish Shift',
            continueIcon: Icons.flag_rounded,
            onContinue: cleanupComplete && !_isTransitioning
                ? () => setState(() => _step = _finalStep)
                : null,
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

IconData _iconForMeal(String meal) {
  switch (meal.toLowerCase()) {
    case 'breakfast':
      return Icons.bakery_dining_rounded;
    case 'lunch':
      return Icons.lunch_dining_rounded;
    case 'dinner':
      return Icons.restaurant_rounded;
    default:
      return Icons.schedule_rounded;
  }
}

/// Steps 2/3/4 — phase checklist shells sharing a consistent editorial header.
class _PhaseStep extends StatelessWidget {
  const _PhaseStep({
    required this.title,
    required this.checklist,
    required this.continueLabel,
    required this.continueIcon,
    required this.onContinue,
    required this.showReferenceActions,
    required this.selectedJobName,
    required this.selectedJobReference,
    required this.showCondimentsRotation,
  });

  final String title;
  final Widget checklist;
  final String continueLabel;
  final IconData continueIcon;
  final VoidCallback? onContinue;
  final bool showReferenceActions;
  final String? selectedJobName;
  final List<String> selectedJobReference;
  final bool showCondimentsRotation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildAppHeaderTitle(context, title),
        if (showReferenceActions && selectedJobName != null) ...[
          const SizedBox(height: StitchSpacing.lg),
          Row(
            children: [
              Expanded(
                child: StitchSecondaryButton(
                  label: 'Notes',
                  icon: Icons.menu_book_rounded,
                  onPressed: () => showJobQuickReferenceDialog(
                    context,
                    jobName: selectedJobName!,
                    lines: selectedJobReference,
                  ),
                ),
              ),
              if (showCondimentsRotation) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: StitchSecondaryButton(
                    label: 'Rotation',
                    icon: Icons.tune_rounded,
                    onPressed: () => showCondimentsRotationDialog(context),
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: StitchSpacing.xl),
        checklist,
        const SizedBox(height: StitchSpacing.xl),
        StitchPrimaryButton(
          label: continueLabel,
          icon: continueIcon,
          onPressed: onContinue,
          height: StitchLayout.ctaHeightLg,
        ),
      ],
    );
  }
}

/// Lead trainer flow for assigning trainee jobs and checking off trainee tasks.
