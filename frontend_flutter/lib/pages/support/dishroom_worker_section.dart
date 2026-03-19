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
  String _meal = _localMeals.first;
  String _jobName = dishroomJobs.first.name;
  final Map<String, bool> _checks = {};
  int _lastReset = 0;
  int _lastBack = 0;

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
        _meal = _localMeals.first;
        _jobName = dishroomJobs.first.name;
        _checks.clear();
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
    final job = dishroomJobs.firstWhere((j) => j.name == _jobName);
    final setupDone = _allChecked(job.setup);
    final cleanupDone = _allChecked(job.cleanup);
    final deepCleanTasks = dishroomDeepCleanTasksFor(
      meal: _meal,
      weekday: DateTime.now().weekday,
    );
    final deepCleanDone = _allChecked(deepCleanTasks);

    if (_step >= 6) {
      return const SimpleFinishCard(
        title: 'Dishroom Shift Complete',
        message:
            'All dishroom tasks complete. Report to the dishroom lead trainer.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle(
              icon: Icons.cleaning_services,
              title: 'Dishroom Tasks',
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_step + 1) / 6,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: const Color(0xFFE2ECF8),
              color: const Color(0xFF1F5E9C),
            ),
            const SizedBox(height: 12),
            if (_step == 0) ...[
              const Text(
                'Step 1 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _meal,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Meal'),
                items: _localMeals
                    .map(
                      (meal) =>
                          DropdownMenuItem(value: meal, child: Text(meal)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _meal = value ?? _meal),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 1) ...[
              const Text(
                'Step 2 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _jobName,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Dishroom Job'),
                items: dishroomJobs
                    .map(
                      (job) => DropdownMenuItem(
                        value: job.name,
                        child: Text(job.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _jobName = value ?? _jobName),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 2) ...[
              const Text(
                'Step 3 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'Setup (Before Doors Open)',
                tasks: job.setup,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: setupDone ? () => setState(() => _step = 3) : null,
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 3) ...[
              const Text(
                'Step 4 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'During Shift (Doors Open)',
                tasks: job.during,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 4),
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 4) ...[
              const Text(
                'Step 5 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'Cleanup (After Doors Close)',
                tasks: job.cleanup,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: cleanupDone
                      ? () => setState(() => _step = 5)
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ] else if (_step == 5) ...[
              const Text(
                'Step 6 of 7',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: 'Deep Clean',
                tasks: deepCleanTasks,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: deepCleanDone
                      ? () => setState(() => _step = 6)
                      : null,
                  child: const Text('Next'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lead-trainer support flow for dishroom trainees.
