part of '../dashboard_support_sections.dart';

class DishroomWorkerSection extends StatefulWidget {
  const DishroomWorkerSection({
    super.key,
    required this.resetSignal,
    required this.backSignal,
    required this.onBackAtRoot,
  });

  final int resetSignal;
  final int backSignal;
  final VoidCallback onBackAtRoot;

  @override
  State<DishroomWorkerSection> createState() => _DishroomWorkerSectionState();
}

class _DishroomWorkerSectionState extends State<DishroomWorkerSection> {
  int _step = 0;
  String? _meal;
  String? _jobName;
  final Map<String, bool> _checks = {};
  int _lastReset = 0;
  int _lastBack = 0;
  bool _hasPromptedForCurrentCompletion = false;
  bool _finishPromptOpen = false;

  @override
  void initState() {
    super.initState();
    _lastReset = widget.resetSignal;
    _lastBack = widget.backSignal;
  }

  @override
  void didUpdateWidget(covariant DishroomWorkerSection oldWidget) {
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
        _meal = null;
        _jobName = null;
        _checks.clear();
        _hasPromptedForCurrentCompletion = false;
        _finishPromptOpen = false;
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

  bool _allChecked(List<LocalChecklistTask> tasks) {
    final requiredTasks = tasks.where((t) => t.requiresCheckoff).toList();
    if (requiredTasks.isEmpty) return true;
    return requiredTasks.every((t) => _checks[t.id] ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeal = _meal;
    final selectedJobName = _jobName;
    final job = selectedJobName == null
        ? null
        : dishroomJobs.firstWhere((j) => j.name == selectedJobName);
    final setupDone = job == null ? false : _allChecked(job.setup);
    final cleanupDone = job == null ? false : _allChecked(job.cleanup);
    final deepCleanTasks = selectedMeal == null
        ? const <LocalChecklistTask>[]
        : dishroomDeepCleanTasksFor(
      meal: selectedMeal,
      weekday: DateTime.now().weekday,
    );
    final deepCleanDone = _allChecked(deepCleanTasks);

    void maybePromptForShiftFinish() {
      final ready = _step == 5 && deepCleanDone;
      if (!ready) {
        _hasPromptedForCurrentCompletion = false;
        return;
      }
      if (_hasPromptedForCurrentCompletion || _finishPromptOpen) return;
      _hasPromptedForCurrentCompletion = true;
      _finishPromptOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final shouldFinish = await _showSupportShiftFinishPrompt(context);
        _finishPromptOpen = false;
        if (!mounted || !shouldFinish || _step != 5) return;
        setState(() => _step = 6);
      });
    }

    maybePromptForShiftFinish();

    if (_step >= 6) {
      return SimpleFinishCard(
        title: 'Dishroom Shift Complete',
        message:
            'All dishroom tasks complete. Report to the dishroom lead trainer.',
      );
    }

    if (_step == 0) {
      return StitchSelectionScreen(
        title: 'Select Meal',
        options: [
          for (final meal in _localMeals)
            StitchSelectionOption(
              rowKey: ValueKey('dishroom-meal-$meal'),
              label: meal,
              icon: _mealIcon(meal),
              selected: false,
              onTap: () => setState(() {
                _meal = meal;
                _step = 1;
              }),
            ),
        ],
      );
    }

    if (_step == 1) {
      return StitchSelectionScreen(
        title: 'Select Station',
        options: [
          for (final j in dishroomJobs)
            StitchSelectionOption(
              rowKey: ValueKey('dishroom-station-${j.name}'),
              label: j.name,
              icon: Icons.local_dining_rounded,
              selected: false,
              onTap: () => setState(() {
                _jobName = j.name;
                _step = 2;
              }),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_step == 2 && job != null) ...[
          buildAppHeaderTitle(context, 'Setup'),
          const SizedBox(height: StitchSpacing.xl),
            LocalPhaseChecklist(
              title: 'Setup (Before Doors Open)',
              tasks: job.setup,
              checks: _checks,
              onToggle: (id, checked) =>
                  setState(() => _checks[id] = checked),
            ),
            const SizedBox(height: StitchSpacing.md),
            StitchPrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward_rounded,
              onPressed: setupDone ? () => setState(() => _step = 3) : null,
            ),
        ] else if (_step == 3 && job != null) ...[
          buildAppHeaderTitle(context, 'Running'),
          const SizedBox(height: StitchSpacing.xl),
            LocalPhaseChecklist(
              title: 'During Shift (Doors Open)',
              tasks: job.during,
              checks: _checks,
              onToggle: (id, checked) =>
                  setState(() => _checks[id] = checked),
            ),
            const SizedBox(height: StitchSpacing.md),
            StitchPrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => setState(() => _step = 4),
            ),
        ] else if (_step == 4 && job != null) ...[
          buildAppHeaderTitle(context, 'Cleanup'),
          const SizedBox(height: StitchSpacing.xl),
            LocalPhaseChecklist(
              title: 'Cleanup (After Doors Close)',
              tasks: job.cleanup,
              checks: _checks,
              onToggle: (id, checked) =>
                  setState(() => _checks[id] = checked),
            ),
            const SizedBox(height: StitchSpacing.md),
            StitchPrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward_rounded,
              onPressed: cleanupDone
                  ? () => setState(() => _step = 5)
                  : null,
            ),
        ] else if (_step == 5) ...[
          buildAppHeaderTitle(context, 'Deep Clean'),
          const SizedBox(height: StitchSpacing.xl),
            LocalPhaseChecklist(
              title: 'Deep Clean',
              tasks: deepCleanTasks,
              checks: _checks,
              onToggle: (id, checked) =>
                  setState(() => _checks[id] = checked),
            ),
            const SizedBox(height: StitchSpacing.md),
            StitchPrimaryButton(
              label: 'Finish',
              icon: Icons.check_rounded,
              onPressed: deepCleanDone
                  ? () => setState(() => _step = 6)
                  : null,
            ),
        ],
      ],
    );
  }

  IconData _mealIcon(String meal) {
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
}

/// Lead-trainer support flow for dishroom trainees.
