// lib/model/duty_status.dart

enum DutyStatus {
  draft("0", "Draft", ""),
  waiting("1", "Waiting", "Needs Approval"),
  approved("2", "Approved", "Approve"),
  rejected("3", "Rejected", "Reject"),
  returned("4", "Returned", "Return");

  final String code;
  final String conceptorDescription;
  final String approverDescription;

  const DutyStatus(
      this.code, this.conceptorDescription, this.approverDescription);

  /// Retrieves the description based on the status code.
  String get conceptorDesc => conceptorDescription;
  String get approverDesc => approverDescription;

  /// Finds a DutyStatus by its code.
  static DutyStatus fromCode(String? code) {
    if (code == null) return DutyStatus.draft;
    return DutyStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => DutyStatus.draft, // Default fallback
    );
  }
}
