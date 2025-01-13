// lib/model/duty_status.dart

import 'package:flutter/material.dart';

enum DutyStatus {
  draft("0", "Draft", ""),
  waiting("1", "Waiting", "Needs Approval"),
  approved("2", "Approved", "Approve"),
  rejected("3", "Rejected", "Reject"),
  returned("4", "Returned", "Return");

  // 1: dikirim
  // 2: disetujui
  // 3: dikembalikan
  // 4: selesai
  // 5: ditolak

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

  /// Returns the associated color for each DutyStatus.
  Color get color {
    switch (this) {
      case DutyStatus.draft:
        return Colors.grey;
      case DutyStatus.waiting:
        return Colors.orange;
      case DutyStatus.approved:
        return Colors.green;
      case DutyStatus.rejected:
        return Colors.red;
      case DutyStatus.returned:
        return Colors.blue;
      default:
        return Colors.grey; // Fallback color
    }
  }
}
