/// A disciplinary point event that may require manager approval and employee
/// acknowledgment before affecting the employee total.
class PointAssignment {
  const PointAssignment({
    required this.id,
    required this.assignedToUserId,
    required this.assignedToEmail,
    required this.assignedByUserId,
    required this.assignedByEmail,
    required this.pointsDelta,
    required this.assignmentDate,
    required this.reason,
    required this.assignmentDescription,
    required this.status,
    required this.requiresManagerApproval,
    required this.managerApprovedByUserId,
    required this.managerApprovedByEmail,
    required this.managerApprovedAt,
    required this.employeeInitials,
    required this.employeeConfirmedAt,
    required this.createdAt,
  });

  final int id;
  final int assignedToUserId;
  final String assignedToEmail;
  final int assignedByUserId;
  final String assignedByEmail;
  final int pointsDelta;
  final String assignmentDate;
  final String reason;
  final String assignmentDescription;
  final String status;
  final bool requiresManagerApproval;
  final int? managerApprovedByUserId;
  final String? managerApprovedByEmail;
  final String? managerApprovedAt;
  final String? employeeInitials;
  final String? employeeConfirmedAt;
  final String createdAt;

  factory PointAssignment.fromJson(Map<String, dynamic> json) {
    return PointAssignment(
      id: _toInt(json['id']),
      assignedToUserId: _toInt(json['assignedToUserId']),
      assignedToEmail: json['assignedToEmail'] as String? ?? '',
      assignedByUserId: _toInt(json['assignedByUserId']),
      assignedByEmail: json['assignedByEmail'] as String? ?? '',
      pointsDelta: _toInt(json['pointsDelta']),
      assignmentDate: json['assignmentDate'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      assignmentDescription: json['assignmentDescription'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      requiresManagerApproval: _toBool(json['requiresManagerApproval']),
      managerApprovedByUserId: _toNullableInt(json['managerApprovedByUserId']),
      managerApprovedByEmail: json['managerApprovedByEmail'] as String?,
      managerApprovedAt: json['managerApprovedAt'] as String?,
      employeeInitials: json['employeeInitials'] as String?,
      employeeConfirmedAt: json['employeeConfirmedAt'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

/// A user who can receive a point assignment from the current actor.
class AssignableUser {
  const AssignableUser({
    required this.id,
    required this.email,
    required this.role,
    required this.points,
  });

  final int id;
  final String email;
  final String role;
  final int points;

  factory AssignableUser.fromJson(Map<String, dynamic> json) {
    return AssignableUser(
      id: _toInt(json['id']),
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      points: _toInt(json['points']),
    );
  }
}

/// Result returned after an employee acknowledges assigned points.
class PointAcceptResult {
  const PointAcceptResult({
    required this.assignment,
    required this.updatedPoints,
  });

  final PointAssignment assignment;
  final int updatedPoints;

  factory PointAcceptResult.fromJson(Map<String, dynamic> json) {
    return PointAcceptResult(
      assignment: PointAssignment.fromJson(
        json['assignment'] as Map<String, dynamic>,
      ),
      updatedPoints: _toInt(json['updatedPoints']),
    );
  }
}

/// Accepts backend number values that may arrive as either JSON numbers or
/// strings.
int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Accepts boolean values that may be serialized as booleans, numbers, or
/// strings by different backend paths.
bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}
