import 'package:flutter/material.dart';

import '../config/runtime_config.dart';
import '../models/admin_task_board.dart';
import '../services/api_client.dart';

/// Admin-only page for managing the canonical list of jobs and their tasks.
///
/// Access is gated by a dedicated password that the caller must have already
/// collected via [promptForTaskEditorPassword]. The password is sent on every
/// backend request. If the backend ever rejects it, the page prompts the
/// caller to cancel and re-unlock instead of silently failing.
class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({
    super.key,
    required this.authToken,
    this.apiClient,
  });

  final String authToken;
  final ApiClient? apiClient;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  late final ApiClient _api = widget.apiClient ??
      ApiClient(runtimeConfig: AppRuntimeConfig.fromEnvironment);

  AdminTaskBoard? _board;
  bool _loading = false;
  String? _error;
  String _mealFilter = 'All';
  final Set<int> _expandedJobIds = <int>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  List<String> get _mealOptions {
    final board = _board;
    if (board == null) return const ['All'];
    final meals = <String>{};
    for (final shift in board.shifts) {
      if (shift.mealType.isNotEmpty) meals.add(shift.mealType);
    }
    final sorted = meals.toList()..sort();
    return ['All', ...sorted];
  }

  List<AdminJob> get _visibleJobs {
    final board = _board;
    if (board == null) return const [];
    if (_mealFilter == 'All') return board.jobs;
    return board.jobs.where((job) => job.mealType == _mealFilter).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final board = await _api.getTaskAdminBoard(widget.authToken);
      if (!mounted) return;
      setState(() {
        _board = board;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleCreateJob() async {
    final board = _board;
    if (board == null) return;
    final shifts = board.shifts;
    if (shifts.isEmpty) {
      _toast('No shifts available to attach a job to.');
      return;
    }
    final result = await showDialog<_JobFormResult>(
      context: context,
      builder: (_) => _JobFormDialog(
        title: 'Add Job',
        shifts: shifts,
        initialShiftId: shifts.first.id,
      ),
    );
    if (result == null) return;
    try {
      await _api.createAdminJob(
        widget.authToken,
        name: result.name,
        shiftId: result.shiftId,
      );
      _toast('Job created');
      await _refresh();
    } on ApiClientException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> _handleRenameJob(AdminJob job) async {
    final board = _board;
    if (board == null) return;
    final result = await showDialog<_JobFormResult>(
      context: context,
      builder: (_) => _JobFormDialog(
        title: 'Rename Job',
        shifts: board.shifts,
        initialName: job.name,
        initialShiftId: job.shiftId,
        lockShift: true,
      ),
    );
    if (result == null) return;
    try {
      await _api.renameAdminJob(
        widget.authToken,
        jobId: job.id,
        name: result.name,
      );
      _toast('Job renamed');
      await _refresh();
    } on ApiClientException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> _handleDeleteJob(AdminJob job) async {
    final confirmed = await _confirm(
      title: 'Delete job?',
      message:
          'This will permanently remove "${job.name}" (${job.mealType ?? 'shift'}) and all of its tasks.',
      destructiveLabel: 'Delete',
    );
    if (!confirmed) return;
    try {
      await _api.deleteAdminJob(widget.authToken, job.id);
      _toast('Job deleted');
      await _refresh();
    } on ApiClientException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> _handleCreateTask(AdminJob job, String phase) async {
    final result = await showDialog<_TaskFormResult>(
      context: context,
      builder: (_) => _TaskFormDialog(
        title: 'Add $phase Task',
        phases: _board?.phases ?? const ['Setup', 'During Shift', 'Cleanup'],
        initialPhase: phase,
      ),
    );
    if (result == null) return;
    try {
      await _api.createAdminTask(
        widget.authToken,
        jobId: job.id,
        description: result.description,
        phase: result.phase,
        requiresCheckoff: result.requiresCheckoff,
      );
      _toast('Task added');
      await _refresh();
    } on ApiClientException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> _handleEditTask(AdminJob job, AdminTask task) async {
    final result = await showDialog<_TaskFormResult>(
      context: context,
      builder: (_) => _TaskFormDialog(
        title: 'Edit Task',
        phases: _board?.phases ?? const ['Setup', 'During Shift', 'Cleanup'],
        initialDescription: task.description,
        initialPhase: task.phase,
        initialRequiresCheckoff: task.requiresCheckoff,
      ),
    );
    if (result == null) return;
    try {
      await _api.updateAdminTask(
        widget.authToken,
        taskId: task.id,
        description: result.description,
        phase: result.phase,
        requiresCheckoff: result.requiresCheckoff,
      );
      _toast('Task updated');
      await _refresh();
    } on ApiClientException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> _handleDeleteTask(AdminJob job, AdminTask task) async {
    final confirmed = await _confirm(
      title: 'Delete task?',
      message: 'Remove "${task.description}" from ${job.name}?',
      destructiveLabel: 'Delete',
    );
    if (!confirmed) return;
    try {
      await _api.deleteAdminTask(widget.authToken, task.id);
      _toast('Task deleted');
      await _refresh();
    } on ApiClientException catch (e) {
      _toast(e.message);
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    String destructiveLabel = 'Confirm',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(destructiveLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task & Job Editor'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _board == null ? null : _handleCreateJob,
        icon: const Icon(Icons.add),
        label: const Text('Add Job'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _board == null) {
      return _ErrorPanel(message: _error!, onRetry: _refresh);
    }
    if (_board == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        _buildFilterBar(),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        if (_error != null)
          Container(
            width: double.infinity,
            color: Colors.red.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        Expanded(child: _buildJobsList()),
      ],
    );
  }

  Widget _buildFilterBar() {
    final options = _mealOptions;
    final totalJobs = _board?.jobs.length ?? 0;
    final totalTasks = _board?.jobs.fold<int>(0, (a, j) => a + j.totalTaskCount) ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$totalJobs jobs · $totalTasks tasks',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (meal) => ChoiceChip(
                    label: Text(meal),
                    selected: _mealFilter == meal,
                    onSelected: (_) => setState(() => _mealFilter = meal),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    final jobs = _visibleJobs;
    if (jobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No jobs match this filter. Add one with the button below.'),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _JobCard(
          job: job,
          phases: _board?.phases ?? const ['Setup', 'During Shift', 'Cleanup'],
          expanded: _expandedJobIds.contains(job.id),
          onToggleExpanded: () {
            setState(() {
              if (!_expandedJobIds.add(job.id)) {
                _expandedJobIds.remove(job.id);
              }
            });
          },
          onRename: () => _handleRenameJob(job),
          onDelete: () => _handleDeleteJob(job),
          onAddTask: (phase) => _handleCreateTask(job, phase),
          onEditTask: (task) => _handleEditTask(job, task),
          onDeleteTask: (task) => _handleDeleteTask(job, task),
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.phases,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onRename,
    required this.onDelete,
    required this.onAddTask,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final AdminJob job;
  final List<String> phases;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final void Function(String phase) onAddTask;
  final void Function(AdminTask task) onEditTask;
  final void Function(AdminTask task) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if ((job.mealType ?? '').isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  job.mealType!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job.totalTaskCount} tasks · ${job.shiftName ?? '—'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Rename',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onRename,
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final phase in phases) ...[
                    const Divider(height: 1),
                    _PhaseSection(
                      phase: phase,
                      tasks: job.tasksByPhase[phase] ?? const [],
                      onAddTask: () => onAddTask(phase),
                      onEditTask: onEditTask,
                      onDeleteTask: onDeleteTask,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PhaseSection extends StatelessWidget {
  const _PhaseSection({
    required this.phase,
    required this.tasks,
    required this.onAddTask,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final String phase;
  final List<AdminTask> tasks;
  final VoidCallback onAddTask;
  final void Function(AdminTask task) onEditTask;
  final void Function(AdminTask task) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  phase,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add task'),
              ),
            ],
          ),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 4),
              child: Text(
                'No tasks yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            )
          else
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10, right: 8),
                      child: Icon(Icons.circle, size: 6),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          task.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    if (!task.requiresCheckoff)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Tooltip(
                          message: 'Does not require checkoff',
                          child: Icon(
                            Icons.flag_outlined,
                            size: 16,
                            color: theme.disabledColor,
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => onEditTask(task),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => onDeleteTask(task),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _JobFormResult {
  const _JobFormResult({required this.name, required this.shiftId});
  final String name;
  final int shiftId;
}

class _JobFormDialog extends StatefulWidget {
  const _JobFormDialog({
    required this.title,
    required this.shifts,
    this.initialName = '',
    required this.initialShiftId,
    this.lockShift = false,
  });

  final String title;
  final List<AdminShift> shifts;
  final String initialName;
  final int initialShiftId;
  final bool lockShift;

  @override
  State<_JobFormDialog> createState() => _JobFormDialogState();
}

class _JobFormDialogState extends State<_JobFormDialog> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  late int _shiftId = widget.initialShiftId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(_JobFormResult(name: name, shiftId: _shiftId));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Job name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _shiftId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Shift',
                border: OutlineInputBorder(),
              ),
              items: widget.shifts
                  .map(
                    (shift) => DropdownMenuItem<int>(
                      value: shift.id,
                      child: Text(
                        shift.name.isNotEmpty
                            ? shift.name
                            : 'Shift #${shift.id}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: widget.lockShift
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _shiftId = value);
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _TaskFormResult {
  const _TaskFormResult({
    required this.description,
    required this.phase,
    required this.requiresCheckoff,
  });

  final String description;
  final String phase;
  final bool requiresCheckoff;
}

class _TaskFormDialog extends StatefulWidget {
  const _TaskFormDialog({
    required this.title,
    required this.phases,
    this.initialDescription = '',
    required this.initialPhase,
    this.initialRequiresCheckoff,
  });

  final String title;
  final List<String> phases;
  final String initialDescription;
  final String initialPhase;
  final bool? initialRequiresCheckoff;

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.initialDescription);
  late String _phase = widget.initialPhase;
  late bool _requiresCheckoff =
      widget.initialRequiresCheckoff ?? (widget.initialPhase != 'During Shift');

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(
      _TaskFormResult(
        description: text,
        phase: _phase,
        requiresCheckoff: _requiresCheckoff,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              autofocus: true,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _phase,
              decoration: const InputDecoration(
                labelText: 'Phase',
                border: OutlineInputBorder(),
              ),
              items: widget.phases
                  .map((phase) =>
                      DropdownMenuItem<String>(value: phase, child: Text(phase)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _phase = value;
                  if (widget.initialRequiresCheckoff == null) {
                    _requiresCheckoff = value != 'During Shift';
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              value: _requiresCheckoff,
              onChanged: (value) => setState(() => _requiresCheckoff = value),
              title: const Text('Requires check-off'),
              subtitle: const Text(
                'When on, employees and supervisors have to mark this task complete.',
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
