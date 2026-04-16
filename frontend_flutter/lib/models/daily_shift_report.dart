/// Supported input types for dynamically rendered daily shift report fields.
enum DailyShiftReportInputType { text, number, name }

/// Metadata that drives the supervisor daily shift report form.
///
/// The UI renders directly from this definition so field order, sections, and
/// keyboard behavior stay in one place.
class DailyShiftReportField {
  const DailyShiftReportField({
    required this.key,
    required this.label,
    required this.section,
    this.required = true,
    this.maxLines = 2,
    this.inputType = DailyShiftReportInputType.text,
    this.readOnly = false,
  });

  final String key;
  final String label;
  final String section;
  final bool required;
  final int maxLines;
  final DailyShiftReportInputType inputType;
  final bool readOnly;
}

/// Canonical field list for the regular line shift report.
const List<DailyShiftReportField> lineShiftReportFields = [
  DailyShiftReportField(
    key: 'cafeWestCount',
    label: 'Cafe West',
    section: 'Counts',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'alohaPlateCount',
    label: 'Aloha Plate',
    section: 'Counts',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'choicesCount',
    label: 'Choices',
    section: 'Counts',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'juniorCashCount',
    label: 'Junior Cash',
    section: 'Counts',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'seniorCashCount',
    label: 'Senior Cash',
    section: 'Counts',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'sackRoomCount',
    label: 'Sack Room',
    section: 'Counts',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'sackCount',
    label: 'Sack',
    section: 'Counts',
    required: false,
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'count',
    label: 'Total',
    section: 'Counts',
    inputType: DailyShiftReportInputType.number,
    readOnly: true,
  ),
  DailyShiftReportField(
    key: 'late',
    label: 'Late',
    section: 'Attendance',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'sick',
    label: 'Sick',
    section: 'Attendance',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'noShows',
    label: 'No Shows',
    section: 'Attendance',
    inputType: DailyShiftReportInputType.number,
  ),
  DailyShiftReportField(
    key: 'deepClean',
    label: 'Deep Clean',
    section: 'Shift Coverage',
  ),
  DailyShiftReportField(
    key: 'seniorCashier',
    label: 'Senior Cashier',
    section: 'Shift Coverage',
    inputType: DailyShiftReportInputType.name,
  ),
  DailyShiftReportField(
    key: 'juniorCashier',
    label: 'Junior Cashier',
    section: 'Shift Coverage',
    inputType: DailyShiftReportInputType.name,
  ),
  DailyShiftReportField(
    key: 'sackCashier',
    label: 'Sack Cashier',
    section: 'Shift Coverage',
    required: false,
    inputType: DailyShiftReportInputType.name,
  ),
  DailyShiftReportField(
    key: 'specialtyMealsAttendantAndPlateCount',
    label: 'Specialty Meals Attendant and Plate Count',
    section: 'Shift Coverage',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'dinnerChoicesAlohaPerson',
    label: 'Dinner 5-8 Choices and Aloha Plate Person',
    section: 'Shift Coverage',
    required: false,
    maxLines: 3,
    inputType: DailyShiftReportInputType.name,
  ),
  DailyShiftReportField(
    key: 'oneOnOne',
    label: '1 on 1',
    section: 'Coaching and Notes',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'shiftShoutout',
    label: 'Shift Shoutout',
    section: 'Coaching and Notes',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'entreeItemOutage',
    label: 'Entree Item Outage',
    section: 'Inventory and Operations',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'productOutage',
    label: 'Product Outage',
    section: 'Inventory and Operations',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'productSurplus',
    label: 'Product Surplus',
    section: 'Inventory and Operations',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'lockersChecked',
    label: 'Lockers Checked',
    section: 'Inventory and Operations',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'maintenanceConcerns',
    label: 'Maintenance Concerns',
    section: 'Inventory and Operations',
    maxLines: 4,
  ),
  DailyShiftReportField(
    key: 'generalComments',
    label: 'General Comments',
    section: 'Coaching and Notes',
    maxLines: 4,
  ),
  DailyShiftReportField(
    key: 'trainings',
    label: 'Trainings',
    section: 'Coaching and Notes',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'serviceMissionariesPresentForShift',
    label: 'Service Missionaries Present For Shift',
    section: 'Shift Coverage',
    maxLines: 3,
  ),
  DailyShiftReportField(
    key: 'summaries',
    label: 'Summaries',
    section: 'Coaching and Notes',
    maxLines: 5,
  ),
];

/// Creates a normalized payload containing every known report key.
///
/// This keeps the draft form and submitted reports stable even when the backend
/// omits empty values.
Map<String, String> emptyLineShiftReportPayload() {
  return {for (final field in lineShiftReportFields) field.key: ''};
}

/// Client-side representation of a saved or submitted line shift report.
class DailyShiftReport {
  const DailyShiftReport({
    required this.id,
    required this.reportDate,
    required this.mealType,
    required this.track,
    required this.status,
    required this.submittedByUserId,
    required this.submittedByEmail,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.payload,
  });

  final int id;
  final String reportDate;
  final String mealType;
  final String track;
  final String status;
  final int submittedByUserId;
  final String? submittedByEmail;
  final String? submittedAt;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, String> payload;

  /// Submitted reports are immutable from the supervisor flow.
  bool get isSubmitted => status == 'Submitted';

  factory DailyShiftReport.fromJson(Map<String, dynamic> json) {
    final payloadJson = json['payload'] as Map<String, dynamic>? ?? const {};
    final payload = emptyLineShiftReportPayload();
    payloadJson.forEach((key, value) {
      payload[key] = value?.toString() ?? '';
    });

    return DailyShiftReport(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reportDate: json['reportDate'] as String? ?? '',
      mealType: json['mealType'] as String? ?? 'Breakfast',
      track: json['track'] as String? ?? 'Line',
      status: json['status'] as String? ?? 'Draft',
      submittedByUserId: (json['submittedByUserId'] as num?)?.toInt() ?? 0,
      submittedByEmail: json['submittedByEmail'] as String?,
      submittedAt: json['submittedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      payload: payload,
    );
  }
}
