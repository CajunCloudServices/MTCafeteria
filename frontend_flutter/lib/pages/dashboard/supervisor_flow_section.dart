part of '../dashboard_page.dart';

class _SupervisorSection extends StatefulWidget {
  const _SupervisorSection({
    required this.resetSignal,
    required this.backSignal,
    required this.onBackAtRoot,
    required this.onReturnToDashboardHub,
    required this.supervisorBoard,
    required this.jobTaskBoard,
    required this.selectedJobId,
    required this.panelMode,
    required this.secondaries,
    required this.deepCleanChecked,
    required this.currentLineShiftReport,
    required this.onSelectMeal,
    required this.onOpenJob,
    required this.onBackToJobs,
    required this.onToggleTask,
    required this.onBulkToggleTasks,
    required this.onPanelModeChanged,
    required this.onSecondaryToggle,
    required this.onDeepCleanToggle,
    required this.onResetSecondaries,
    required this.onResetAll,
    required this.onReloadBoard,
    required this.onLoadDailyShiftReport,
    required this.onSaveDailyShiftReport,
    required this.onSubmitDailyShiftReport,
  });

  final int resetSignal;
  final int backSignal;
  final VoidCallback onBackAtRoot;
  final Future<void> Function() onReturnToDashboardHub;
  final SupervisorBoard? supervisorBoard;
  final SupervisorJobTaskBoard? jobTaskBoard;
  final int? selectedJobId;
  final String panelMode;
  final List<SecondaryJobItem> secondaries;
  final bool deepCleanChecked;
  final DailyShiftReport? currentLineShiftReport;
  final Future<void> Function(String meal) onSelectMeal;
  final Future<void> Function(int jobId) onOpenJob;
  final VoidCallback onBackToJobs;
  final Future<void> Function(int taskId, bool checked) onToggleTask;
  final Future<void> Function(List<int> taskIds, bool checked)
  onBulkToggleTasks;
  final ValueChanged<String> onPanelModeChanged;
  final void Function(int index, bool checked) onSecondaryToggle;
  final ValueChanged<bool> onDeepCleanToggle;
  final VoidCallback onResetSecondaries;
  final Future<void> Function() onResetAll;
  final Future<void> Function() onReloadBoard;
  final Future<void> Function(String meal) onLoadDailyShiftReport;
  final Future<void> Function(String meal, Map<String, String> payload)
  onSaveDailyShiftReport;
  final Future<void> Function(String meal, Map<String, String> payload)
  onSubmitDailyShiftReport;

  @override
  State<_SupervisorSection> createState() => _SupervisorSectionState();
}

class _SupervisorSectionState extends State<_SupervisorSection> {
  String? _selectedMeal;
  String _selectedView = 'Jobs';
  bool _mealLoaded = false;
  bool _shiftFinished = false;
  final bool _markingAllJobTasks = false;
  bool _lastOpenJobWasComplete = false;
  int? _lastOpenJobId;
  Map<String, bool> _supervisorEndShiftChecks = {};
  int _lastResetSignal = 0;
  int _lastBackSignal = 0;
  final Set<int> _optimisticallyCompletedJobIds = <int>{};
  String? _optimisticCompletionMeal;
  bool _hasPromptedForCurrentCompletion = false;
  bool _finishPromptOpen = false;

  void _updateSupervisorState(VoidCallback action) {
    if (!mounted) return;
    setState(action);
  }

  @override
  void initState() {
    _lastResetSignal = widget.resetSignal;
    _lastBackSignal = widget.backSignal;
    super.initState();
    if (widget.panelMode == 'Jobs' ||
        widget.panelMode == 'Secondaries' ||
        widget.panelMode == 'Deep Clean' ||
        widget.panelMode == 'Daily Shift Report') {
      _selectedView = widget.panelMode;
    }
  }

  @override
  void didUpdateWidget(covariant _SupervisorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    void defer(VoidCallback action) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        action();
      });
    }

    final openJobId = widget.selectedJobId;
    final openJobTasks =
        widget.jobTaskBoard?.tasks ?? const <SupervisorJobTaskItem>[];
    final openJobComplete =
        openJobId != null &&
        openJobTasks.isNotEmpty &&
        openJobTasks.every((task) => task.checked);

    if (openJobId != _lastOpenJobId) {
      _lastOpenJobId = openJobId;
      _lastOpenJobWasComplete = openJobComplete;
    } else if (openJobComplete && !_lastOpenJobWasComplete) {
      _lastOpenJobWasComplete = true;
      defer(() {
        setState(() {
          _selectedView = 'Jobs';
        });
        widget.onPanelModeChanged('Jobs');
        widget.onBackToJobs();
      });
    } else {
      _lastOpenJobWasComplete = openJobComplete;
    }

    final oldMeal = oldWidget.supervisorBoard?.selectedMeal;
    final newMeal = widget.supervisorBoard?.selectedMeal;
    if (newMeal != null && oldMeal != newMeal) {
      _optimisticallyCompletedJobIds.clear();
      _optimisticCompletionMeal = null;
    }

    if (_optimisticCompletionMeal != null &&
        newMeal != null &&
        _optimisticCompletionMeal != newMeal) {
      _optimisticallyCompletedJobIds.clear();
      _optimisticCompletionMeal = null;
    }

    if (_optimisticallyCompletedJobIds.isNotEmpty &&
        widget.supervisorBoard != null) {
      final nowServerCompleted = widget.supervisorBoard!.jobs
          .where(
            (job) => job.totalCount > 0 && job.checkedCount >= job.totalCount,
          )
          .map((job) => job.jobId)
          .toSet();
      final removable = _optimisticallyCompletedJobIds
          .where((jobId) => nowServerCompleted.contains(jobId))
          .toList();
      if (removable.isNotEmpty) {
        _optimisticallyCompletedJobIds.removeAll(removable);
        if (_optimisticallyCompletedJobIds.isEmpty) {
          _optimisticCompletionMeal = null;
        }
      }
    }

    if (widget.resetSignal != _lastResetSignal) {
      _lastResetSignal = widget.resetSignal;
      setState(() {
        _mealLoaded = false;
        _shiftFinished = false;
        _selectedView = 'Jobs';
        _supervisorEndShiftChecks = {};
        _lastOpenJobId = null;
        _lastOpenJobWasComplete = false;
        _optimisticallyCompletedJobIds.clear();
        _optimisticCompletionMeal = null;
        _hasPromptedForCurrentCompletion = false;
        _finishPromptOpen = false;
      });
      defer(() {
        widget.onPanelModeChanged('Jobs');
        widget.onBackToJobs();
      });
    }
    if (widget.backSignal != _lastBackSignal) {
      _lastBackSignal = widget.backSignal;
      if (_shiftFinished) {
        setState(() {
          _shiftFinished = false;
          _hasPromptedForCurrentCompletion = false;
        });
        return;
      }
      if (widget.selectedJobId != null) {
        setState(() {
          _selectedView = 'Jobs';
        });
        defer(() {
          widget.onPanelModeChanged('Jobs');
          widget.onBackToJobs();
        });
        return;
      }
      if (_mealLoaded && _selectedView != 'Jobs') {
        setState(() {
          _selectedView = 'Jobs';
        });
        defer(() => widget.onPanelModeChanged('Jobs'));
        return;
      }
      if (_mealLoaded) {
        // From the supervisor jobs list, go back to the parent workflow
        // selector instead of jumping down into meal re-selection.
        defer(widget.onBackAtRoot);
        return;
      }
      defer(widget.onBackAtRoot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supervisorBoard = widget.supervisorBoard;
    if (supervisorBoard == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Loading supervisor board...'),
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

    final secondarySource = widget.secondaries.isNotEmpty
        ? widget.secondaries
        : const [
            SecondaryJobItem(
              name: 'Wipe spills in dining area',
              phase: 'While doors are open',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Restock napkin stations',
              phase: 'While doors are open',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Trashes',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Spot Mop',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Wipe Tables',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Straighten Chairs',
              phase: 'After doors close',
              checked: false,
            ),
            SecondaryJobItem(
              name: 'Collect Red Buckets',
              phase: 'After doors close',
              checked: false,
            ),
          ];

    bool isDuringPhase(String phase) {
      final value = phase.trim().toLowerCase();
      return value == 'during shift' ||
          value == 'while doors are open' ||
          value.contains('during');
    }

    bool isCleanupPhase(String phase) {
      final value = phase.trim().toLowerCase();
      return value == 'cleanup' ||
          value == 'after doors close' ||
          value.contains('cleanup') ||
          value.contains('after');
    }

    final mealScopedEntries = secondarySource
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.value.meals.isEmpty ||
              entry.value.meals.contains(supervisorBoard.selectedMeal),
        )
        .toList();

    final mealScopedSecondaries = mealScopedEntries
        .map((e) => e.value)
        .toList();

    final duringSecondaries = mealScopedEntries
        .where((entry) => isDuringPhase(entry.value.phase))
        .toList();
    final cleanupSecondaries = mealScopedEntries
        .where((entry) => isCleanupPhase(entry.value.phase))
        .toList();

    final pendingJobs = supervisorBoard.jobs
        .where((j) => !_isJobComplete(j))
        .toList();
    final completedJobs = supervisorBoard.jobs.where(_isJobComplete).toList();
    final allSecondariesChecked = mealScopedSecondaries.every((s) => s.checked);
    final completedSecondariesCount = mealScopedSecondaries
        .where((s) => s.checked)
        .length;
    final supervisorChecklistDone = supervisorEndShiftCheckoffItems.every(
      (item) => _supervisorEndShiftChecks[item] ?? false,
    );
    final completedSupervisorChecklistCount = supervisorEndShiftCheckoffItems
        .where((item) => _supervisorEndShiftChecks[item] ?? false)
        .length;
    final report = widget.currentLineShiftReport;
    final reportSubmitted =
        report != null &&
        report.isSubmitted &&
        report.mealType == supervisorBoard.selectedMeal;
    final totalProgressUnits =
        supervisorBoard.jobs.length +
        mealScopedSecondaries.length +
        1 +
        supervisorEndShiftCheckoffItems.length +
        1;
    final completedProgressUnits =
        completedJobs.length +
        completedSecondariesCount +
        (widget.deepCleanChecked ? 1 : 0) +
        completedSupervisorChecklistCount +
        (reportSubmitted ? 1 : 0);

    final canMarkShiftFinished = _canMarkShiftFinished(
      hasPendingJobs: pendingJobs.isNotEmpty,
      allSecondariesChecked: allSecondariesChecked,
      deepCleanChecked: widget.deepCleanChecked,
      supervisorChecklistDone: supervisorChecklistDone,
      reportSubmitted: reportSubmitted,
    );

    void maybePromptForShiftFinish() {
      final ready = canMarkShiftFinished && !_shiftFinished;
      if (!ready) {
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
        if (!mounted || !shouldFinish || _shiftFinished) return;
        _updateSupervisorState(() {
          _shiftFinished = true;
        });
      });
    }

    maybePromptForShiftFinish();

    if (_shiftFinished) {
      return _buildSupervisorCompletionCard(
        supervisorBoard: supervisorBoard,
        completedJobs: completedJobs,
        allSecondariesChecked: allSecondariesChecked,
      );
    }

    return _buildSupervisorMainLayout(
      context: context,
      supervisorBoard: supervisorBoard,
      pendingJobs: pendingJobs,
      completedJobs: completedJobs,
      duringSecondaries: duringSecondaries,
      cleanupSecondaries: cleanupSecondaries,
      canMarkShiftFinished: canMarkShiftFinished,
      allSecondariesChecked: allSecondariesChecked,
      supervisorChecklistDone: supervisorChecklistDone,
      reportSubmitted: reportSubmitted,
      totalProgressUnits: totalProgressUnits,
      completedProgressUnits: completedProgressUnits,
    );
  }
}
