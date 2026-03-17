import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/daily_shift_report.dart';

/// Dynamic supervisor form for the line daily shift report.
class SupervisorDailyShiftReportForm extends StatefulWidget {
  const SupervisorDailyShiftReportForm({
    super.key,
    required this.meal,
    required this.currentReport,
    required this.onSave,
    required this.onSubmit,
  });

  final String meal;
  final DailyShiftReport? currentReport;
  final Future<void> Function(String meal, Map<String, String> payload) onSave;
  final Future<void> Function(String meal, Map<String, String> payload)
  onSubmit;

  @override
  State<SupervisorDailyShiftReportForm> createState() =>
      _SupervisorDailyShiftReportFormState();
}

class _SupervisorDailyShiftReportFormState
    extends State<SupervisorDailyShiftReportForm> {
  // The total is computed from the individual count fields instead of being
  // directly editable.
  static const List<String> _countComponentKeys = [
    'cafeWestCount',
    'alohaPlateCount',
    'choicesCount',
    'juniorCashCount',
    'seniorCashCount',
    'sackRoomCount',
    'sackCount',
  ];

  Map<String, String> _reportValues = emptyLineShiftReportPayload();
  String _reportSeedKey = '';
  bool _reportSaving = false;
  bool _reportSubmitting = false;
  String? _reportFeedback;
  String? _reportError;

  @override
  void initState() {
    super.initState();
    _syncFromReport();
  }

  @override
  void didUpdateWidget(covariant SupervisorDailyShiftReportForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFromReport();
  }

  void _syncFromReport() {
    final report = widget.currentReport;
    final payload = report?.payload ?? emptyLineShiftReportPayload();
    // Ignore rebuilds that did not actually deliver a new report payload.
    final nextKey =
        '${widget.meal}|${report?.id ?? 0}|${report?.updatedAt ?? ''}|${report?.status ?? ''}';
    if (nextKey == _reportSeedKey) {
      return;
    }

    _reportSeedKey = nextKey;
    _reportValues = {...emptyLineShiftReportPayload(), ...payload};
    _recomputeTotalCount();
    _reportError = null;
    _reportFeedback = null;
  }

  int _parseNonNegativeInt(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    final value = int.tryParse(raw.trim()) ?? 0;
    if (value < 0) return 0;
    return value;
  }

  void _recomputeTotalCount() {
    final total = _countComponentKeys.fold<int>(
      0,
      (sum, key) => sum + _parseNonNegativeInt(_reportValues[key]),
    );
    _reportValues['count'] = '$total';
  }

  List<String> _missingRequiredFields() {
    return lineShiftReportFields
        .where(
          (field) =>
              field.required &&
              (_reportValues[field.key]?.trim().isEmpty ?? true),
        )
        .map((field) => field.label)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Daily Shift Report',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            if (widget.currentReport?.isSubmitted ?? false)
              const Chip(
                label: Text('Submitted'),
                avatar: Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF2E7D32),
                ),
              )
            else
              const Chip(label: Text('Draft')),
          ],
        ),
        const SizedBox(height: 8),
        if (_reportError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _reportError!,
              style: const TextStyle(
                color: Color(0xFF9A2A2A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (_reportFeedback != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _reportFeedback!,
              style: const TextStyle(
                color: Color(0xFF1E5A93),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ...(() {
          // Preserve the field order declared in the model so the on-screen
          // form matches the paper report supervisors already know.
          final sectionOrder = <String>[];
          final fieldsBySection = <String, List<DailyShiftReportField>>{};
          for (final field in lineShiftReportFields) {
            if (!fieldsBySection.containsKey(field.section)) {
              sectionOrder.add(field.section);
              fieldsBySection[field.section] = <DailyShiftReportField>[];
            }
            fieldsBySection[field.section]!.add(field);
          }

          return sectionOrder.map((section) {
            final sectionFields = fieldsBySection[section]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFB6C9E4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF123A65),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...sectionFields.map((field) {
                      if (field.key == 'count') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF4FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFBFD0E3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Color(0xFF4E6786),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _reportValues['count'] ?? '0',
                                  style: const TextStyle(
                                    color: Color(0xFF123A65),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final isLongField = field.maxLines > 2;
                      final effectiveMaxLines =
                          field.inputType == DailyShiftReportInputType.number ||
                              field.inputType == DailyShiftReportInputType.name
                          ? 1
                          : field.maxLines;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextFormField(
                          key: ValueKey(
                            '${field.key}-${widget.meal}-$_reportSeedKey'
                            '${field.readOnly ? '-${_reportValues[field.key] ?? ''}' : ''}',
                          ),
                          initialValue: _reportValues[field.key] ?? '',
                          minLines: 1,
                          maxLines: effectiveMaxLines,
                          readOnly: field.readOnly,
                          enabled: true,
                          style: TextStyle(
                            color: field.readOnly
                                ? const Color(0xFF123A65)
                                : const Color(0xFF243B53),
                            fontWeight: field.readOnly
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: field.readOnly ? 20 : 16,
                          ),
                          keyboardType:
                              field.inputType ==
                                  DailyShiftReportInputType.number
                              ? TextInputType.number
                              : isLongField
                              ? TextInputType.multiline
                              : TextInputType.text,
                          inputFormatters:
                              field.inputType ==
                                  DailyShiftReportInputType.number
                              ? [FilteringTextInputFormatter.digitsOnly]
                              : null,
                          textInputAction: isLongField
                              ? TextInputAction.newline
                              : TextInputAction.next,
                          textCapitalization:
                              field.inputType == DailyShiftReportInputType.name
                              ? TextCapitalization.words
                              : TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: field.required
                                ? field.label
                                : '${field.label} (optional)',
                            filled: field.readOnly,
                            fillColor: field.readOnly
                                ? const Color(0xFFEAF4FF)
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _reportValues[field.key] = value;
                              if (_countComponentKeys.contains(field.key)) {
                                _recomputeTotalCount();
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          });
        })(),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reportSaving
                    ? null
                    : () async {
                        setState(() {
                          _reportSaving = true;
                          _reportError = null;
                          _reportFeedback = null;
                        });
                        try {
                          await widget.onSave(widget.meal, _reportValues);
                          if (!mounted) return;
                          setState(() {
                            _reportFeedback = 'Draft saved.';
                          });
                        } catch (_) {
                          if (!mounted) return;
                          setState(() {
                            _reportError = 'Could not save draft. Try again.';
                          });
                        } finally {
                          if (mounted) {
                            setState(() {
                              _reportSaving = false;
                            });
                          }
                        }
                      },
                child: Text(_reportSaving ? 'Saving...' : 'Save Draft'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _reportSubmitting
                    ? null
                    : () async {
                        final missing = _missingRequiredFields();
                        if (missing.isNotEmpty) {
                          setState(() {
                            _reportError =
                                'Complete required fields: ${missing.join(', ')}';
                            _reportFeedback = null;
                          });
                          return;
                        }

                        setState(() {
                          _reportSubmitting = true;
                          _reportError = null;
                          _reportFeedback = null;
                        });
                        try {
                          await widget.onSubmit(widget.meal, _reportValues);
                          if (!mounted) return;
                          setState(() {
                            _reportFeedback = 'Report submitted to leadership.';
                          });
                        } catch (_) {
                          if (!mounted) return;
                          setState(() {
                            _reportError =
                                'Report submit failed. Verify required fields and try again.';
                          });
                        } finally {
                          if (mounted) {
                            setState(() {
                              _reportSubmitting = false;
                            });
                          }
                        }
                      },
                child: Text(_reportSubmitting ? 'Submitting...' : 'Submit'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
