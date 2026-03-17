/// Authenticated user payload plus derived capability checks used across the
/// frontend.
class UserSession {
  const UserSession({
    required this.id,
    required this.email,
    required this.role,
    required this.points,
  });

  final int id;
  final String email;
  final String role;
  final int points;

  /// Student managers are the only role allowed to edit landing content.
  bool get canManageLanding => role == 'Student Manager';
  bool get canManagePoints => role == 'Student Manager';
  bool get canSubmitPointRequests =>
      role == 'Student Manager' ||
      role == 'Supervisor' ||
      role == 'Lead Trainer' ||
      role == 'Dishroom Lead Trainer';

  UserSession copyWith({int? points}) {
    return UserSession(
      id: id,
      email: email,
      role: role,
      points: points ?? this.points,
    );
  }

  /// These getters keep role gating out of the UI layer.
  bool get canViewTrainings =>
      role == 'Lead Trainer' ||
      role == 'Supervisor' ||
      role == 'Student Manager';
  bool get canViewDailyShiftReports =>
      role == 'Lead Trainer' ||
      role == 'Supervisor' ||
      role == 'Student Manager' ||
      role == 'Dishroom Lead Trainer';
  bool get canAccessTrainerBoard =>
      role == 'Lead Trainer' ||
      role == 'Supervisor' ||
      role == 'Student Manager';
}
