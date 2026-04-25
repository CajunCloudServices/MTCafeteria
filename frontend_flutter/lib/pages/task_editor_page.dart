import 'package:flutter/material.dart';

import '../config/runtime_config.dart';
import '../models/admin_task_board.dart';
import '../services/api_client.dart';
import '../theme/stitch_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/ui/stitch_buttons.dart';
import '../widgets/ui/stitch_card.dart';
import '../widgets/ui/stitch_chip.dart';
import '../widgets/ui/stitch_selection_screen.dart';

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

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({super.key, required this.authToken, this.apiClient});

  final String authToken;
  final ApiClient? apiClient;

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  late final ApiClient _api =
      widget.apiClient ??
      ApiClient(runtimeConfig: AppRuntimeConfig.fromEnvironment);

  AdminTaskBoard? _board;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  List<String> get _jobNamesSorted {
    final board = _board;
    if (board == null) return const [];
    final names = board.jobs.map((j) => j.name).toSet().toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  List<AdminJob> _jobsForName(String name) {
    final board = _board;
    if (board == null) return <AdminJob>[];
    return board.jobs.where((job) => job.name == name).toList();
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
      final existingShiftIds = board.jobs
          .where((job) => job.name.toLowerCase() == result.name.toLowerCase())
          .map((job) => job.shiftId)
          .toSet();
      final shiftIdsToCreate = result.shiftIds
          .where((shiftId) => !existingShiftIds.contains(shiftId))
          .toList();

      if (shiftIdsToCreate.isEmpty) {
        _toast('That job already exists for the selected meals.');
        return;
      }

      for (final shiftId in shiftIdsToCreate) {
        await _api.createAdminJob(
          widget.authToken,
          name: result.name,
          shiftId: shiftId,
        );
      }

      final skippedCount = result.shiftIds.length - shiftIdsToCreate.length;
      if (shiftIdsToCreate.length == 1 && skippedCount == 0) {
        _toast('Job created');
      } else if (skippedCount == 0) {
        _toast('${shiftIdsToCreate.length} jobs created');
      } else {
        _toast(
          '${shiftIdsToCreate.length} jobs created, $skippedCount already existed',
        );
      }
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

  Future<void> _handleSelectJobMeal(String name) async {
    final board = _board;
    if (board == null) return;
    final options = _jobsForName(name);
    if (options.isEmpty) return;

    // Show the canonical meal list but mark unavailable meals as disabled.
    const allMeals = ['Breakfast', 'Lunch', 'Dinner'];
    final mealSet = <String>{};
    for (final j in options) {
      final mt = (j.mealType ?? '').trim();
      if (mt.isNotEmpty) mealSet.add(mt);
    }

    final selectedMeal = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (ctx) =>
            _JobMealSelectionPage(meals: allMeals, enabledMeals: mealSet),
      ),
    );
    if (!mounted) return;
    if (mealSet.isEmpty) {
      _toast('No meal variants available for "$name".');
      return;
    }
    if (selectedMeal == null) return;

    final selectedJob = options.firstWhere(
      (j) => (j.mealType ?? '') == selectedMeal,
      orElse: () => options.first,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return _JobEditScreen(
            jobName: name,
            getJob: () => _jobsForName(name).firstWhere(
              (j) => (j.mealType ?? '') == selectedMeal,
              orElse: () => selectedJob,
            ),
            onRename: (job) async => await _handleRenameJob(job),
            onDelete: (job) async => await _handleDeleteJob(job),
            onAddTask: (job, phase) async =>
                await _handleCreateTask(job, phase),
            onEditTask: (job, task) async => await _handleEditTask(job, task),
            onDeleteTask: (job, task) async =>
                await _handleDeleteTask(job, task),
          );
        },
      ),
    );
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
            style: FilledButton.styleFrom(backgroundColor: StitchColors.error),
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
        toolbarHeight: appHeaderToolbarHeight(context),
        title: buildAppHeaderTitle(context, 'Task & Job Editor'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refresh,
          ),
        ],
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
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAddJobButton(),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _InlineErrorBanner(message: _error!),
                    ],
                    const SizedBox(height: 14),
                    _buildJobsList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddJobButton() {
    return StitchPrimaryButton(
      label: 'Add Job',
      icon: Icons.add_rounded,
      height: StitchLayout.ctaHeightLg,
      onPressed: _handleCreateJob,
    );
  }

  Widget _buildJobsList() {
    final names = _jobNamesSorted;
    if (names.isEmpty) {
      return StitchCard(
        padding: const EdgeInsets.all(StitchSpacing.xl2),
        elevation: StitchCardElevation.subtle,
        ring: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.work_outline_rounded,
              size: 28,
              color: StitchColors.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text('No jobs available.', style: StitchText.titleMd),
            const SizedBox(height: 6),
            Text(
              'Add a new job to get started.',
              style: StitchText.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
          for (var index = 0; index < names.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            _JobNameCard(
              name: names[index],
              onTap: () => _handleSelectJobMeal(names[index]),
            ),
          ],
        ],
      );
  }
}

class _JobNameCard extends StatelessWidget {
  const _JobNameCard({
    required this.name,
    required this.onTap,
  });

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
      return StitchCard(
        padding: const EdgeInsets.symmetric(
          horizontal: StitchSpacing.lg,
          vertical: StitchSpacing.xl,
        ),
        onTap: onTap,
        child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: StitchText.titleMd.copyWith(
                    color: StitchColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_right_rounded,
            color: StitchColors.onSurfaceVariant,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _JobMealSelectionPage extends StatefulWidget {
  const _JobMealSelectionPage({
    required this.meals,
    required this.enabledMeals,
  });

  final List<String> meals;
  final Set<String> enabledMeals;

  @override
  State<_JobMealSelectionPage> createState() => _JobMealSelectionPageState();
}

class _JobMealSelectionPageState extends State<_JobMealSelectionPage> {
  String? _selectedMeal;

  List<String> get _availableMeals =>
      widget.meals.where(widget.enabledMeals.contains).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appHeaderToolbarHeight(context),
        title: buildAppHeaderTitle(context, 'Select Meal'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(StitchSpacing.lg),
        child: StitchSelectionScreen(
          title: 'Select Meal',
          options: [
            for (final meal in _availableMeals)
              StitchSelectionOption(
                rowKey: ValueKey('meal-row-$meal'),
                label: meal,
                icon: _iconForMeal(meal),
                selected: _selectedMeal == meal,
                onTap: () {
                  setState(() => _selectedMeal = meal);
                  Navigator.of(context).pop(meal);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _JobEditScreen extends StatefulWidget {
  const _JobEditScreen({
    required this.jobName,
    required this.getJob,
    required this.onRename,
    required this.onDelete,
    required this.onAddTask,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final String jobName;
  final AdminJob Function() getJob;
  final Future<void> Function(AdminJob job) onRename;
  final Future<void> Function(AdminJob job) onDelete;
  final Future<void> Function(AdminJob job, String phase) onAddTask;
  final Future<void> Function(AdminJob job, AdminTask task) onEditTask;
  final Future<void> Function(AdminJob job, AdminTask task) onDeleteTask;

  @override
  State<_JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends State<_JobEditScreen> {
  late AdminJob _job;

  @override
  void initState() {
    super.initState();
    _job = widget.getJob();
  }

  Future<void> _refreshJob() async {
    final latest = widget.getJob();
    if (!mounted) return;
    setState(() {
      _job = latest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appHeaderToolbarHeight(context),
        title: buildAppHeaderTitle(context, 'Edit ${widget.jobName}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _JobEditorHeader(
                  onRename: () async {
                    await widget.onRename(_job);
                    await _refreshJob();
                  },
                  onDelete: () async {
                    await widget.onDelete(_job);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: StitchSpacing.md),
                for (final phase in _job.tasksByPhase.keys) ...[
                  _PhaseSection(
                    phase: phase,
                    tasks: _job.tasksByPhase[phase] ?? const [],
                    onAddTask: () async {
                      await widget.onAddTask(_job, phase);
                      await _refreshJob();
                    },
                    onEditTask: (task) async {
                      await widget.onEditTask(_job, task);
                      await _refreshJob();
                    },
                    onDeleteTask: (task) async {
                      await widget.onDeleteTask(_job, task);
                      await _refreshJob();
                    },
                  ),
                  const SizedBox(height: StitchSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobEditorHeader extends StatelessWidget {
  const _JobEditorHeader({required this.onRename, required this.onDelete});

  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StitchSecondaryButton(
            label: 'Edit Job',
            icon: Icons.edit_outlined,
            onPressed: onRename,
          ),
        ),
        const SizedBox(width: StitchSpacing.md),
        Expanded(
          child: StitchSecondaryButton(
            label: 'Delete Job',
            icon: Icons.delete_outline,
            background: StitchColors.errorContainer,
            foreground: StitchColors.onErrorContainer,
            border: StitchColors.error.withValues(alpha: 0.18),
            onPressed: onDelete,
          ),
        ),
      ],
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
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.lg),
      elevation: StitchCardElevation.none,
      surface: StitchSurface.low,
      ring: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final summary = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StitchChip(
                    label: phase,
                    tone: StitchChipTone.primary,
                    uppercase: false,
                    filled: false,
                  ),
                ],
              );
              final addTask = StitchSecondaryButton(
                label: 'Add Task',
                icon: Icons.add_rounded,
                expand: stacked,
                onPressed: onAddTask,
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [summary, const SizedBox(height: 12), addTask],
                );
              }

              return Row(
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 12),
                  SizedBox(width: 148, child: addTask),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Text('No tasks yet.', style: StitchText.body)
          else
            ...tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: StitchColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(StitchRadii.md),
                    border: Border.all(
                      color: StitchColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: StitchColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.description,
                              style: StitchText.bodyStrong.copyWith(
                                height: 1.45,
                              ),
                            ),
                            if (!task.requiresCheckoff) ...[
                              const SizedBox(height: 8),
                              const StitchChip(
                                label: 'Optional',
                                tone: StitchChipTone.neutral,
                                uppercase: false,
                                dense: true,
                                icon: Icons.flag_outlined,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ActionIconButton(
                        tooltip: 'Edit',
                        icon: Icons.edit_outlined,
                        onPressed: () => onEditTask(task),
                      ),
                      const SizedBox(width: 8),
                      _ActionIconButton(
                        tooltip: 'Delete',
                        icon: Icons.delete_outline,
                        tone: StitchChipTone.error,
                        onPressed: () => onDeleteTask(task),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.tone = StitchChipTone.neutral,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final StitchChipTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone == StitchChipTone.error
        ? StitchColors.error
        : StitchColors.primary;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: StitchColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(StitchRadii.sm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(StitchRadii.sm),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class _JobFormResult {
  const _JobFormResult({required this.name, required this.shiftIds});

  final String name;
  final List<int> shiftIds;

  int get shiftId => shiftIds.first;
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
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );
  late int _sectionShiftId = widget.initialShiftId;
  late Set<String> _selectedMeals = <String>{
    _mealLabelForShift(
      widget.shifts.firstWhere(
        (shift) => shift.id == widget.initialShiftId,
        orElse: () => widget.shifts.first,
      ),
    ),
  };

  List<AdminShift> get _sectionShifts {
    final section = _sectionLabelForShiftId(_sectionShiftId);
    return widget.shifts
        .where((shift) => _sectionLabelForShift(shift) == section)
        .toList()
      ..sort(
        (a, b) => _mealSortOrder(
          _mealLabelForShift(a),
        ).compareTo(_mealSortOrder(_mealLabelForShift(b))),
      );
  }

  List<String> get _sectionLabels {
    final labels = widget.shifts.map(_sectionLabelForShift).toSet().toList();
    labels.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return labels;
  }

  String _sectionLabelForShift(AdminShift shift) {
    final raw = shift.shiftType.trim();
    if (raw.isEmpty) return 'Section';
    final lower = raw.toLowerCase();
    if (lower.endsWith(' shift')) {
      return raw.substring(0, raw.length - 6).trim();
    }
    return raw;
  }

  String _sectionLabelForShiftId(int shiftId) {
    final shift = widget.shifts.firstWhere(
      (entry) => entry.id == shiftId,
      orElse: () => widget.shifts.first,
    );
    return _sectionLabelForShift(shift);
  }

  String _mealLabelForShift(AdminShift shift) {
    final meal = shift.mealType.trim();
    return meal.isEmpty ? 'Shift ${shift.id}' : meal;
  }

  int _mealSortOrder(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      default:
        return 99;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (widget.lockShift) {
      Navigator.of(
        context,
      ).pop(_JobFormResult(name: name, shiftIds: <int>[widget.initialShiftId]));
      return;
    }

    final shiftIds = _sectionShifts
        .where((shift) => _selectedMeals.contains(_mealLabelForShift(shift)))
        .map((shift) => shift.id)
        .toList();
    if (shiftIds.isEmpty) return;
    Navigator.of(context).pop(_JobFormResult(name: name, shiftIds: shiftIds));
  }

  @override
  Widget build(BuildContext context) {
    final sectionShifts = _sectionShifts;
    final canSave = _nameController.text.trim().isNotEmpty &&
        (widget.lockShift || _selectedMeals.isNotEmpty);

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
              decoration: const InputDecoration(labelText: 'Job name'),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
            if (!widget.lockShift) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _sectionLabelForShiftId(_sectionShiftId),
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Section'),
                items: _sectionLabels
                    .map(
                      (label) => DropdownMenuItem<String>(
                        value: label,
                        child: Text(label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final nextShift = widget.shifts.firstWhere(
                    (shift) => _sectionLabelForShift(shift) == value,
                    orElse: () => widget.shifts.first,
                  );
                  setState(() {
                    _sectionShiftId = nextShift.id;
                    _selectedMeals = sectionShifts.isEmpty
                        ? <String>{}
                        : <String>{_mealLabelForShift(nextShift)};
                  });
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Meals', style: StitchText.fieldLabel),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: sectionShifts.map((shift) {
                  final meal = _mealLabelForShift(shift);
                  final selected = _selectedMeals.contains(meal);
                  return InkWell(
                    borderRadius: BorderRadius.circular(StitchRadii.sm),
                    onTap: () {
                      setState(() {
                        if (!selected) {
                          _selectedMeals.add(meal);
                        } else {
                          _selectedMeals.remove(meal);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? StitchColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        meal,
                        style: StitchText.bodyStrong.copyWith(
                          color: selected
                              ? StitchColors.primary
                              : StitchColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canSave ? _submit : null,
          child: const Text('Save'),
        ),
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
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _phase,
              decoration: const InputDecoration(labelText: 'Phase'),
              items: widget.phases
                  .map(
                    (phase) => DropdownMenuItem<String>(
                      value: phase,
                      child: Text(phase),
                    ),
                  )
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.xl2),
          elevation: StitchCardElevation.subtle,
          ring: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: StitchColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load the task board.',
                style: StitchText.titleMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: StitchText.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              StitchPrimaryButton(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.lg),
      elevation: StitchCardElevation.none,
      ring: true,
      ringColor: StitchColors.error.withValues(alpha: 0.22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: StitchColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: StitchText.bodyStrong.copyWith(
                color: StitchColors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
