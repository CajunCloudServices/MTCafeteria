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
  String? _section;
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
        _section = null;
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
    final section = _section;
    if (section == null) return const [];
    final day = DateTime.now().weekday;
    final raw = switch (section) {
      'Tile Floors' => _tileFloorsByDay[day] ?? const <String>[],
      'Rotational Jobs' => _rotationalByDay[day] ?? const <String>[],
      _ => _dailyJobs,
    };
    return [
      for (var i = 0; i < raw.length; i += 1)
        LocalChecklistTask(
          id: 'nc-${section.toLowerCase().replaceAll(' ', '-')}-$day-$i',
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
      return SimpleFinishCard(
        title: 'Night Custodial Complete',
        message: 'All custodial tasks complete. Submit final handoff report.',
      );
    }

    final activeTasks = _activeTasks;
    final sectionDone = _allChecked(activeTasks);

    void maybePromptForShiftFinish() {
      final ready = _step == 1 && sectionDone;
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
        if (!mounted || !shouldFinish || _step != 1) return;
        setState(() => _step = 2);
      });
    }

    maybePromptForShiftFinish();

    if (_step == 0) {
      return StitchSelectionScreen(
        title: 'Select Section',
        options: [
          for (final section in _sections)
            StitchSelectionOption(
              rowKey: ValueKey('night-section-$section'),
              label: section,
              icon: _sectionIcon(section),
              selected: false,
              onTap: () => setState(() {
                _section = section;
                _step = 1;
              }),
            ),
        ],
      );
    }

    final activeSection = _section;
    if (activeSection == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildAppHeaderTitle(context, activeSection),
        const SizedBox(height: StitchSpacing.xl),
        LocalPhaseChecklist(
          title: activeSection,
          tasks: activeTasks,
          checks: _checks,
          onToggle: (id, checked) =>
              setState(() => _checks[id] = checked),
        ),
        const SizedBox(height: StitchSpacing.md),
        StitchPrimaryButton(
          label: 'Finish',
          icon: Icons.check_rounded,
          onPressed: sectionDone
              ? () => setState(() => _step = 2)
              : null,
        ),
      ],
    );
  }

  IconData _sectionIcon(String section) {
    switch (section) {
      case 'Daily Jobs':
        return Icons.cleaning_services_rounded;
      case 'Tile Floors':
        return Icons.grid_on_rounded;
      case 'Rotational Jobs':
        return Icons.autorenew_rounded;
      default:
        return Icons.work_outline_rounded;
    }
  }
}

/// Shared instruction card used by the local support sections.
