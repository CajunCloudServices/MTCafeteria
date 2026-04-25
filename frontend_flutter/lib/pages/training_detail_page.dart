import 'package:flutter/material.dart';
import 'training/training_text_data.dart';
import '../theme/stitch_tokens.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_header.dart';
import '../widgets/shift_selection_cards.dart';
import '../widgets/ui/stitch_buttons.dart';
import '../widgets/ui/stitch_card.dart';
import '../widgets/ui/stitch_chip.dart';

/// Full-screen manual 2-minute training viewer with rotating daily default
/// content.
///
/// Visual spec mirrors `2_minute_training/code.html`:
/// - Editorial headline (Manrope extrabold) + eyebrow ("2-Minute Training")
/// - Objective / Key Directives cards with soft shadow and ringed surface
/// - Optional picker strip above viewer when "See All" is on
class TrainingDetailPage extends StatefulWidget {
  const TrainingDetailPage({
    super.key,
    required this.navIndex,
    required this.onSelectNav,
  });

  final int navIndex;
  final ValueChanged<int> onSelectNav;

  @override
  State<TrainingDetailPage> createState() => _TrainingDetailPageState();
}

enum _TrainingTrack { line, dishroom }

class _TrainingDetailPageState extends State<TrainingDetailPage> {
  _TrainingTrack? _selectedTrack;
  _TrainingTrack _pendingTrack = _TrainingTrack.line;
  int _selectedTrainingIndex = 0;
  bool _showAllTrainings = false;

  List<TrainingTextContent> get _trainings {
    switch (_selectedTrack) {
      case _TrainingTrack.dishroom:
        return buildDishroomTrainings();
      case _TrainingTrack.line:
      case null:
        return buildLineTrainings();
    }
  }

  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int _rotationIndexForToday(_TrainingTrack track) {
    if (_trainings.isEmpty) return 0;
    return _rotationIndexForDate(_todayDateOnly(), track);
  }

  int _rotationIndexForDate(DateTime date, _TrainingTrack track) {
    if (_trainings.isEmpty) return 0;
    final cycleStart = track == _TrainingTrack.line
        ? DateTime(2026, 3, 12)
        : DateTime(2026, 3, 17);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final delta = track == _TrainingTrack.line
        ? dateOnly.difference(cycleStart).inDays
        : _nonSundayDayDelta(cycleStart, dateOnly);
    final length = _trainings.length;
    return ((delta % length) + length) % length;
  }

  bool _isSunday(DateTime date) => date.weekday == DateTime.sunday;

  int _nonSundayDayDelta(DateTime start, DateTime end) {
    if (start == end) return _isSunday(start) ? -1 : 0;
    final forward = !end.isBefore(start);
    var cursor = DateTime(start.year, start.month, start.day);
    final target = DateTime(end.year, end.month, end.day);
    var delta = 0;
    if (forward) {
      while (cursor.isBefore(target)) {
        cursor = cursor.add(const Duration(days: 1));
        if (!_isSunday(cursor)) delta++;
      }
      return delta;
    }
    while (cursor.isAfter(target)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!_isSunday(cursor)) delta--;
    }
    return delta;
  }

  DateTime _nextNonSunday(DateTime date) {
    var cursor = DateTime(date.year, date.month, date.day);
    while (_isSunday(cursor)) {
      cursor = cursor.add(const Duration(days: 1));
    }
    return cursor;
  }

  DateTime _advanceNonSunday(DateTime date, int count) {
    var cursor = DateTime(date.year, date.month, date.day);
    var remaining = count;
    while (remaining > 0) {
      cursor = cursor.add(const Duration(days: 1));
      if (!_isSunday(cursor)) remaining--;
    }
    return cursor;
  }

  String _trainingTitleFor(int index) => _trainings[index].title;

  int _scheduleAnchorIndexForCurrentTrack() {
    final track = _selectedTrack ?? _TrainingTrack.line;
    return _rotationIndexForToday(track);
  }

  DateTime _trainingDateFor(int index) {
    final track = _selectedTrack ?? _TrainingTrack.line;
    final today = track == _TrainingTrack.dishroom
        ? _nextNonSunday(_todayDateOnly())
        : _todayDateOnly();
    final delta =
        (index - _scheduleAnchorIndexForCurrentTrack() + _trainings.length) %
        _trainings.length;
    if (track == _TrainingTrack.dishroom) {
      return _advanceNonSunday(today, delta);
    }
    return today.add(Duration(days: delta));
  }

  String _formatDateLong(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _selectTraining(int index) {
    setState(() {
      _selectedTrainingIndex = index;
    });
  }

  String _trackLabel(_TrainingTrack track) =>
      track == _TrainingTrack.line ? 'Line' : 'Dishroom';

  void _confirmTrack() {
    setState(() {
      _selectedTrack = _pendingTrack;
      _selectedTrainingIndex = _rotationIndexForToday(_pendingTrack);
      _showAllTrainings = false;
    });
  }

  void _handleBottomNavSelection(int index) {
    widget.onSelectNav(index);
    if (index != widget.navIndex) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedTrack == null) {
      return Scaffold(
        backgroundColor: StitchColors.surface,
        appBar: AppBar(
          toolbarHeight: appHeaderToolbarHeight(context),
          centerTitle: true,
          leading: BackButton(
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: buildAppHeaderTitle(context, 'Shift Area'),
          actions: [
            AppHeaderMenuButton(
              onSelected: (value) {
                if (value == 'close') {
                  Navigator.of(context).maybePop();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'close',
                  child: Row(
                    children: [
                      Icon(Icons.close, size: 18),
                      SizedBox(width: 10),
                      Text('Close'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(StitchSpacing.lg),
          child: ShiftTrackSelectionCard(
            availableTracks: const ['Line', 'Dishroom'],
            selectedTrack: _pendingTrack == _TrainingTrack.dishroom
                ? 'Dishroom'
                : 'Line',
            onTrackChanged: (value) {
              _pendingTrack = value == 'Dishroom'
                  ? _TrainingTrack.dishroom
                  : _TrainingTrack.line;
              _confirmTrack();
            },
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: widget.navIndex,
          onTap: _handleBottomNavSelection,
        ),
      );
    }

    final isDishroomSunday =
        _selectedTrack == _TrainingTrack.dishroom &&
        _isSunday(_todayDateOnly());
    final selectedTraining = _trainings[_selectedTrainingIndex];
    final displayDate = _formatDateLong(
      _trainingDateFor(_selectedTrainingIndex),
    );

    return PopScope(
      canPop: _selectedTrack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedTrack != null) {
          setState(() {
            _selectedTrack = null;
            _pendingTrack = _TrainingTrack.line;
            _showAllTrainings = false;
            _selectedTrainingIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: StitchColors.surface,
        appBar: AppBar(
          toolbarHeight: appHeaderToolbarHeight(context),
          centerTitle: true,
          leading: BackButton(
            onPressed: () {
              if (_selectedTrack != null) {
                setState(() {
                  _selectedTrack = null;
                  _pendingTrack = _TrainingTrack.line;
                  _showAllTrainings = false;
                  _selectedTrainingIndex = 0;
                });
                return;
              }
              Navigator.of(context).maybePop();
            },
          ),
          title: buildAppHeaderTitle(context, '2-Minute Trainings'),
          actions: [
            AppHeaderMenuButton(
              onSelected: (value) {
                if (value == 'switch-area') {
                  setState(() {
                    _selectedTrack = null;
                    _pendingTrack = _TrainingTrack.line;
                    _showAllTrainings = false;
                    _selectedTrainingIndex = 0;
                  });
                  return;
                }
                if (value == 'toggle-all') {
                  setState(() {
                    _showAllTrainings = !_showAllTrainings;
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  height: 38,
                  value: 'current-area',
                  child: Text(_trackLabel(_selectedTrack!)),
                ),
                const PopupMenuItem<String>(
                  value: 'switch-area',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 18),
                      SizedBox(width: 10),
                      Text('Switch Area'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'toggle-all',
                  child: Row(
                    children: [
                      Icon(
                        _showAllTrainings
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(_showAllTrainings ? 'Hide All' : 'See All'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: widget.navIndex,
          onTap: _handleBottomNavSelection,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 960;

            final viewer = _TrainingViewerPanel(
              training: selectedTraining,
              displayDate: displayDate,
              track: _trackLabel(_selectedTrack!),
            );

            final picker = _TrainingPickerPanel(
              trainings: _trainings,
              isWide: isWide,
              selectedIndex: _selectedTrainingIndex,
              titleFor: _trainingTitleFor,
              dateFor: (i) => _formatDateShort(_trainingDateFor(i)),
              onSelect: _selectTraining,
            );

            return Padding(
              padding: const EdgeInsets.all(StitchSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDishroomSunday) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(StitchSpacing.md),
                      decoration: BoxDecoration(
                        color: StitchColors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(StitchRadii.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: StitchColors.onTertiaryContainer,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No dishroom training is scheduled on Sunday. Showing the next scheduled training.',
                              style: StitchText.bodyStrong.copyWith(
                                color: StitchColors.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StitchSpacing.md),
                  ],
                  Expanded(
                    child: _showAllTrainings
                        ? isWide
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(width: 340, child: picker),
                                    const SizedBox(width: StitchSpacing.md),
                                    Expanded(child: viewer),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    picker,
                                    const SizedBox(height: StitchSpacing.md),
                                    Expanded(child: viewer),
                                  ],
                                )
                        : viewer,
                  ),
                  const SizedBox(height: StitchSpacing.md),
                  StitchSecondaryButton(
                    label: _showAllTrainings ? 'Hide All' : 'See All',
                    icon: _showAllTrainings
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onPressed: () =>
                        setState(() => _showAllTrainings = !_showAllTrainings),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrainingViewerPanel extends StatelessWidget {
  const _TrainingViewerPanel({
    required this.training,
    required this.displayDate,
    required this.track,
  });

  final TrainingTextContent training;
  final String displayDate;
  final String track;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timer_rounded,
                  size: 18,
                  color: StitchColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '2-Minute Training',
                  style: StitchText.eyebrowBold.copyWith(
                    color: StitchColors.onSurface,
                  ),
                ),
                Text('  •  ', style: StitchText.eyebrow),
                Text(
                  track,
                  style: StitchText.eyebrowBold.copyWith(
                    color: StitchColors.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  displayDate,
                  style: StitchText.bodyStrong.copyWith(
                    color: StitchColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: StitchSpacing.md),
            Text(
              training.title,
              style: StitchText.displayXl.copyWith(
                color: StitchColors.onSurface,
                height: 1.1,
              ),
            ),
            const SizedBox(height: StitchSpacing.xl),
            _ObjectiveSection(training: training),
            if (training.generalGuidelines.isNotEmpty) ...[
              const SizedBox(height: StitchSpacing.xl),
              _GeneralGuidelinesSection(lines: training.generalGuidelines),
            ],
            const SizedBox(height: StitchSpacing.xl),
            ...training.sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: StitchSpacing.xl),
                child: _TrainingSectionBlock(section: section),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectiveSection extends StatelessWidget {
  const _ObjectiveSection({required this.training});

  final TrainingTextContent training;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              size: 22,
              color: StitchColors.primary,
            ),
            const SizedBox(width: 10),
            Text('The Objective', style: StitchText.titleLg),
          ],
        ),
        const SizedBox(height: StitchSpacing.md),
        Text(
          training.objective,
          style: StitchText.titleSm.copyWith(
            height: 1.5,
            color: StitchColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (training.teachingIdea != null &&
            training.teachingIdea!.trim().isNotEmpty) ...[
          const SizedBox(height: StitchSpacing.md),
          Text(
            training.teachingIdea!,
            style: StitchText.bodyLg.copyWith(
              color: StitchColors.onSurface,
              height: 1.55,
            ),
          ),
        ],
      ],
    );
  }
}

class _GeneralGuidelinesSection extends StatelessWidget {
  const _GeneralGuidelinesSection({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StitchChip(
          label: 'General Guidelines',
          tone: StitchChipTone.tertiary,
        ),
        const SizedBox(height: StitchSpacing.md),
        ...lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: StitchColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line,
                    style: StitchText.bodyLg.copyWith(
                      color: StitchColors.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrainingSectionBlock extends StatelessWidget {
  const _TrainingSectionBlock({required this.section});

  final TrainingTextSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: StitchColors.outlineVariant)),
      ),
      padding: const EdgeInsets.only(top: StitchSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.list_alt_rounded,
                size: 20,
                color: StitchColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(section.heading, style: StitchText.titleLg)),
            ],
          ),
          const SizedBox(height: StitchSpacing.lg),
          for (var i = 0; i < section.bullets.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: StitchColors.primaryFixed,
                      borderRadius: BorderRadius.circular(StitchRadii.pill),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: StitchText.bodyStrong.copyWith(
                        color: StitchColors.onPrimaryFixed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        section.bullets[i],
                        style: StitchText.titleSm.copyWith(
                          height: 1.5,
                          color: StitchColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TrainingPickerPanel extends StatelessWidget {
  const _TrainingPickerPanel({
    required this.trainings,
    required this.isWide,
    required this.selectedIndex,
    required this.titleFor,
    required this.dateFor,
    required this.onSelect,
  });

  final List<TrainingTextContent> trainings;
  final bool isWide;
  final int selectedIndex;
  final String Function(int index) titleFor;
  final String Function(int index) dateFor;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return StitchCard(
        padding: const EdgeInsets.all(StitchSpacing.md),
        child: ListView.separated(
          itemCount: trainings.length,
          shrinkWrap: true,
          itemBuilder: (context, index) => _TrainingPickerTile(
            title: titleFor(index),
            date: dateFor(index),
            selected: index == selectedIndex,
            onTap: () => onSelect(index),
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trainings.length,
        itemBuilder: (context, index) => SizedBox(
          width: 200,
          child: _TrainingPickerTile(
            title: titleFor(index),
            date: dateFor(index),
            selected: index == selectedIndex,
            onTap: () => onSelect(index),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }
}

class _TrainingPickerTile extends StatelessWidget {
  const _TrainingPickerTile({
    required this.title,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.md),
      elevation: StitchCardElevation.subtle,
      ring: true,
      ringColor: selected ? StitchColors.primary : StitchColors.hairline,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: StitchText.titleSm.copyWith(
              color: selected ? StitchColors.primary : StitchColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(date, style: StitchText.caption),
        ],
      ),
    );
  }
}
