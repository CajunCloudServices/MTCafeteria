import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/daily_shift_report.dart';
import '../theme/stitch_tokens.dart';
import 'ui/stitch_buttons.dart';

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

  Future<bool> _confirmUndoSubmission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo Submission?'),
        content: const Text(
          'This will change the daily shift report back to a draft.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Undo Submission'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final visibleFields = lineShiftReportFields;
    final isSubmitted = widget.currentReport?.isSubmitted ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Daily Shift Report', style: StitchText.titleLg),
            ),
            if (isSubmitted)
              Text(
                'Submitted',
                style: StitchText.bodyStrong.copyWith(
                  color: StitchColors.primary,
                ),
              )
            else
              Text(
                'Draft',
                style: StitchText.bodyStrong.copyWith(
                  color: StitchColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: StitchSpacing.md),
        if (_reportError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(StitchSpacing.md),
              decoration: BoxDecoration(
                color: StitchColors.errorContainer,
                borderRadius: BorderRadius.circular(StitchRadii.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: StitchColors.onErrorContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _reportError!,
                      style: StitchText.bodyStrong.copyWith(
                        color: StitchColors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_reportFeedback != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(StitchSpacing.md),
              decoration: BoxDecoration(
                color: StitchColors.secondaryContainer,
                borderRadius: BorderRadius.circular(StitchRadii.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: StitchColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _reportFeedback!,
                      style: StitchText.bodyStrong.copyWith(
                        color: StitchColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ...(() {
          final sectionOrder = <String>[];
          final fieldsBySection = <String, List<DailyShiftReportField>>{};
          for (final field in visibleFields) {
            if (!fieldsBySection.containsKey(field.section)) {
              sectionOrder.add(field.section);
              fieldsBySection[field.section] = <DailyShiftReportField>[];
            }
            fieldsBySection[field.section]!.add(field);
          }

          return sectionOrder.map((section) {
            final sectionFields = fieldsBySection[section]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: StitchSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section, style: StitchText.titleMd),
                  const SizedBox(height: StitchSpacing.md),
                  ...sectionFields.map((field) {
                      if (field.key == 'count') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(StitchSpacing.lg),
                            decoration: BoxDecoration(
                              color: StitchColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(
                                StitchRadii.md,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total', style: StitchText.titleSm),
                                const SizedBox(height: 4),
                                Text(
                                  _reportValues['count'] ?? '0',
                                  style: StitchText.displayXl,
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
                        padding: const EdgeInsets.only(bottom: 10),
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
                          style: StitchText.bodyLg.copyWith(
                            fontWeight: field.readOnly
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: field.readOnly
                                ? StitchColors.onSurface
                                : StitchColors.onSurface,
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
                            alignLabelWithHint: isLongField,
                            filled: field.readOnly,
                            fillColor: field.readOnly
                                ? StitchColors.surfaceContainer
                                : null,
                            helperStyle: StitchText.body,
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
            );
          });
        })(),
        const SizedBox(height: StitchSpacing.sm),
        if (isSubmitted)
          StitchPrimaryButton(
            label: _reportSaving ? 'Undoing…' : 'Undo Submission',
            icon: Icons.undo_rounded,
            onPressed: _reportSaving
                ? null
                : () async {
                    final confirmed = await _confirmUndoSubmission();
                    if (!confirmed || !mounted) return;
                    setState(() {
                      _reportSaving = true;
                      _reportError = null;
                      _reportFeedback = null;
                    });
                    try {
                      await widget.onSave(widget.meal, _reportValues);
                      if (!mounted) return;
                      setState(() {
                        _reportFeedback =
                            'Submission undone. Report is back in draft.';
                      });
                    } catch (_) {
                      if (!mounted) return;
                      setState(() {
                        _reportError =
                            'Could not undo submission. Try again.';
                      });
                    } finally {
                      if (mounted) {
                        setState(() {
                          _reportSaving = false;
                        });
                      }
                    }
                  },
          )
        else
          Row(
            children: [
              Expanded(
                child: StitchSecondaryButton(
                  label: _reportSaving ? 'Saving…' : 'Save Draft',
                  icon: Icons.save_rounded,
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
                              _reportError =
                                  'Could not save draft. Try again.';
                            });
                          } finally {
                            if (mounted) {
                              setState(() {
                                _reportSaving = false;
                              });
                            }
                          }
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StitchPrimaryButton(
                  label: _reportSubmitting ? 'Submitting…' : 'Submit',
                  icon: Icons.send_rounded,
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
                              _reportFeedback =
                                  'Report submitted to leadership.';
                            });
                          } catch (error) {
                            final message = error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            );
                            if (!mounted) return;
                            setState(() {
                              _reportError = message.isEmpty
                                  ? 'Report submit failed. Verify required fields and try again.'
                                  : message;
                              _reportFeedback = null;
                            });
                          } finally {
                            if (mounted) {
                              setState(() {
                                _reportSubmitting = false;
                              });
                            }
                          }
                        },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
