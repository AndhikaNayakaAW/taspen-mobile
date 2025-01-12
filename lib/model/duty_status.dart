// lib/model/duty_status.dart

enum DutyStatus {
  draft("0", "Draft"),
  waiting("1", "Waiting"),
  approved("2", "Approved"),
  rejected("3", "Rejected"),
  returned("4", "Returned"),
  needApprove("5", "Need Approve"),
  returnStatus("6", "Return"),
  approve("7", "Approve"),
  reject("8", "Reject");

  final String code;
  final String description;

  const DutyStatus(this.code, this.description);

  /// Retrieves the description based on the status code.
  String get desc => description;

  /// Finds a DutyStatus by its code.
  static DutyStatus fromCode(String? code) {
    if (code == null) return DutyStatus.draft;
    return DutyStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => DutyStatus.draft, // Default fallback
    );
  }
}
