part of '../dashboard_page.dart';

extension _SupervisorSectionViews on _SupervisorSectionState {
  Widget _buildSupervisorInfoChip(String text) {
    return StitchChip(label: text, tone: StitchChipTone.secondary);
  }

  Widget _buildSupervisorAssignmentCard({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cleaning_services_rounded,
              size: 20,
              color: StitchColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: StitchText.titleMd)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 6,
                  width: 6,
                  decoration: const BoxDecoration(
                    color: StitchColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: StitchText.bodyLg)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisorCompletionCard({
    required SupervisorBoard supervisorBoard,
    required List<SupervisorJobItem> completedJobs,
    required bool allSecondariesChecked,
  }) {
    final jobsCompletion =
        '${completedJobs.length}/${supervisorBoard.jobs.length}';
    return StitchSuccessCard(
      title: 'Shift Complete',
      message:
          'All supervisor duties logged. You are cleared to close the '
          'line.',
      stats: [
        StitchSuccessStat(value: jobsCompletion, label: 'Jobs'),
        StitchSuccessStat(
          value: allSecondariesChecked && widget.deepCleanChecked
              ? '100%'
              : 'Review',
          label: 'Secondaries',
        ),
      ],
      primaryCtaLabel: 'Back to Dashboard',
      primaryIcon: Icons.dashboard_rounded,
      onPrimary: () async {
        await widget.onReturnToDashboardHub();
      },
    );
  }

  Widget _buildSupervisorMainLayout({
    required BuildContext context,
    required SupervisorBoard supervisorBoard,
    required List<SupervisorJobItem> pendingJobs,
    required List<SupervisorJobItem> completedJobs,
    required List<MapEntry<int, SecondaryJobItem>> duringSecondaries,
    required List<MapEntry<int, SecondaryJobItem>> cleanupSecondaries,
    required bool canMarkShiftFinished,
    required bool allSecondariesChecked,
    required bool supervisorChecklistDone,
    required bool reportSubmitted,
    required int totalProgressUnits,
    required int completedProgressUnits,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_mealLoaded)
          _buildSupervisorMealStep(supervisorBoard)
        else
          _buildSupervisorLoadedContent(
            context: context,
            supervisorBoard: supervisorBoard,
            pendingJobs: pendingJobs,
            completedJobs: completedJobs,
            duringSecondaries: duringSecondaries,
            cleanupSecondaries: cleanupSecondaries,
          ),
        if (_mealLoaded && widget.selectedJobId == null) ...[
          const SizedBox(height: StitchSpacing.lg),
          _buildSupervisorCompletionProgress(
            canMarkShiftFinished: canMarkShiftFinished,
            totalProgressUnits: totalProgressUnits,
            completedProgressUnits: completedProgressUnits,
          ),
          if (_shiftFinished) ...[
            const SizedBox(height: StitchSpacing.md),
            Row(
              children: [
                const Icon(Icons.info_rounded, color: StitchColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Shift marked finished. You can still review jobs, '
                    'secondaries, and deep clean.',
                    style: StitchText.bodyStrong,
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSupervisorMealStep(SupervisorBoard supervisorBoard) {
    return StitchSelectionScreen(
      title: 'Select Meal',
      options: [
        for (final meal in supervisorBoard.meals)
          StitchSelectionOption(
            rowKey: ValueKey('supervisor-meal-$meal'),
            label: meal,
            icon: _iconForMeal(meal),
            selected: _selectedMeal == meal,
            onTap: () async {
              _updateSupervisorState(() {
                _selectedMeal = meal;
              });
              final previousMeal = supervisorBoard.selectedMeal;
              await widget.onSelectMeal(meal);
              if (meal != previousMeal) {
                await widget.onResetAll();
                await widget.onSelectMeal(meal);
              }
              if (!mounted) return;
              await widget.onLoadDailyShiftReport(meal);
              if (!mounted) return;
              _updateSupervisorState(() {
                _mealLoaded = true;
                _shiftFinished = false;
                _selectedView = 'Jobs';
              });
              widget.onPanelModeChanged('Jobs');
            },
          ),
      ],
    );
  }

  Widget _buildSupervisorLoadedContent({
    required BuildContext context,
    required SupervisorBoard supervisorBoard,
    required List<SupervisorJobItem> pendingJobs,
    required List<SupervisorJobItem> completedJobs,
    required List<MapEntry<int, SecondaryJobItem>> duringSecondaries,
    required List<MapEntry<int, SecondaryJobItem>> cleanupSecondaries,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StitchChip(
              label: 'MEAL · ${supervisorBoard.selectedMeal.toUpperCase()}',
              tone: StitchChipTone.secondary,
            ),
          ],
        ),
        const SizedBox(height: StitchSpacing.md),
        StitchDropdownField<String>(
          value: _selectedView,
          label: 'Section',
          items: const [
            DropdownMenuItem(value: 'Jobs', child: Text('Jobs')),
            DropdownMenuItem(value: 'Secondaries', child: Text('Secondaries')),
            DropdownMenuItem(value: 'Deep Clean', child: Text('Deep Clean')),
            DropdownMenuItem(
              value: 'Supervisor End-of-Shift',
              child: Text('Supervisor End-of-Shift'),
            ),
            DropdownMenuItem(
              value: 'Daily Shift Report',
              child: Text('Daily Shift Report'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateSupervisorState(() {
                _selectedView = value;
              });
              widget.onPanelModeChanged(value);
            }
          },
        ),
        const SizedBox(height: StitchSpacing.lg),
        if (_selectedView == 'Jobs')
          _buildSupervisorJobsView(
            context: context,
            supervisorBoard: supervisorBoard,
            pendingJobs: pendingJobs,
            completedJobs: completedJobs,
          )
        else if (_selectedView == 'Secondaries')
          _buildSecondariesView(
            duringSecondaries: duringSecondaries,
            cleanupSecondaries: cleanupSecondaries,
          )
        else if (_selectedView == 'Deep Clean')
          _buildDeepCleanView(supervisorBoard)
        else if (_selectedView == 'Supervisor End-of-Shift')
          _buildSupervisorEndOfShiftView()
        else
          _buildDailyShiftReportView(supervisorBoard),
      ],
    );
  }

  Widget _buildSupervisorJobsView({
    required BuildContext context,
    required SupervisorBoard supervisorBoard,
    required List<SupervisorJobItem> pendingJobs,
    required List<SupervisorJobItem> completedJobs,
  }) {
    if (widget.selectedJobId != null) {
      if (widget.jobTaskBoard == null) {
        return Text('Loading tasks…', style: StitchText.body);
      }
      return _buildSupervisorJobDetail(context, supervisorBoard);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SupervisorJobsSection(
          label: 'PENDING JOBS',
          emptyText: 'No remaining jobs.',
          jobs: pendingJobs,
          onOpen: widget.onOpenJob,
          leadingIcon: Icons.radio_button_unchecked_rounded,
          accent: StitchColors.primary,
        ),
        const SizedBox(height: StitchSpacing.lg),
        _SupervisorJobsSection(
          label: 'COMPLETED JOBS',
          emptyText: 'No completed jobs yet.',
          jobs: completedJobs,
          onOpen: widget.onOpenJob,
          leadingIcon: Icons.check_circle_rounded,
          accent: const Color(0xFF2E7D32),
        ),
      ],
    );
  }

  Widget _buildSupervisorJobDetail(
    BuildContext context,
    SupervisorBoard supervisorBoard,
  ) {
    final board = widget.jobTaskBoard!;
    final completedCount = board.tasks.where((t) => t.checked).length;
    final actionSurface = StitchColors.primaryFixed;
    final actionForeground = StitchColors.onPrimaryFixed;
    final actionBorder = StitchColors.primaryFixedDim;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(board.jobName, style: StitchText.titleLg),
        const SizedBox(height: 4),
        Text(
          '$completedCount of ${board.tasks.length} tasks checked',
          style: StitchText.bodyStrong.copyWith(
            color: StitchColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: StitchSpacing.lg),
        if (board.tasks.any((task) => !task.checked)) ...[
          StitchSecondaryButton(
            label: _markingAllJobTasks
                ? 'Marking Complete...'
                : 'Mark All as Complete',
            icon: Icons.done_all_rounded,
            background: StitchColors.primary,
            foreground: StitchColors.onPrimary,
            border: StitchColors.primaryContainer,
            onPressed: _markingAllJobTasks
                ? null
                : () async {
                    final remainingTaskIds = board.tasks
                        .where((task) => !task.checked)
                        .map((task) => task.taskId)
                        .toList();
                    if (remainingTaskIds.isEmpty) return;
                    final activeJobId = widget.selectedJobId;
                    final request = widget.onBulkToggleTasks(
                      remainingTaskIds,
                      true,
                    );
                    if (activeJobId != null) {
                      _markJobOptimisticallyComplete(
                        activeJobId,
                        supervisorBoard.selectedMeal,
                      );
                      unawaited(
                        _syncOptimisticCompletion(
                          jobId: activeJobId,
                          request: request,
                        ),
                      );
                    } else {
                      unawaited(request);
                    }
                    _updateSupervisorState(() {
                      _selectedView = 'Jobs';
                    });
                    widget.onPanelModeChanged('Jobs');
                    widget.onBackToJobs();
                  },
          ),
          const SizedBox(height: StitchSpacing.lg),
        ],
        if (board.tasks.every((task) => task.checked)) ...[
          StitchSecondaryButton(
            label: 'Mark All as Incomplete',
            icon: Icons.undo_rounded,
            background: actionSurface,
            foreground: actionForeground,
            border: actionBorder,
            onPressed: _markingAllJobTasks
                ? null
                : () {
                    final checkedTaskIds = board.tasks
                        .where((task) => task.checked)
                        .map((task) => task.taskId)
                        .toList();
                    if (checkedTaskIds.isEmpty) return;
                    final activeJobId = widget.selectedJobId;
                    if (activeJobId != null) {
                      _updateSupervisorState(() {
                        _optimisticallyCompletedJobIds.remove(activeJobId);
                        if (_optimisticallyCompletedJobIds.isEmpty) {
                          _optimisticCompletionMeal = null;
                        }
                      });
                    }
                    unawaited(
                      widget.onBulkToggleTasks(checkedTaskIds, false),
                    );
                  },
          ),
          const SizedBox(height: StitchSpacing.lg),
        ],
        StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.lg),
          elevation: StitchCardElevation.card,
          surface: StitchSurface.low,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final task in board.tasks) ...[
                StitchChecklistTile(
                  title: task.description,
                  checked: task.checked,
                  onChanged: (value) {
                    final activeJobId = widget.selectedJobId;
                    final remainingUnchecked = board.tasks
                        .where((t) => !t.checked)
                        .length;
                    final completesJobNow =
                        value && !task.checked && remainingUnchecked == 1;
                    final request = widget.onToggleTask(task.taskId, value);
                    if (completesJobNow) {
                      if (activeJobId != null) {
                        _markJobOptimisticallyComplete(
                          activeJobId,
                          supervisorBoard.selectedMeal,
                        );
                        unawaited(
                          _syncOptimisticCompletion(
                            jobId: activeJobId,
                            request: request,
                          ),
                        );
                      }
                      _updateSupervisorState(() {
                        _selectedView = 'Jobs';
                      });
                      widget.onPanelModeChanged('Jobs');
                      widget.onBackToJobs();
                    } else {
                      unawaited(request);
                    }
                  },
                ),
                const SizedBox(height: StitchSpacing.md),
              ],
            ],
          ),
        ),
        const SizedBox(height: StitchSpacing.md),
        StitchSecondaryButton(
          label: 'View Job Notes',
          icon: Icons.menu_book_rounded,
          background: actionSurface,
          foreground: actionForeground,
          border: actionBorder,
          onPressed: () => showJobQuickReferenceDialog(
            context,
            jobName: board.jobName,
            lines: notesForJob(board.jobName),
          ),
        ),
        if (board.jobName == 'Condiments Prep') ...[
          const SizedBox(height: StitchSpacing.md),
          StitchSecondaryButton(
            label: 'Condiment Rotation',
            icon: Icons.tune_rounded,
            background: actionSurface,
            foreground: actionForeground,
            border: actionBorder,
            onPressed: () => showCondimentsRotationDialog(context),
          ),
        ],
      ],
    );
  }

  Widget _buildSecondariesView({
    required List<MapEntry<int, SecondaryJobItem>> duringSecondaries,
    required List<MapEntry<int, SecondaryJobItem>> cleanupSecondaries,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSecondaryPhaseCard(
          title: 'During Shift',
          entries: duringSecondaries,
        ),
        const SizedBox(height: StitchSpacing.lg),
        _buildSecondaryPhaseCard(title: 'Cleanup', entries: cleanupSecondaries),
      ],
    );
  }

  Widget _buildSecondaryPhaseCard({
    required String title,
    required List<MapEntry<int, SecondaryJobItem>> entries,
  }) {
    final total = entries.length;
    final done = entries.where((e) => e.value.checked).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StitchProgressCard(
          title: title,
          completed: done,
          total: total,
          leadingIcon: Icons.checklist_rounded,
        ),
        const SizedBox(height: StitchSpacing.md),
        if (entries.isEmpty)
          Text('No tasks in this section.', style: StitchText.body)
        else
          StitchCard(
            padding: const EdgeInsets.all(StitchSpacing.lg),
            elevation: StitchCardElevation.card,
            surface: StitchSurface.low,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  StitchChecklistTile(
                    title: entries[i].value.name,
                    checked: entries[i].value.checked,
                    onChanged: (value) =>
                        widget.onSecondaryToggle(entries[i].key, value),
                  ),
                  if (i < entries.length - 1)
                    const SizedBox(height: StitchSpacing.md),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDeepCleanView(SupervisorBoard supervisorBoard) {
    final dayKey = weekdayNameLabel(DateTime.now().weekday).toLowerCase();
    final assignment = lineDeepCleaningAssignmentFor(
      dayKey,
      supervisorBoard.selectedMeal,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSupervisorInfoChip(
              weekdayNameLabel(DateTime.now().weekday).toUpperCase(),
            ),
            _buildSupervisorInfoChip(
              supervisorBoard.selectedMeal.toUpperCase(),
            ),
          ],
        ),
        const SizedBox(height: StitchSpacing.md),
        _buildSupervisorAssignmentCard(
          title: "Today's Assignment",
          items: [
            assignment ??
                'No deep cleaning assignment found for this day and meal.',
          ],
        ),
        const SizedBox(height: StitchSpacing.md),
        StitchChecklistTile(
          title: 'Deep Clean Completed',
          checked: widget.deepCleanChecked,
          onChanged: (value) => widget.onDeepCleanToggle(value),
        ),
      ],
    );
  }

  Widget _buildSupervisorEndOfShiftView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Supervisor End-of-Shift Checkoff', style: StitchText.titleMd),
        const SizedBox(height: StitchSpacing.md),
        for (final item in supervisorEndShiftCheckoffItems) ...[
          StitchChecklistTile(
            title: item,
            checked: _supervisorEndShiftChecks[item] ?? false,
            onChanged: (value) {
              _updateSupervisorState(() {
                _supervisorEndShiftChecks = {
                  ..._supervisorEndShiftChecks,
                  item: value,
                };
              });
            },
          ),
          const SizedBox(height: StitchSpacing.md),
        ],
      ],
    );
  }

  Widget _buildDailyShiftReportView(SupervisorBoard supervisorBoard) {
    return SupervisorDailyShiftReportForm(
      key: ValueKey('daily-report-form-${supervisorBoard.selectedMeal}'),
      meal: supervisorBoard.selectedMeal,
      currentReport: widget.currentLineShiftReport,
      onSave: widget.onSaveDailyShiftReport,
      onSubmit: widget.onSubmitDailyShiftReport,
    );
  }

  Widget _buildMarkShiftFinishedButton({required bool canMarkShiftFinished}) {
    return StitchPrimaryButton(
      label: 'Mark Shift Finished',
      icon: Icons.flag_rounded,
      onPressed: canMarkShiftFinished
          ? () {
              _updateSupervisorState(() {
                _shiftFinished = true;
              });
            }
          : null,
    );
  }

  Widget _buildSupervisorCompletionProgress({
    required bool canMarkShiftFinished,
    required int totalProgressUnits,
    required int completedProgressUnits,
  }) {
    final safeTotal = totalProgressUnits <= 0 ? 1 : totalProgressUnits;
    final clampedCompleted = completedProgressUnits.clamp(0, safeTotal);
    final progress = clampedCompleted / safeTotal;
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Shift Progress', style: StitchText.titleMd)),
            Text(
              '$percent%',
              style: StitchText.metricSm.copyWith(fontSize: 22),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(StitchRadii.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: StitchColors.surfaceContainer,
            valueColor: const AlwaysStoppedAnimation<Color>(
              StitchColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$clampedCompleted of $safeTotal items complete',
          style: StitchText.body,
        ),
        if (canMarkShiftFinished) ...[
          const SizedBox(height: StitchSpacing.lg),
          _buildMarkShiftFinishedButton(
            canMarkShiftFinished: canMarkShiftFinished,
          ),
        ],
      ],
    );
  }
}

class _SupervisorJobsSection extends StatelessWidget {
  const _SupervisorJobsSection({
    required this.label,
    required this.emptyText,
    required this.jobs,
    required this.onOpen,
    required this.leadingIcon,
    required this.accent,
  });

  final String label;
  final String emptyText;
  final List<SupervisorJobItem> jobs;
  final void Function(int jobId) onOpen;
  final IconData leadingIcon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: StitchText.eyebrow),
        ),
        if (jobs.isEmpty)
          Text(emptyText, style: StitchText.body)
        else
          for (final job in jobs) ...[
            StitchListRow(
              title: job.jobName,
              subtitle: '${job.checkedCount}/${job.totalCount} tasks checked',
              leadingIcon: leadingIcon,
              leadingBackground: accent.withValues(alpha: 0.12),
              leadingForeground: accent,
              onTap: () => onOpen(job.jobId),
            ),
            const SizedBox(height: StitchSpacing.md),
          ],
      ],
    );
  }
}
