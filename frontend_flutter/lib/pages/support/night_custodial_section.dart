part of '../dashboard_support_sections.dart';

class NightCustodialSection extends StatefulWidget {
  const NightCustodialSection({
    super.key,
    required this.resetSignal,
    required this.backSignal,
    required this.onBackAtRoot,
  });

  final int resetSignal;
  final int backSignal;
  final VoidCallback onBackAtRoot;

  @override
  State<NightCustodialSection> createState() => _NightCustodialSectionState();
}

class _NightCustodialSectionState extends State<NightCustodialSection> {
  int _step = 0;
  String _section = 'Daily Jobs';
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
  void didUpdateWidget(covariant NightCustodialSection oldWidget) {
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
        _section = 'Daily Jobs';
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

  static const _sections = ['Daily Jobs', 'Tile Floors', 'Rotational Jobs'];

  static const _dailyJobs = [
    'Pulpers emptied',
    'Paper dispensers/consumables refilled',
    'Trough, traps, arms, and drains in dishroom/scullery/machine cleaned',
    'Floors scrubbed, rinsed, and squeegeed',
    'Drains cleaned',
    'Hose, scrubbers, and squeegees put away',
  ];

  static const _tileFloorsByDay = {
    1: ['Bev. Line 4', 'Cereal Station'],
    2: ['Bev. Line 2', 'Junior Cash'],
    3: ['Island'],
    4: ['Cafe West'],
    5: ['Dish Return'],
    6: ['Aloha Plate', 'Choices', 'Line 1 and 3'],
    7: [],
  };

  static const _rotationalByDay = {
    1: [
      'Grout/shelf tops',
      'Cup conveyor/under section',
      'Line area (Supervisor)',
    ],
    2: ['Blue belt - shift return', 'Bev. Line 1 and 4', 'Fryers'],
    3: ['Blue belt - pit', 'Hoods', 'Ovens'],
    4: ['Blue belt - BTS', 'Bev. Line 2'],
    5: [
      'Fryers',
      'Bev. Line 6',
      'Basement stairs/pipe carts/fans/cereal dispensers',
    ],
    6: ['Grey floors', 'Custodial closet', 'Deep cleaning'],
    7: [],
  };

  List<LocalChecklistTask> get _activeTasks {
    final day = DateTime.now().weekday;
    final raw = switch (_section) {
      'Tile Floors' => _tileFloorsByDay[day] ?? const <String>[],
      'Rotational Jobs' => _rotationalByDay[day] ?? const <String>[],
      _ => _dailyJobs,
    };
    return [
      for (var i = 0; i < raw.length; i += 1)
        LocalChecklistTask(
          id: 'nc-${_section.toLowerCase().replaceAll(' ', '-')}-$day-$i',
          description: raw[i],
          requiresCheckoff: true,
        ),
    ];
  }

  bool _allChecked(List<LocalChecklistTask> tasks) {
    return tasks
        .where((t) => t.requiresCheckoff)
        .every((t) => _checks[t.id] ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (_step >= 2) {
      return const SimpleFinishCard(
        title: 'Night Custodial Complete',
        message: 'All custodial tasks complete. Submit final handoff report.',
      );
    }

    final activeTasks = _activeTasks;
    final sectionDone = _allChecked(activeTasks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelTitle(
              icon: Icons.nights_stay,
              title: 'Night Custodial Tasks',
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_step + 1) / 2,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: const Color(0xFFE2ECF8),
              color: const Color(0xFF1F5E9C),
            ),
            const SizedBox(height: 12),
            if (_step == 0) ...[
              const Text(
                'Step 1 of 2',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _section,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Section'),
                items: _sections
                    .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _section = value ?? _section),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Next'),
                ),
              ),
            ] else ...[
              const Text(
                'Step 2 of 2',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete $_section (${weekdayNameLabel(DateTime.now().weekday)}).',
              ),
              const SizedBox(height: 8),
              LocalPhaseChecklist(
                title: _section,
                tasks: activeTasks,
                checks: _checks,
                onToggle: (id, checked) =>
                    setState(() => _checks[id] = checked),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: sectionDone
                      ? () => setState(() => _step = 2)
                      : null,
                  child: const Text('Finish'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shared instruction card used by the local support sections.
