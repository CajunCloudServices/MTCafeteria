part of '../dashboard_page.dart';

class _StudentManagerPortalSection extends StatelessWidget {
  const _StudentManagerPortalSection({
    required this.user,
    required this.pendingAssignments,
    required this.pointSentAssignments,
    required this.pointApprovalAssignments,
    required this.pointAssignableUsers,
    required this.pointInboxError,
    required this.pointSentError,
    required this.pointAssignableUsersError,
    required this.pointApprovalQueueError,
    required this.onAcceptPointAssignment,
    required this.onAssignPoints,
    required this.onApprovePointAssignment,
    required this.onRefreshPointCenter,
  });

  final UserSession user;
  final List<PointAssignment> pendingAssignments;
  final List<PointAssignment> pointSentAssignments;
  final List<PointAssignment> pointApprovalAssignments;
  final List<AssignableUser> pointAssignableUsers;
  final String? pointInboxError;
  final String? pointSentError;
  final String? pointAssignableUsersError;
  final String? pointApprovalQueueError;
  final Future<void> Function(int assignmentId, String initials)
  onAcceptPointAssignment;
  final Future<void> Function({
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  })
  onAssignPoints;
  final Future<void> Function(int assignmentId) onApprovePointAssignment;
  final Future<void> Function() onRefreshPointCenter;

  @override
  Widget build(BuildContext context) {
    if (!user.canSubmitPointRequests && !user.canManagePoints) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('You do not have point center access for this portal.'),
        ),
      );
    }

    return ReportingPage(
      user: user,
      pendingAssignments: pendingAssignments,
      onAcceptAssignment: onAcceptPointAssignment,
      onRefresh: onRefreshPointCenter,
      canSubmitPointRequests: user.canSubmitPointRequests,
      canApprovePointRequests: user.canManagePoints,
      pointSentAssignments: pointSentAssignments,
      pointApprovalAssignments: pointApprovalAssignments,
      pointAssignableUsers: pointAssignableUsers,
      pointInboxError: pointInboxError,
      pointSentError: pointSentError,
      pointAssignableUsersError: pointAssignableUsersError,
      pointApprovalQueueError: pointApprovalQueueError,
      onAssignPoints: onAssignPoints,
      onApprovePointAssignment: onApprovePointAssignment,
      onRefreshPointCenter: onRefreshPointCenter,
    );
  }
}
