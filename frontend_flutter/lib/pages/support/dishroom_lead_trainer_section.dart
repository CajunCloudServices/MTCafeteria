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
  int _traineeCount = 1;
  int _selectedTrainee = 0;
  final Map<int, String?> _traineeJob = {};
  final Map<int, Map<String, bool>> _traineeChecks = {};
  final Map<int, bool> _traineeCheckedOff = {};
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
        _traineeCount = 1;
        _selectedTrainee = 0;
        _traineeJob.clear();
        _traineeChecks.clear();
        _traineeCheckedOff.clear();
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
    void maybePromptForShiftFinish() {
      final ready = _step == 3 && _allTraineesCheckedOff;
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
        if (!mounted || !shouldFinish || _step != 3) return;
        setState(() => _step = 4);
      });
    }

    maybePromptForShiftFinish();

    if (_step >= 4) {
      return SimpleFinishCard(
        title: 'Dishroom Trainer Shift Complete',
        message:
            'All trainees checked off. Submit shift email report and report to the supervisor.',
      );
    }

    if (_step == 0) {
      return StitchSelectionScreen(
        title: 'Select Meal',
        options: [
          for (final meal in _localMeals)
            StitchSelectionOption(
              rowKey: ValueKey('dishroom-trainer-meal-$meal'),
              label: meal,
              icon: _mealIcon(meal),
              selected: false,
              onTap: () => setState(() {
                _step = 1;
              }),
            ),
        ],
      );
    }

    Widget centeredSetupStep(Widget child) {
      final media = MediaQuery.of(context);
      final minHeight =
          (media.size.height -
                  media.padding.vertical -
                  appHeaderToolbarHeight(context) -
                  kBottomNavigationBarHeight -
                  36)
              .clamp(0.0, media.size.height);
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: StitchSpacing.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_step == 1) {
      final count = _traineeCount.clamp(1, 12);
      return centeredSetupStep(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Trainee Count',
              style: StitchText.bodyStrong.copyWith(
                color: StitchColors.onSurface,
              ),
            ),
            const SizedBox(height: StitchSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: StitchSpacing.md,
                vertical: StitchSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: StitchColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(StitchRadii.md),
                border: Border.all(color: StitchColors.outlineVariant),
              ),
              child: Row(
                children: [
                  _DishroomLeadTrainerCountButton(
                    tooltip: 'Decrease trainee count',
                    icon: Icons.remove_rounded,
                    onPressed: count > 1
                        ? () => setState(() => _traineeCount = count - 1)
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$count',
                          style: StitchText.titleLg.copyWith(
                            color: StitchColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          count == 1 ? 'trainee' : 'trainees',
                          style: StitchText.bodyStrong.copyWith(
                            color: StitchColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  _DishroomLeadTrainerCountButton(
                    tooltip: 'Increase trainee count',
                    icon: Icons.add_rounded,
                    onPressed: count < 12
                        ? () => setState(() => _traineeCount = count + 1)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: StitchSpacing.lg),
            StitchPrimaryButton(
              label: 'Continue',
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () => setState(() {
                _traineeCount = count;
                for (var i = 0; i < count; i += 1) {
                  _traineeJob.putIfAbsent(i, () => null);
                }
                _traineeJob.removeWhere((key, value) => key >= count);
                if (_selectedTrainee >= count) {
                  _selectedTrainee = count - 1;
                }
                _step = 2;
              }),
            ),
          ],
        ),
      );
    }

    if (_step == 2) {
      return centeredSetupStep(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var slot = 0; slot < _traineeCount; slot++) ...[
              Text(
                'Trainee ${slot + 1}',
                style: StitchText.bodyStrong.copyWith(
                  color: StitchColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              StitchDropdownField<String>(
                value: _traineeJob[slot],
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
              if (slot < _traineeCount - 1)
                const SizedBox(height: StitchSpacing.lg),
            ],
            const SizedBox(height: StitchSpacing.lg),
            StitchPrimaryButton(
              label: 'Continue',
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: List.generate(
                _traineeCount,
                (i) => _traineeJob[i],
              ).every((job) => job != null)
                  ? () => setState(() => _step = 3)
                  : null,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelTitle(
          icon: Icons.groups_rounded,
          title: 'Dishroom Trainee Support',
        ),
        const SizedBox(height: StitchSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(StitchRadii.sm),
          child: LinearProgressIndicator(
            value: (_step + 1) / 5,
            minHeight: 6,
            backgroundColor: StitchColors.surfaceContainer,
            color: StitchColors.primary,
          ),
        ),
          const SizedBox(height: StitchSpacing.md),
          if (_step == 3) ...[
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
            const SizedBox(height: StitchSpacing.sm),
            _buildTraineeChecklist(_selectedTrainee),
            const SizedBox(height: StitchSpacing.sm),
            StitchSecondaryButton(
              label: (_traineeCheckedOff[_selectedTrainee] ?? false)
                  ? 'Trainee Checked Off'
                  : 'Mark Trainee Checked Off',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _traineeTasksComplete(_selectedTrainee)
                  ? () => setState(
                      () => _traineeCheckedOff[_selectedTrainee] = true,
                    )
                  : null,
            ),
            const SizedBox(height: StitchSpacing.md),
            StitchPrimaryButton(
              label: 'Finish',
              icon: Icons.check_rounded,
              onPressed: _allTraineesCheckedOff
                  ? () => setState(() => _step = 4)
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

  Widget _buildTraineeChecklist(int slot) {
    final jobName = _traineeJob[slot];
    if (jobName == null) {
      return Text('Assign a job to this trainee first.', style: StitchText.body);
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

class _DishroomLeadTrainerCountButton extends StatelessWidget {
  const _DishroomLeadTrainerCountButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null
          ? StitchColors.surfaceContainer
          : StitchColors.primaryFixed,
      borderRadius: BorderRadius.circular(StitchRadii.sm),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed == null
              ? StitchColors.onSurfaceVariant
              : StitchColors.onPrimaryFixed,
        ),
      ),
    );
  }
}

/// Reference-first kitchen jobs section used for main dish, salads, and
/// desserts.
