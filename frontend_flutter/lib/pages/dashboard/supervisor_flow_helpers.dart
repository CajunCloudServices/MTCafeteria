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

  void _showShiftFinishRequirements({
    required BuildContext context,
    required List<String> pendingJobNames,
    required bool allSecondariesChecked,
    required bool deepCleanChecked,
    required bool supervisorChecklistDone,
    required bool reportSubmitted,
  }) {
    final missing = <String>[
      if (pendingJobNames.isNotEmpty)
        'Finish jobs: ${pendingJobNames.join(', ')}',
      if (!allSecondariesChecked) 'Complete secondaries',
      if (!deepCleanChecked) 'Complete deep clean',
      if (!supervisorChecklistDone) 'Complete supervisor end-of-shift checkoff',
      if (!reportSubmitted) 'Submit Daily Shift Report',
    ];

    if (missing.isEmpty) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Still Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF103760),
                  ),
                ),
                const SizedBox(height: 10),
                ...missing.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(0xFF1F5E9C),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1B3F66),
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
