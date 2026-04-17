part of '../dashboard_page.dart';

extension _SupervisorFlowHelpers on _SupervisorSectionState {
  bool _isJobComplete(SupervisorJobItem job) {
    final serverComplete =
        job.totalCount > 0 && job.checkedCount >= job.totalCount;
    final optimisticComplete = _optimisticallyCompletedJobIds.contains(
      job.jobId,
    );
    return serverComplete || optimisticComplete;
  }

  void _markJobOptimisticallyComplete(int jobId, String meal) {
    _updateSupervisorState(() {
      _optimisticCompletionMeal = meal;
      _optimisticallyCompletedJobIds.add(jobId);
    });
  }

  Future<void> _syncOptimisticCompletion({
    required int jobId,
    required Future<void> request,
  }) async {
    try {
      await request;
      if (!mounted) return;
      final board = widget.supervisorBoard;
      final serverHasCompletedJob =
          board?.jobs.any((job) => job.jobId == jobId && _isJobComplete(job)) ??
          false;
      if (serverHasCompletedJob) {
        _updateSupervisorState(() {
          _optimisticallyCompletedJobIds.remove(jobId);
          if (_optimisticallyCompletedJobIds.isEmpty) {
            _optimisticCompletionMeal = null;
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      _updateSupervisorState(() {
        _optimisticallyCompletedJobIds.remove(jobId);
        if (_optimisticallyCompletedJobIds.isEmpty) {
          _optimisticCompletionMeal = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update task. Please try again.'),
        ),
      );
    }
  }

  bool _canMarkShiftFinished({
    required bool hasPendingJobs,
    required bool allSecondariesChecked,
    required bool deepCleanChecked,
    required bool supervisorChecklistDone,
    required bool reportSubmitted,
  }) {
    // Finishing the shift is intentionally stricter than simply completing job
    // cleanup; supervisor secondaries, deep clean, checklist items, and the
    // report all have to be done first.
    return !hasPendingJobs &&
        allSecondariesChecked &&
        deepCleanChecked &&
        supervisorChecklistDone &&
        reportSubmitted;
  }
}
