import 'package:flutter/material.dart';

import '../theme/app_ui_tokens.dart';

/// Central dashboard launcher card that exposes only the actions the current
/// user/profile is allowed to open.
class DashboardHubCard extends StatelessWidget {
  const DashboardHubCard({
    super.key,
    required this.canOpenReference,
    required this.canOpenFindItem,
    required this.canOpenDiningMap,
    required this.canViewTrainings,
    required this.onOpenWorkflow,
    required this.onOpenFindItem,
    required this.onOpenDiningMap,
    required this.onOpenManagerPortal,
    required this.onOpenTrainings,
    required this.onOpenReference,
  });

  final bool canOpenReference;
  final bool canOpenFindItem;
  final bool canOpenDiningMap;
  final bool canViewTrainings;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenFindItem;
  final VoidCallback onOpenDiningMap;
  final VoidCallback onOpenManagerPortal;
  final VoidCallback onOpenTrainings;
  final VoidCallback onOpenReference;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF9FBFF), Color(0xFFF1F6FD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppUiTokens.cardRadius),
            border: Border.all(color: AppUiTokens.shellBorder),
            boxShadow: AppUiTokens.shellShadowSoft,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF123A65),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('hub-start-workflow'),
                    onPressed: onOpenWorkflow,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
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
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('2-minute Trainings'),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: const ValueKey('hub-open-manager-portal'),
                    onPressed: onOpenManagerPortal,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Student Manager Portal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
