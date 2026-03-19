import 'package:flutter/material.dart';

/// Central dashboard launcher card that exposes only the actions the current
/// user/profile is allowed to open.
class DashboardHubCard extends StatelessWidget {
  const DashboardHubCard({
    super.key,
    required this.canOpenReference,
    required this.canOpenFindItem,
    required this.canOpenDiningMap,
    required this.canOpenManagerPortal,
    required this.canViewTrainings,
    required this.canAssignPoints,
    required this.canViewDailyShiftReports,
    required this.onOpenWorkflow,
    required this.onOpenFindItem,
    required this.onOpenDiningMap,
    required this.onOpenManagerPortal,
    required this.onOpenTrainings,
    required this.onOpenPoints,
    required this.onOpenReference,
    required this.onOpenDailyShiftReports,
  });

  final bool canOpenReference;
  final bool canOpenFindItem;
  final bool canOpenDiningMap;
  final bool canOpenManagerPortal;
  final bool canViewTrainings;
  final bool canAssignPoints;
  final bool canViewDailyShiftReports;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenFindItem;
  final VoidCallback onOpenDiningMap;
  final VoidCallback onOpenManagerPortal;
  final VoidCallback onOpenTrainings;
  final VoidCallback onOpenPoints;
  final VoidCallback onOpenReference;
  final VoidCallback onOpenDailyShiftReports;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('hub-start-workflow'),
                    onPressed: onOpenWorkflow,
                    child: const Text('Start Shift'),
                  ),
                ),
                if (canOpenFindItem || canOpenDiningMap) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (canOpenFindItem)
                        Expanded(
                          child: OutlinedButton(
                            key: const ValueKey('hub-open-find-item'),
                            onPressed: onOpenFindItem,
                            child: const Text('Find an Item'),
                          ),
                        ),
                      if (canOpenFindItem && canOpenDiningMap)
                        const SizedBox(width: 10),
                      if (canOpenDiningMap)
                        Expanded(
                          child: OutlinedButton(
                            key: const ValueKey('hub-open-dining-map'),
                            onPressed: onOpenDiningMap,
                            child: const Text('Dining Map'),
                          ),
                        ),
                    ],
                  ),
                ],
                if (canOpenReference) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: const ValueKey('hub-open-reference'),
                      onPressed: onOpenReference,
                      child: const Text('Guides'),
                    ),
                  ),
                ],
                if (canViewTrainings) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: const ValueKey('hub-open-trainings'),
                      onPressed: onOpenTrainings,
                      child: const Text('2-minute Trainings'),
                    ),
                  ),
                ],
                if (canAssignPoints) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: const ValueKey('hub-open-points'),
                      onPressed: onOpenPoints,
                      child: const Text('Assign Points'),
                    ),
                  ),
                ],
                if (canViewDailyShiftReports) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: const ValueKey('hub-open-daily-shift-reports'),
                      onPressed: onOpenDailyShiftReports,
                      child: const Text('Daily Shift Reports'),
                    ),
                  ),
                ],
                if (canOpenManagerPortal) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: const ValueKey('hub-open-manager-portal'),
                      onPressed: onOpenManagerPortal,
                      child: const Text('Open Student Manager Portal'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
