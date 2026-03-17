import 'package:flutter/material.dart';

import '../models/daily_shift_report.dart';

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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Daily Shift Reports',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRefresh,
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFF9A2A2A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (reports.isEmpty)
                  const Text('No submitted reports yet.')
                else
                  ...reports.map((report) {
                    final payload = report.payload;
                    // Surface the fields leadership scans most often so the
                    // list stays compact.
                    final summaries = payload['summaries']?.trim() ?? '';
                    final maintenance =
                        payload['maintenanceConcerns']?.trim() ?? '';
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFB7CAE4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${report.reportDate} • ${report.mealType}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF113A67),
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Submitted by ${report.submittedByEmail ?? 'Unknown'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF335678),
                            ),
                          ),
                          if (maintenance.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Maintenance: $maintenance'),
                          ],
                          if (summaries.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Summaries: $summaries',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
