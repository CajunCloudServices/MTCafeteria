part of '../dashboard_page.dart';

extension _SupervisorSectionViews on _SupervisorSectionState {
  Widget _buildSupervisorCompletionCard({
    required SupervisorBoard supervisorBoard,
    required List<SupervisorJobItem> completedJobs,
    required bool allSecondariesChecked,
  }) {
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
            Text(
              'Jobs complete: ${completedJobs.length}/${supervisorBoard.jobs.length}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF264D76),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Secondaries complete: ${allSecondariesChecked ? 'Yes' : 'No'} • Deep clean complete: ${widget.deepCleanChecked ? 'Yes' : 'No'}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF264D76),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1F5E9C).withValues(alpha: 0.35),
                ),
              ),
              child: const Text(
                'Shift complete. Submit your report and confirm handoff.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF113A67),
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onReturnToDashboardHub,
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
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
  }) {
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
                    icon: Icons.task_alt,
                    title: 'Supervisor Checkoff',
                  ),
                  const SizedBox(height: 10),
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
                ],
              ),
            ),
          ),
        ),
        if (_mealLoaded && widget.selectedJobId == null) ...[
          const SizedBox(height: 12),
          _buildMarkShiftFinishedButton(
            context: context,
            canMarkShiftFinished: canMarkShiftFinished,
            pendingJobs: pendingJobs,
            allSecondariesChecked: allSecondariesChecked,
            supervisorChecklistDone: supervisorChecklistDone,
            reportSubmitted: reportSubmitted,
          ),
          if (_shiftFinished) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF1F5E9C).withValues(alpha: 0.35),
                ),
              ),
              child: const Text(
                'Shift marked finished. You can still review jobs, secondaries, and deep clean.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF113A67),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSupervisorMealStep(SupervisorBoard supervisorBoard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedMeal,
          decoration: const InputDecoration(labelText: 'Meal'),
          isExpanded: true,
          items: supervisorBoard.meals
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _updateSupervisorState(() {
                _selectedMeal = value;
              });
            }
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              final meal = _selectedMeal ?? supervisorBoard.selectedMeal;
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
            child: const Text('Next'),
          ),
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
        Text(
          'Meal: ${supervisorBoard.selectedMeal}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _selectedView,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Section'),
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
        const SizedBox(height: 12),
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
        return const Text('Loading tasks...');
      }
      return _buildSupervisorJobDetail(context, supervisorBoard);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pending Jobs', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        if (pendingJobs.isEmpty)
          const Text('No remaining jobs.')
        else
          ...pendingJobs.map(
            (job) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFD0E3)),
              ),
              child: ListTile(
                dense: false,
                leading: const Icon(
                  Icons.radio_button_unchecked,
                  color: Color(0xFF6B7F96),
                ),
                title: Text(job.jobName),
                subtitle: Text(
                  '${job.checkedCount}/${job.totalCount} tasks checked',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => widget.onOpenJob(job.jobId),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Text('Completed Jobs', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        if (completedJobs.isEmpty)
          const Text('No completed jobs yet.')
        else
          ...completedJobs.map(
            (job) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7F1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC7DCCB)),
              ),
              child: ListTile(
                dense: false,
                leading: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                ),
                title: Text(job.jobName),
                subtitle: Text(
                  '${job.checkedCount}/${job.totalCount} tasks checked',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => widget.onOpenJob(job.jobId),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSupervisorJobDetail(
    BuildContext context,
    SupervisorBoard supervisorBoard,
  ) {
    final board = widget.jobTaskBoard!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB7CAE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            board.jobName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF123A65),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          ...board.tasks.map(
            (task) => CheckboxListTile(
              dense: false,
              controlAffinity: ListTileControlAffinity.leading,
              value: task.checked,
              title: Text(task.description),
              onChanged: (value) {
                if (value == null) return;
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
          ),
          if (board.tasks.any((task) => !task.checked)) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
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
                icon: const Icon(Icons.done_all_rounded),
                label: Text(
                  _markingAllJobTasks
                      ? 'Marking Complete...'
                      : 'Mark All as Complete',
                ),
              ),
            ),
          ],
          if (board.tasks.every((task) => task.checked)) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
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
                icon: const Icon(Icons.undo_rounded),
                label: const Text('Mark All as Incomplete'),
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showJobQuickReferenceDialog(
                context,
                jobName: board.jobName,
                lines: notesForJob(board.jobName),
              ),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('View Job Notes'),
            ),
          ),
          if (board.jobName == 'Condiments Prep') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showCondimentsRotationDialog(context),
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Condiment Rotation'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecondariesView({
    required List<MapEntry<int, SecondaryJobItem>> duringSecondaries,
    required List<MapEntry<int, SecondaryJobItem>> cleanupSecondaries,
  }) {
    return Column(
      children: [
        _buildSecondaryPhaseCard(
          title: 'During Shift',
          entries: duringSecondaries,
        ),
        const SizedBox(height: 12),
        _buildSecondaryPhaseCard(title: 'Cleanup', entries: cleanupSecondaries),
      ],
    );
  }

  Widget _buildSecondaryPhaseCard({
    required String title,
    required List<MapEntry<int, SecondaryJobItem>> entries,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFD0E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF123A65),
            ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const Text('No tasks in this section.')
          else
            ...entries.map(
              (entry) => CheckboxListTile(
                dense: false,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                value: entry.value.checked,
                title: Text(entry.value.name),
                onChanged: (value) {
                  if (value != null) {
                    widget.onSecondaryToggle(entry.key, value);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeepCleanView(SupervisorBoard supervisorBoard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deep Clean • ${supervisorBoard.selectedMeal}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Text(weekdayNameLabel(DateTime.now().weekday)),
        CheckboxListTile(
          dense: false,
          controlAffinity: ListTileControlAffinity.leading,
          value: widget.deepCleanChecked,
          title: const Text('Deep Clean'),
          onChanged: (value) {
            if (value != null) {
              widget.onDeepCleanToggle(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSupervisorEndOfShiftView() {
    return Container(
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
            'Supervisor End-of-Shift Checkoff',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...supervisorEndShiftCheckoffItems.map(
            (item) => CheckboxListTile(
              dense: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              controlAffinity: ListTileControlAffinity.leading,
              value: _supervisorEndShiftChecks[item] ?? false,
              title: Text(item),
              onChanged: (value) {
                if (value == null) return;
                _updateSupervisorState(() {
                  _supervisorEndShiftChecks = {
                    ..._supervisorEndShiftChecks,
                    item: value,
                  };
                });
              },
            ),
          ),
        ],
      ),
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

  Widget _buildMarkShiftFinishedButton({
    required BuildContext context,
    required bool canMarkShiftFinished,
    required List<SupervisorJobItem> pendingJobs,
    required bool allSecondariesChecked,
    required bool supervisorChecklistDone,
    required bool reportSubmitted,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () async {
          if (canMarkShiftFinished) {
            if (!mounted) return;
            _updateSupervisorState(() {
              _shiftFinished = true;
            });
            return;
          }

          _showShiftFinishRequirements(
            context: context,
            pendingJobNames: pendingJobs.map((job) => job.jobName).toList(),
            allSecondariesChecked: allSecondariesChecked,
            deepCleanChecked: widget.deepCleanChecked,
            supervisorChecklistDone: supervisorChecklistDone,
            reportSubmitted: reportSubmitted,
          );
        },
        child: const Text('Mark Shift Finished'),
      ),
    );
  }
}
