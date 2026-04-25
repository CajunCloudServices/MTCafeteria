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
  int _step = 0;
  String? _selectedMeal;
  int? _selectedCount;
  Map<int, bool> _traineeCheckedOff = {};
  Map<String, bool> _leadTrainerEndShiftChecks = {};
  bool _shiftFinished = false;
  bool _hasPromptedForCurrentCompletion = false;
  bool _finishPromptOpen = false;

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
        _step = 0;
        _shiftFinished = false;
        _traineeCheckedOff = {};
        _leadTrainerEndShiftChecks = {};
        _hasPromptedForCurrentCompletion = false;
        _finishPromptOpen = false;
      });
    }
    if (widget.backSignal != _lastBackSignal) {
      _lastBackSignal = widget.backSignal;
      if (_shiftFinished) {
        setState(() {
          _shiftFinished = false;
          _hasPromptedForCurrentCompletion = false;
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
      return StitchCard(
        padding: const EdgeInsets.all(StitchSpacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loading trainer board…', style: StitchText.titleMd),
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

    void maybePromptForShiftFinish() {
      final ready =
          _step == 4 &&
          allTraineesCheckedOff &&
          leadTrainerChecklistDone &&
          !_shiftFinished;
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
        if (!mounted || !shouldFinish || _step != 4) return;
        setState(() {
          _shiftFinished = true;
        });
      });
    }

    maybePromptForShiftFinish();

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

    if (_shiftFinished) {
      return _buildLeadTrainerCompletionCard(checkedOffCount);
    }

    if (_step == 0) {
      return StitchSelectionScreen(
        title: 'Select Meal',
        options: [
          for (final meal in trainerBoard.meals)
            StitchSelectionOption(
              rowKey: ValueKey('lead-trainer-meal-$meal'),
              label: meal,
              icon: _iconForMeal(meal),
              selected: _selectedMeal == meal,
              onTap: () async {
                setState(() => _selectedMeal = meal);
                await widget.onSelectMeal(meal);
                if (!mounted) return;
                setState(() {
                  _step = 1;
                  _shiftFinished = false;
                  _traineeCheckedOff = {
                    for (var i = 0; i < widget.traineeCount; i += 1) i: false,
                  };
                });
              },
            ),
        ],
      );
    }

    if (_step == 1) {
      final count = (_selectedCount ?? widget.traineeCount).clamp(1, 12);
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
                  _LeadTrainerCountButton(
                    tooltip: 'Decrease trainee count',
                    icon: Icons.remove_rounded,
                    onPressed: count > 1
                        ? () => setState(() => _selectedCount = count - 1)
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
                          style: StitchText.body.copyWith(
                            color: StitchColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  _LeadTrainerCountButton(
                    tooltip: 'Increase trainee count',
                    icon: Icons.add_rounded,
                    onPressed: count < 12
                        ? () => setState(() => _selectedCount = count + 1)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: StitchSpacing.lg),
            StitchPrimaryButton(
              label: 'Continue',
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () {
                widget.onSetTraineeCount(count);
                setState(() {
                  _step = 2;
                  _shiftFinished = false;
                  _traineeCheckedOff = {
                    for (var i = 0; i < count; i += 1) i: false,
                  };
                });
              },
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
            for (var slot = 0; slot < widget.traineeCount; slot++) ...[
              Text(
                'Trainee ${slot + 1}',
                style: StitchText.bodyStrong.copyWith(
                  color: StitchColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              StitchDropdownField<int>(
                value: widget.traineeJobBySlot[slot],
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
              if (slot < widget.traineeCount - 1)
                const SizedBox(height: StitchSpacing.lg),
            ],
            const SizedBox(height: StitchSpacing.lg),
            StitchPrimaryButton(
              label: 'Continue',
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: allAssigned
                  ? () {
                      widget.onSelectTraineeSlot(0);
                      setState(() {
                        _step = 3;
                      });
                    }
                  : null,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: StitchSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_step == 3) ...[
          StitchDropdownField<int>(
            value: selectedSlot,
            label: 'Trainee',
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
          const SizedBox(height: StitchSpacing.md),
          if (_jobLabelForSlot(trainerBoard, selectedSlot) != 'Unassigned') ...[
            Row(
              children: [
                Expanded(
                  child: StitchSecondaryButton(
                    label: 'View Job Notes',
                    icon: Icons.menu_book_rounded,
                    onPressed: () => showJobQuickReferenceDialog(
                      context,
                      jobName: _jobLabelForSlot(trainerBoard, selectedSlot),
                      lines: notesForJob(
                        _jobLabelForSlot(trainerBoard, selectedSlot),
                      ),
                    ),
                  ),
                ),
                if (_jobLabelForSlot(trainerBoard, selectedSlot) ==
                    'Condiments Prep') ...[
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
            const SizedBox(height: StitchSpacing.md),
          ],
          _TrainerPhaseChecklist(
            phase: 'Setup (Before Doors Open)',
            tasks: selectedTasks.where((t) => t.phase == 'Setup').toList(),
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
            tasks: selectedTasks.where((t) => t.phase == 'Cleanup').toList(),
            slot: selectedSlot,
            onToggle: widget.onTaskToggle,
          ),
          const SizedBox(height: StitchSpacing.md),
          StitchProgressCard(
            title: 'Checkoff Progress',
            completed: checkedOffCount,
            total: widget.traineeCount,
            leadingIcon: Icons.verified_rounded,
          ),
          const SizedBox(height: StitchSpacing.md),
          StitchPrimaryButton(
            label: selectedTraineeCheckedOff
                ? 'Checked Off'
                : 'Check Off Trainee',
            icon: selectedTraineeCheckedOff
                ? Icons.check_circle_rounded
                : Icons.how_to_reg_rounded,
            onPressed: selectedTraineeCompleted && !selectedTraineeCheckedOff
                ? () {
                    setState(() {
                      _traineeCheckedOff = {
                        ..._traineeCheckedOff,
                        selectedSlot: true,
                      };
                    });
                  }
                : null,
          ),
          if (allTraineesCheckedOff) ...[
            const SizedBox(height: StitchSpacing.md),
            StitchPrimaryButton(
              label: 'Continue',
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () {
                setState(() {
                  _step = 4;
                });
              },
            ),
          ],
          ] else ...[
          Text(
            'Lead Trainer End-of-Shift Checkoff',
            style: StitchText.titleMd,
          ),
          const SizedBox(height: StitchSpacing.md),
          for (final item in leadTrainerEndShiftCheckoffItems) ...[
            StitchChecklistTile(
              title: item,
              checked: _leadTrainerEndShiftChecks[item] ?? false,
              onChanged: (value) {
                setState(() {
                  _leadTrainerEndShiftChecks = {
                    ..._leadTrainerEndShiftChecks,
                    item: value,
                  };
                });
              },
            ),
            const SizedBox(height: StitchSpacing.md),
          ],
          ],
          if (_step == 4 &&
              allTraineesCheckedOff &&
              leadTrainerChecklistDone &&
              !_shiftFinished) ...[
            const SizedBox(height: StitchSpacing.lg),
            StitchPrimaryButton(
              label: 'Finish Shift',
              icon: Icons.flag_rounded,
              height: StitchLayout.ctaHeightLg,
              onPressed: () {
                setState(() {
                  _shiftFinished = true;
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _LeadTrainerCountButton extends StatelessWidget {
  const _LeadTrainerCountButton({
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
