import 'package:flutter/material.dart';

import '../models/user_session.dart';
import '../theme/stitch_tokens.dart';
import '../widgets/ui/stitch_card.dart';

/// Stitch-aligned profile view.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user});

  final UserSession user;

  @override
  Widget build(BuildContext context) {
    final status = _pointsStatus(user.points);
    final displayName = _displayName(user.email);
    final initials = _initials(displayName);

    // Progress is capped at 20 to match the warning/termination threshold.
    final clamped = user.points.clamp(0, 20);
    final pct = clamped / 20;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      children: [
        _ProfileHeader(
          displayName: displayName,
          email: user.email,
          initials: initials,
        ),
        const SizedBox(height: StitchSpacing.lg),
        _PointsCard(
          points: user.points,
          progress: pct,
          status: status,
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.initials,
  });

  final String displayName;
  final String email;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.xl),
      elevation: StitchCardElevation.subtle,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: StitchColors.surfaceContainer,
              borderRadius: BorderRadius.circular(StitchRadii.md),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: StitchText.titleLg.copyWith(color: StitchColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: StitchText.titleLg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _ProfileMetaRow(label: 'Email', value: email),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetaRow extends StatelessWidget {
  const _ProfileMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$label:',
          style: StitchText.bodyStrong.copyWith(
            color: StitchColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: StitchText.body,
        ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({
    required this.points,
    required this.progress,
    required this.status,
  });

  final int points;
  final double progress;
  final _PointsStatus status;

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: const EdgeInsets.all(StitchSpacing.xl2),
      elevation: StitchCardElevation.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: StitchColors.tertiaryFixed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: StitchColors.onTertiaryFixedVariant,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Penalty Points', style: StitchText.titleSm),
              ),
              Text(
                '$points / 20',
                style: StitchText.metric.copyWith(color: status.color),
              ),
            ],
          ),
          const SizedBox(height: StitchSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(StitchRadii.pill),
            child: Container(
              height: 10,
              color: StitchColors.surfaceContainer,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: status.color),
                ),
              ),
            ),
          ),
          const SizedBox(height: StitchSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(StitchRadii.md),
              border: Border.all(
                color: status.color.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              status.message,
              style: StitchText.bodyStrong.copyWith(color: status.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsStatus {
  const _PointsStatus({
    required this.message,
    required this.color,
    required this.trailing,
  });

  final String message;
  final Color color;
  final String trailing;
}

_PointsStatus _pointsStatus(int points) {
  if (points >= 20) {
    return _PointsStatus(
      message: 'Critical',
      color: StitchColors.error,
      trailing: '$points / 20',
    );
  }
  if (points >= 15) {
    return _PointsStatus(
      message: 'Warning',
      color: const Color(0xFFB54708),
      trailing: '$points / 20',
    );
  }
  return _PointsStatus(
    message: 'On Track',
    color: const Color(0xFF217A3C),
    trailing: '$points / 20',
  );
}

String _displayName(String email) {
  final local = email.split('@').first;
  return local
      .replaceAll(RegExp(r'[._-]+'), ' ')
      .split(' ')
      .where((s) => s.isNotEmpty)
      .map((s) => s[0].toUpperCase() + s.substring(1))
      .join(' ');
}

String _initials(String name) {
  final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
