// lib/dto/get_duty_list.dart

import 'package:mobileapp/model/duty.dart';

class GetDutyList {
  final List<Duty> duty;
  final List<Duty>
      dutyApprove; // Assuming 'duty_approve' is a list that might be empty

  GetDutyList({
    required this.duty,
    required this.dutyApprove,
  });

  factory GetDutyList.fromJson(Map<String, dynamic> json) {
    var dutyList = json['duty'] as List<dynamic>? ?? [];
    var dutyApproveList = json['duty_approve'] as List<dynamic>? ?? [];

    return GetDutyList(
      duty: dutyList.map((dutyJson) => Duty.fromJson(dutyJson)).toList(),
      dutyApprove:
          dutyApproveList.map((dutyJson) => Duty.fromJson(dutyJson)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duty': duty.map((duty) => duty.toJson()).toList(),
      'duty_approve': dutyApprove.map((duty) => duty.toJson()).toList(),
    };
  }
}
