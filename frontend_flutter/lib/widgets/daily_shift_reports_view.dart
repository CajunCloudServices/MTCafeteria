import 'package:flutter/material.dart';

import '../models/daily_shift_report.dart';
import '../theme/stitch_tokens.dart';
import 'ui/stitch_card.dart';

/// Leadership view of submitted daily shift reports.
class DailyShiftReportsView extends StatelessWidget {
  const DailyShiftReportsView({
    super.key,
    required this.reports,
    required this.error,
    required this.onRefresh,
  });

  final List<DailyShiftReport> reports;
  final String? error;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: StitchCard(
          padding: const EdgeInsets.all(StitchSpacing.xl2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Daily Shift Reports',
                      style: StitchText.titleLg,
                    ),
                  ),
                  Material(
                    color: StitchColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(StitchRadii.pill),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onRefresh,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: StitchColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Container(
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
                          error!,
                          style: StitchText.bodyStrong.copyWith(
                            color: StitchColors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: StitchSpacing.md),
              if (reports.isEmpty)
                Text('No submitted reports yet.', style: StitchText.body)
              else
                ...reports.map((report) {
                  final payload = report.payload;
                  final summaries = payload['summaries']?.trim() ?? '';
                  final maintenance =
                      payload['maintenanceConcerns']?.trim() ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StitchCard(
                      padding: const EdgeInsets.all(StitchSpacing.lg),
                      elevation: StitchCardElevation.subtle,
                      ring: true,
                      accentBarColor: StitchColors.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${report.mealType}  •  ${report.reportDate}',
                            style: StitchText.bodyStrong.copyWith(
                              color: StitchColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Submitted by ${report.submittedByEmail ?? 'Unknown'}',
                            style: StitchText.bodyLg.copyWith(
                              color: StitchColors.onSurfaceVariant,
                            ),
                          ),
                          if (maintenance.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Maintenance',
                              style: StitchText.titleSm,
                            ),
                            const SizedBox(height: 4),
                            Text(maintenance, style: StitchText.bodyLg),
                          ],
                          if (summaries.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('Summary', style: StitchText.titleSm),
                            const SizedBox(height: 4),
                            Text(
                              summaries,
                              style: StitchText.bodyLg,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
