import 'package:flutter/material.dart';

import '../theme/app_ui_tokens.dart';

/// Neutral bootstrap screen used in pilot mode so workers never see auth UI.
class PilotAccessPage extends StatelessWidget {
  const PilotAccessPage({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'MTC Dining',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16385F),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLoading ? 'Opening app...' : 'Preparing app...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF47627F),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: const Color(0xFF1F5E9C),
                    ),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F2),
                      borderRadius: BorderRadius.circular(
                        AppUiTokens.cardRadius,
                      ),
                      border: Border.all(
                        color: const Color(0xFFBF2C1E).withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Text(
                      'Unable to open the app right now. Check the connection and try again.',
                      style: TextStyle(
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
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
