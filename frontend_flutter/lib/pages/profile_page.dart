import 'package:flutter/material.dart';

import '../models/user_session.dart';

/// Personal profile and point summary for the authenticated user.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user});

  final UserSession user;

  @override
  Widget build(BuildContext context) {
    final roleLabel = user.role == 'Employee' ? 'Line Worker' : user.role;
    final status = _pointsStatus(user.points);

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _InfoRow(label: 'Role', value: roleLabel),
                const SizedBox(height: 8),
                _InfoRow(label: 'Email', value: user.email),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Points', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(
                  '${user.points}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: Color(0xFF12365E),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (user.points.clamp(0, 20)) / 20,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE6EDF7),
                    color: status.color,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: status.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    status.message,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
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

/// Small two-column metadata row used by the profile card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF456283),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF12365E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Color/message pair for the point threshold banner.
class _PointsStatus {
  const _PointsStatus({required this.message, required this.color});

  final String message;
  final Color color;
}

/// Converts the current point total into the warning tier displayed in the UI.
_PointsStatus _pointsStatus(int points) {
  if (points >= 20) {
    return const _PointsStatus(
      message: 'Critical: 20+ points means termination threshold.',
      color: Color(0xFFB42318),
    );
  }

  if (points >= 15) {
    return const _PointsStatus(
      message: 'Warning: 15+ points means supervisor conversation threshold.',
      color: Color(0xFFB54708),
    );
  }

  return const _PointsStatus(
    message: 'Below warning threshold.',
    color: Color(0xFF217A3C),
  );
}
