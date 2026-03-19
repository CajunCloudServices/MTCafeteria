import 'package:flutter/material.dart';
import 'training/training_text_data.dart';
import '../widgets/shift_selection_cards.dart';

/// Full-screen two-minute training viewer with rotating daily default content.
class TrainingDetailPage extends StatefulWidget {
  const TrainingDetailPage({super.key});

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

  /// Rotation is calendar-based so the highlighted training advances daily
  /// without requiring per-day backend assignments.
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
        ? DateTime(2026, 3, 16)
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

  DateTime _trainingDateFor(int index) {
    final track = _selectedTrack ?? _TrainingTrack.line;
    final today = track == _TrainingTrack.dishroom
        ? _nextNonSunday(_todayDateOnly())
        : _todayDateOnly();
    final delta =
        (index - _selectedTrainingIndex + _trainings.length) %
        _trainings.length;
    if (track == _TrainingTrack.dishroom) {
      return _advanceNonSunday(today, delta);
    }
    return today.add(Duration(days: delta));
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
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

  @override
  Widget build(BuildContext context) {
    if (_selectedTrack == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('2-Minute Trainings')),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FCFF), Color(0xFFE7EEF9)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ShiftTrackSelectionCard(
              availableTracks: const ['Line', 'Dishroom'],
              selectedTrack: _pendingTrack == _TrainingTrack.dishroom
                  ? 'Dishroom'
                  : 'Line',
              onTrackChanged: (value) => setState(() {
                _pendingTrack = value == 'Dishroom'
                    ? _TrainingTrack.dishroom
                    : _TrainingTrack.line;
              }),
              onContinue: _confirmTrack,
            ),
          ),
        ),
      );
    }

    final isDishroomSunday =
        _selectedTrack == _TrainingTrack.dishroom &&
        _isSunday(_todayDateOnly());
    final selectedTraining = _trainings[_selectedTrainingIndex];
    final displayDate = _formatDate(_trainingDateFor(_selectedTrainingIndex));

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
        appBar: AppBar(
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
          title: Text('2-Minute Trainings • ${_trackLabel(_selectedTrack!)}'),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FCFF), Color(0xFFE7EEF9)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              final picker = Container(
                width: isWide ? 340 : double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1F5E9C).withValues(alpha: 0.24),
                  ),
                ),
                child: isWide
                    ? ListView.separated(
                        itemCount: _trainings.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedTrainingIndex == index;
                          final date = _formatDate(_trainingDateFor(index));
                          return InkWell(
                            onTap: () => _selectTraining(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE6F0FF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1F5E9C)
                                      : const Color(0xFFB3C7E2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _trainingTitleFor(index),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF123A65),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      color: Color(0xFF4E6786),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                      )
                    : SizedBox(
                        height: 116,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _trainings.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedTrainingIndex == index;
                            return InkWell(
                              onTap: () => _selectTraining(index),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 186,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE6F0FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1F5E9C)
                                        : const Color(0xFFB3C7E2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _trainingTitleFor(index),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF123A65),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Tap to view',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF1F5E9C,
                                        ).withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                        ),
                      ),
              );

              final viewer = Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1F5E9C).withValues(alpha: 0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Text(
                        displayDate,
                        style: const TextStyle(
                          color: Color(0xFF4E6786),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF9FB6D3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedTraining.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF123A65),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    selectedTraining.objective,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E4E70),
                                      height: 1.35,
                                    ),
                                  ),
                                  if (selectedTraining.teachingIdea != null &&
                                      selectedTraining.teachingIdea!
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      selectedTraining.teachingIdea!,
                                      style: const TextStyle(
                                        color: Color(0xFF365A80),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (selectedTraining
                                .generalGuidelines
                                .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F4E6),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFD4BC8D),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'General Guidelines',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF5B3F11),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ...selectedTraining.generalGuidelines.map(
                                      (line) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '- ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Expanded(child: Text(line)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            ...selectedTraining.sections.map(
                              (section) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7FAFF),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFB3C7E2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        section.heading,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF123A65),
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...section.bullets.map(
                                        (line) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 5,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '- ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  line,
                                                  style: const TextStyle(
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDishroomSunday) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F4E6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD4BC8D)),
                        ),
                        child: const Text(
                          'No dishroom training is scheduled on Sunday. Showing the next scheduled training.',
                          style: TextStyle(
                            color: Color(0xFF5B3F11),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Expanded(
                      child: _showAllTrainings
                          ? isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      picker,
                                      const SizedBox(width: 12),
                                      Expanded(child: viewer),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      picker,
                                      const SizedBox(height: 10),
                                      Expanded(child: viewer),
                                    ],
                                  )
                          : viewer,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(
                          () => _showAllTrainings = !_showAllTrainings,
                        ),
                        child: Text(_showAllTrainings ? 'Hide all' : 'See all'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
