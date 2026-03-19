part of 'package:frontend_flutter/state/app_state.dart';

extension AppStatePoints on AppState {
  Future<void> refreshPointCenter() async {
    if (!isAuthenticated || !_features.pointsEnabled) return;

    pointInboxError = null;
    pointSentError = null;
    pointAssignableUsersError = null;
    pointApprovalQueueError = null;

    try {
      pointInbox = await _apiClient.getPointAssignmentInbox(_token!);
    } catch (e) {
      pointInbox = const [];
      pointInboxError = 'Could not load point notifications.';
      debugPrint('Point inbox failed: $e');
    }

    // Each section loads independently so one endpoint failure does not blank
    // the rest of the point center.
    if (canSubmitPointRequests) {
      try {
        pointSent = await _apiClient.getPointAssignmentsSent(_token!);
      } catch (e) {
        pointSent = const [];
        pointSentError = 'Could not load recent assignments.';
        debugPrint('Point sent list failed: $e');
      }

      try {
        pointAssignableUsers = await _apiClient.getAssignableUsers(_token!);
      } catch (e) {
        pointAssignableUsers = const [];
        pointAssignableUsersError = 'Could not load assignable users.';
        debugPrint('Assignable users failed: $e');
      }
    } else {
      pointSent = const [];
      pointAssignableUsers = const [];
    }

    if (canManagePoints) {
      try {
        pointApprovalQueue = await _apiClient.getPointApprovalQueue(_token!);
      } catch (e) {
        pointApprovalQueue = const [];
        pointApprovalQueueError = 'Could not load manager approval queue.';
        debugPrint('Point approval queue failed: $e');
      }
    } else {
      pointApprovalQueue = const [];
    }

    _stateChanged();
  }

  Future<void> assignPoints({
    required int assignedToUserId,
    required int pointsDelta,
    required String assignmentDate,
    required String reason,
    required String assignmentDescription,
  }) async {
    if (!isAuthenticated || !canSubmitPointRequests) return;

    await _apiClient.createPointAssignment(
      _token!,
      assignedToUserId: assignedToUserId,
      pointsDelta: pointsDelta,
      assignmentDate: assignmentDate,
      reason: reason,
      assignmentDescription: assignmentDescription,
    );

    await refreshPointCenter();
  }

  Future<void> acceptAssignedPoints({
    required int assignmentId,
    required String initials,
  }) async {
    if (!isAuthenticated) return;

    final result = await _apiClient.acceptPointAssignment(
      _token!,
      assignmentId: assignmentId,
      initials: initials,
    );

    user = user?.copyWith(points: result.updatedPoints);
    await refreshPointCenter();
  }

  Future<void> approvePointAssignment({required int assignmentId}) async {
    if (!isAuthenticated || !canManagePoints) return;

    await _apiClient.approvePointAssignment(
      _token!,
      assignmentId: assignmentId,
    );

    await refreshPointCenter();
  }

}
